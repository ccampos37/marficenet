SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop Proc ct_grabaautomatico_pro
EXECUTE ct_grabaautomatico_pro 'planta_casma','CT_DETCOMPROB2012','03','08','0808000005','080','0019',1


*/
CREATE         Proc [ct_grabaautomatico_pro]
(
@base varchar(50),
@tabla varchar(50),
@empresa varchar(2),
@mes  varchar(2), 
@comp varchar(10),
@asiento varchar(3) ,
@subasiento varchar(4),
@tipo char(1)='1'
)
as
DECLARE @sqlcad varchar(8000),@sqlcad2 varchar(8000),@sqlcad3 varchar(8000),@sqlcad4 varchar(8000), @sqlparm nvarchar(1000)
declare @autoxccosto char(1),@autoxccosto1 char(1)
--Pararametros de la cadena

set @sqlcad=' If Exists(Select name from tempdb..sysobjects where name=''##tempo'') 
    Drop Table [##tempo] 
 	  SELECT a.empresacodigo,
       A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo, 
       A.analiticocodigo,A.asientocodigo,detcomprobitem=''00000'',
       A.monedacodigo,A.centrocostocodigo,A.documentocodigo,
       A.operacioncodigo,
       cuentacodigo=cuentadistribucion,
       A.detcomprobnumdocumento,A.detcomprobfechaemision,A.detcomprobfechavencimiento,
       A.detcomprobglosa,
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
      INTO ##tempo
FROM  ['+@base+'].dbo.['+@tabla+'] A
      inner join ['+@base+'].dbo.ct_cuenta b 
          on  a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
      inner join '
set @sqlcad3=' (select empresacodigo,cuentacodigo,indicador=''D'',cuentadistribucion=distribucioncargo,distribucionporcen 
                from ['+@base+'].dbo.ct_distribucion 
            where NOT (rtrim(distribucioncargo)='''' or 
                  distribucioncargo is null) and empresacodigo='''+@empresa+'''
             Union all
            select empresacodigo,cuentacodigo,indicador=''H'',cuentadistribucion=distribucionabono,distribucionporcen 
            from ['+@base+'].dbo.ct_distribucion 
            where NOT (rtrim(distribucionabono)='''' or 
                 distribucionabono is null) and empresacodigo='''+@empresa+'''  ) as C           
         on  b.empresacodigo=c.empresacodigo and b.cuentacodigo = c.cuentacodigo   
         WHERE  a.empresacodigo='''+@empresa+''' and '
set @sqlcad4=' (select empresacodigo='''+@empresa+''',centrocostocodigo,indicador=''D'',cuentadistribucion=cuentacodigo,
                    distribucionporcen=100  from ['+@base+'].dbo.ct_centrocosto 
                     where empresacodigo='''+@empresa+''' and len(rtrim(cuentacodigo))>0
                     union all
                     select empresacodigo='''+@empresa+''',centrocostocodigo,indicador=''H'',cuentadistribucion=''7911100'',
                    distribucionporcen=100  from ['+@base+'].dbo.ct_centrocosto 
                     where empresacodigo='''+@empresa+''' and len(rtrim(cuentacodigo))>0
                   ) as C on b.empresacodigo=c.empresacodigo and a.centrocostocodigo = c.centrocostocodigo 
                where a.empresacodigo='''+@empresa+''' and  '
if @tipo<>'1' set @sqlcad=@sqlcad+@sqlcad3
if @tipo='1' set @sqlcad=@sqlcad+@sqlcad4
                     
if @tipo<>'1' set @sqlcad=@sqlcad+' B.cuentaestadodistribucion=1 and '
if @tipo='1' set @sqlcad=@sqlcad+' B.cuentaestadoccostos=1 and '
set @sqlcad=@sqlcad+' A.cabcomprobmes='+@mes+' and  
        A.cabcomprobnumero='''+@comp+''' and
        A.asientocodigo='''+@asiento+''' and
    	A.subasientocodigo='''+@subasiento+'''
        order by A.cabcomprobnumero,c.indicador ' 
 
set @sqlcad2= '

if @@rowcount > 0 
Begin   
   declare @pend int
   select @pend=isnull(max(detcomprobitem),0) from ['+@base+'].dbo.['+@tabla+']
   where  empresacodigo='''+@empresa+''' and cabcomprobmes='+@mes+' and  cabcomprobnumero='''+@comp+''' and  
            asientocodigo='''+@asiento+''' and  subasientocodigo='''+@subasiento+'''      
 insert into ['+@base+'].dbo.['+@tabla+']
   (  empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, 
      analiticocodigo, asientocodigo, 
      detcomprobitem,
      monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo, cuentacodigo,
      detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
      detcomprobglosa, 
      detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe, detcomprobtipocambio, detcomprobruc,
      detcomprobauto, detcomprobformacambio, detcomprobajusteuser,plantillaasientoinafecto,detcomprobnlibro,detcomprobfecharef)
    select 
       empresacodigo,cabcomprobmes,cabcomprobnumero,subasientocodigo, 
       analiticocodigo,asientocodigo,
       detcomprobitem=Replicate(''0'',5-len(@pend + id)) + rtrim(cast((@pend + id) as varchar(5))),
       monedacodigo,centrocostocodigo,documentocodigo, operacioncodigo,cuentacodigo,
       detcomprobnumdocumento,detcomprobfechaemision,detcomprobfechavencimiento,
       detcomprobglosa,
       debe,haber , usshaber, ussdebe, detcomprobtipocambio, detcomprobruc,
       detcomprobauto=1, detcomprobformacambio,detcomprobajusteuser,plantillaasientoinafecto,detcomprobnlibro,detcomprobfecharef
   from ##tempo 
end'

execute(@sqlcad+@sqlcad2)
GO
