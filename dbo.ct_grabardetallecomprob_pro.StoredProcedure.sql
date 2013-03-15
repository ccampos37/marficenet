SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop PROCEDURE ct_grabardetallecomprob_pro
execute ct_grabardetallecomprob_pro 'campos2012','ct_detcomprob2012','01',3,1,'0103000003','0001','030'
*/
CREATE    PROCEDURE [ct_grabardetallecomprob_pro]
	(@base varchar(30),
         @tabla varchar(30),
	 @empresa varchar(2),
         @op int,
         @cabcomprobmes int	,
	 @cabcomprobnumero 	[char](10),
	 @subasientocodigo 	[char](4),
	 @asientocodigo 	[char](3),
	 @detcomprobitem 	[char](5)=null,
	 @analiticocodigo 	[char](15)=null, 	 
	 @monedacodigo 	[char](2)=null,
	 @centrocostocodigo 	[char](6)=null,
	 @documentocodigo 	[char](2)=null,
	 @operacioncodigo 	[char](2)=null,
	 @cuentacodigo 	[varchar](20)=null,
	 @detcomprobnumdocumento 	[Varchar](20)=null,
	 @detcomprobfechaemision 	[datetime]=null,
	 @detcomprobfechavencimiento 	[datetime]=null,
	 @detcomprobglosa 	[varchar](50)=null,
	 @detcomprobdebe 	[numvalor]=0,
	 @detcomprobhaber 	[numvalor]=0,
	 @detcomprobusshaber 	[numvalor]=0,
	 @detcomprobussdebe 	[numvalor]=0,
	 @detcomprobtipocambio 	[float]=0,
	 @detcomprobruc 	[char](13)=null,
	 @detcomprobauto 	[bit]=0,     
     @detcomprobformacambio char(2)=Null,
     @ctacteanaliticofechacontable datetime='01/01/2006', 
     @detcomprobajusteuser  bit=0,
     @plantillaasientoinafecto bit =0,
     @tipdocref  char(2)=null, 
     @detcomprobnumref varchar(20)=null,  
     @detcomprobnlibro varchar(10)=Null,   
     @detcomprobfecharef datetime=Null,
     @ctacteanaliticocancel bit=0
)
AS
DECLARE @sqlcad nvarchar(4000),@sqlparm nvarchar(1000)
--Pararametros de la cadena
SET @sqlparm=' @empresa varchar(2),@cabcomprobmes int,@cabcomprobnumero char(10),@subasientocodigo char(4),'+
	   		 '@analiticocodigo char(15),@asientocodigo char(3),@detcomprobitem char(5),'+
	 		 '@monedacodigo char(2),@centrocostocodigo char(5),@documentocodigo char(2),'+
	 		 '@operacioncodigo char(2),@cuentacodigo varchar(20),@detcomprobnumdocumento Varchar(20),'+
	 		 '@detcomprobfechaemision datetime,@detcomprobfechavencimiento datetime,@detcomprobglosa varchar(50),'+
	 		 '@detcomprobdebe numvalor,@detcomprobhaber numvalor,@detcomprobusshaber numvalor,'+
	 		 '@detcomprobussdebe numvalor,@detcomprobtipocambio float,@detcomprobruc char(13),'+
	 		 '@detcomprobauto bit,@detcomprobformacambio char(2),@ctacteanaliticofechacontable datetime ,
              @detcomprobajusteuser  bit,@plantillaasientoinafecto bit,
              @tipdocref char(2),@detcomprobnumref varchar(20),
              @detcomprobnlibro varchar(10),@detcomprobfecharef datetime,@ctacteanaliticocancel bit
               '
IF @op=1 --Insertar Datos
BEGIN
	SET @sqlcad=''+
	'INSERT INTO '+'['+@base+'].[dbo].['+@tabla+'] 
   (     [empresacodigo],
         [cabcomprobmes],
	 [cabcomprobnumero],
	 [subasientocodigo],
	 [analiticocodigo],
	 [asientocodigo],
	 [detcomprobitem],
	 [monedacodigo],
	 [centrocostocodigo],
	 [documentocodigo],
	 [operacioncodigo],
	 [cuentacodigo],
	 [detcomprobnumdocumento],
	 [detcomprobfechaemision],
	 [detcomprobfechavencimiento],
	 [detcomprobglosa],
	 [detcomprobdebe],
	 [detcomprobhaber],
	 [detcomprobusshaber],
	 [detcomprobussdebe],
	 [detcomprobtipocambio],
	 [detcomprobruc],
	 [detcomprobauto],
     [detcomprobformacambio],detcomprobajusteuser,
     plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobnlibro,detcomprobfecharef)  
VALUES 
	(@empresa,
	 @cabcomprobmes,
	 @cabcomprobnumero,
	 @subasientocodigo,
	 @analiticocodigo,
	 @asientocodigo,
	 @detcomprobitem,
	 @monedacodigo,
	 @centrocostocodigo,
	 @documentocodigo,
	 @operacioncodigo,
	 @cuentacodigo,
	 @detcomprobnumdocumento,
	 @detcomprobfechaemision,
	 @detcomprobfechavencimiento,
	 @detcomprobglosa,
	 @detcomprobdebe,
	 @detcomprobhaber,
	 @detcomprobusshaber,
	 @detcomprobussdebe,
	 @detcomprobtipocambio,
	 @detcomprobruc,
	 @detcomprobauto,@detcomprobformacambio,
     @detcomprobajusteuser,@plantillaasientoinafecto,@tipdocref,@detcomprobnumref,@detcomprobnlibro,@detcomprobfecharef)'
