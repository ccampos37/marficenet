SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      Proc [BKct_grabaautomatico_pro](
@base varchar(50),
@tabla varchar(50),
@mes  varchar(2), 
@comp varchar(10),
@asiento varchar(3) ,
@subasiento varchar(4))
as
DECLARE @sqlcad varchar(8000),@sqlcad2 varchar(8000), @sqlparm nvarchar(1000)
--Pararametros de la cadena
SET @sqlparm='@mes int,@comp varchar(10),@asiento varchar(3),
              @subasiento varchar(4)'
set @sqlcad='
	  SELECT 
       A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo, 
       A.analiticocodigo,A.asientocodigo,detcomprobitem=''00000'',
       A.monedacodigo,A.centrocostocodigo,A.documentocodigo,
       A.operacioncodigo,
       cuentacodigo=cuentadistribucion,
       A.detcomprobnumdocumento,A.detcomprobfechaemision,A.detcomprobfechavencimiento,
       detcomprobglosa=''Asiento automatico'',
       debe=Round((isnull((case when A.detcomprobdebe > 0 then 
                 case when c.indicador=''D'' then (A.detcomprobdebe +  A.detcomprobhaber)    * (distribucionporcen/100) 
                 else 0 end
             else case when A.detcomprobhaber > 0 then 
                 	case when c.indicador=''H'' then (A.detcomprobdebe +  A.detcomprobhaber)    * (distribucionporcen/100) 
                 	else 0 end end
             end),0)),2),    
       haber=Round((isnull((case when A.detcomprobhaber > 0 then 
               case when c.indicador=''D'' then (A.detcomprobdebe +  A.detcomprobhaber) * (distribucionporcen/100) 
               else 0 end  
             else case when A.detcomprobdebe > 0 then  
                    case when c.indicador=''H'' then (A.detcomprobdebe +  A.detcomprobhaber) * (distribucionporcen/100) 
                    else 0 end end  
             end),0)),2),
       usshaber=Round((isnull((case when A.detcomprobhaber > 0 then 
                   case when c.indicador=''D'' then (A.detcomprobussdebe +  A.detcomprobusshaber) * (distribucionporcen/100) 
                   else 0 end  
                else case when A.detcomprobdebe > 0 then 
                        case when c.indicador=''H'' then (A.detcomprobussdebe +  A.detcomprobusshaber) * (distribucionporcen/100) 
                        else 0 end end 
                end),0)),2),
       ussdebe=Round((isnull((case when A.detcomprobdebe > 0 then 
                    case when c.indicador=''D'' then (A.detcomprobussdebe +  A.detcomprobusshaber) * (distribucionporcen/100) 
                    else 0 end 
                else case when A.detcomprobhaber > 0 then 
                    case when c.indicador=''H'' then (A.detcomprobussdebe +  A.detcomprobusshaber) * (distribucionporcen/100) 
                    else 0 end end
                end),0)),2),     
       A.detcomprobtipocambio,
       A.detcomprobruc,
       detcomprobauto=1,
       A.detcomprobformacambio,A.detcomprobajusteuser,A.plantillaasientoinafecto,
       A.detcomprobnlibro,A.detcomprobfecharef, 
      ID=IDENTITY(int, 1,1) 	
      INTO #tempo
FROM  ['+@base+'].dbo.ct_cuenta b,['+@base+'].dbo.['+@tabla+'] A,
      (select cuentacodigo,indicador=''D'',cuentadistribucion=distribucioncargo,distribucionporcen from ['+@base+'].dbo.ct_distribucion 
       where NOT (rtrim(distribucioncargo)='''' or 
       distribucioncargo is null)
        Union all
         select cuentacodigo,indicador=''H'',cuentadistribucion=distribucionabono,distribucionporcen from ['+@base+'].dbo.ct_distribucion 
         where NOT (rtrim(distribucionabono)='''' or 
         distribucionabono is null)) as C           
WHERE  B.cuentaestadodistribucion=1 and 
               B.cuentacodigo=A.cuentacodigo and
                B.cuentacodigo=C.cuentacodigo and  
                A.cabcomprobmes='+@mes+' and  
                A.cabcomprobnumero='''+@comp+''' and
                A.asientocodigo='''+@asiento+''' and
			    A.subasientocodigo='''+@subasiento+'''
       order by A.cabcomprobnumero,c.indicador 
'  
set @sqlcad2= '
if @@rowcount > 0 
Begin   
   declare @pend int
   select @pend=isnull(max(detcomprobitem),0) from ['+@base+'].dbo.['+@tabla+']
   where  cabcomprobmes='+@mes+' and  cabcomprobnumero='''+@comp+''' and  
            asientocodigo='''+@asiento+''' and  subasientocodigo='''+@subasiento+'''      
 insert into ['+@base+'].dbo.['+@tabla+']
   (  cabcomprobmes, cabcomprobnumero, subasientocodigo, 
      analiticocodigo, asientocodigo, 
      detcomprobitem,
      monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo, cuentacodigo,
      detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
      detcomprobglosa, 
      detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe, detcomprobtipocambio, detcomprobruc,
      detcomprobauto, detcomprobformacambio, detcomprobajusteuser,plantillaasientoinafecto,detcomprobnlibro,detcomprobfecharef)
    select 
       cabcomprobmes,cabcomprobnumero,subasientocodigo, 
       analiticocodigo,asientocodigo,
       detcomprobitem=Replicate(''0'',5-len(@pend + id)) + rtrim(cast((@pend + id) as varchar(5))),
       monedacodigo,centrocostocodigo,documentocodigo, operacioncodigo,cuentacodigo,
       detcomprobnumdocumento,detcomprobfechaemision,detcomprobfechavencimiento,
       detcomprobglosa=''Asiento automatico'',
       debe,haber , usshaber, ussdebe, detcomprobtipocambio, detcomprobruc,
       detcomprobauto=1, detcomprobformacambio,detcomprobajusteuser,plantillaasientoinafecto,detcomprobnlibro,detcomprobfecharef
   from #tempo 
end'
exec(@sqlcad+@sqlcad2)
GO