END
IF @op=2 --Eliminar
BEGIN
	SET @sqlcad=''+
  	'DELETE FROM '+'['+@base+'].[dbo].['+@tabla+'] '+		
	'WHERE 
	( [empresacodigo]	 = @empresa AND
          [cabcomprobmes]	 = @cabcomprobmes AND
	  [cabcomprobnumero]	 = @cabcomprobnumero AND
	  [subasientocodigo]	 = @subasientocodigo AND
	  [asientocodigo]	 = @asientocodigo )'
END
IF @op=3 --Recuperar los Datos
BEGIN
        SET @sqlcad=''+	
        'SELECT
	detcomprobitem,operacioncodigo,cuentacodigo,
        isnull(rtrim(centrocostocodigo),''00'') as centrocostocodigo,
	tipoanaliticocodigo=isnull(B.tipoanaliticocodigo,''00''),A.analiticocodigo,detcomprobruc,documentocodigo,
	detcomprobnumdocumento,detcomprobfechaemision,
	detcomprobfechavencimiento,detcomprobglosa,monedacodigo,
	tcambio =detcomprobformacambio,valcambio=detcomprobtipocambio,
	indicador=case when detcomprobdebe > 0 then ''D'' else ''H'' end,
	montosol = isnull((case when detcomprobdebe > 0 then detcomprobdebe 
             			else detcomprobhaber end),0),
	montouss = isnull((case when detcomprobussdebe > 0 then detcomprobussdebe
             			 else detcomprobusshaber end),0),detcomprobauto,detcomprobajusteuser,plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobnlibro,detcomprobfecharef
        FROM ['+@base+'].dbo.['+@tabla+']  A
           left join ['+@base+'].dbo.ct_analitico B   on A.analiticocodigo=B.analiticocodigo 
        WHERE A.empresacodigo=@empresa and
	A.cabcomprobmes=@cabcomprobmes and
	A.asientocodigo=@asientocodigo and
             A.subasientocodigo=@subasientocodigo and
	A.cabcomprobnumero=@cabcomprobnumero 
        order by A.cabcomprobmes,A.subasientocodigo,
             A.asientocodigo,A.cabcomprobnumero,A.detcomprobitem'	
END
if @op=4 
 Begin
		SET @sqlcad =N'UPDATE '+'['+@base+'].[dbo].['+@tabla+'] 
           	    SET empresacodigo=@empresa and
			cabcomprobmes=@cabcomprobmes,
			detcomprobitem=@detcomprobitem, 
			cabcomprobnumero=@cabcomprobnumero, 
			subasientocodigo=@subasientocodigo, 
			asientocodigo=@asientocodigo, 
			documentocodigo=@documentocodigo, 
			operacioncodigo=@operacioncodigo, 
			cuentacodigo=@cuentacodigo, 
  			ctacteanaliticofechaconta=@ctacteanaliticofechaconta, 
			analiticocodigo=@analiticocodigo, 
			ctacteanaliticonumdocumento=@ctacteanaliticonumdocumento, 
			ctacteanaliticofechadoc=@ctacteanaliticofechadoc, 
			ctacteanaliticoglosa=@ctacteanaliticoglosa, 
			ctacteanaliticodebe=@ctacteanaliticodebe, 
			ctacteanaliticoussdebe=@ctacteanaliticoussdebe, 
			ctacteanaliticohaber=@ctacteanaliticohaber, 
			ctacteanaliticousshaber=@ctacteanaliticousshaber, 
			ctacteanaliticocancel=@ctacteanaliticocancel, 
			ctacteanaliticofechaven=@ctacteanaliticofechaven,
			monedacodigo=@monedacodigo
			ctacteanaliticosaldo=@ctacteanaliticosaldo,
                        ctacteanaliticofechaconta=@ctacteanaliticofechacontable
            Where  cabcomprobnumero=@cabcomprobnumero and
                   empresacodigo=@empresa'
				
end
--print(@sqlcad)
---/*
Exec sp_executesql   @sqlcad,@sqlparm,
				   	 @empresa,
					 @cabcomprobmes,
					 @cabcomprobnumero,
					 @subasientocodigo,
					 @analiticocodigo,
					 @asientocodigo,
					 @detcomprobitem,
					 @monedacodigo,
					 @centrocostocodigo,
					 @documentocodigo,
					 @operacioncodigo,
					 @cuentacodigo,
					 @detcomprobnumdocumento,
					 @detcomprobfechaemision,
					 @detcomprobfechavencimiento,
					 @detcomprobglosa,
					 @detcomprobdebe,
					 @detcomprobhaber,
					 @detcomprobusshaber,
					 @detcomprobussdebe,		
					 @detcomprobtipocambio,
					 @detcomprobruc,
					 @detcomprobauto,@detcomprobformacambio,
					 @ctacteanaliticofechacontable,
					 @detcomprobajusteuser,@plantillaasientoinafecto,
					 @tipdocref,@detcomprobnumref,@detcomprobnlibro,
                     			 @detcomprobfecharef,
					 @ctacteanaliticocancel
--*/
SET QUOTED_IDENTIFIER OFF
GO
