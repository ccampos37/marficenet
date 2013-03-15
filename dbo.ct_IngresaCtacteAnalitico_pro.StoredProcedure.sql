SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop PROCEDURE ct_IngresaCtacteAnalitico_pro
*/
CREATE     PROCEDURE [ct_IngresaCtacteAnalitico_pro]
(    @base varchar(30),
     @tabla varchar(30),
     @op int,
     @empresa varchar(2),
     @cabcomprobmes int	,
	 @cabcomprobnumero 	[char](10),
	 @subasientocodigo 	[char](4),
	 @asientocodigo 	[char](3),
	 @detcomprobitem 	[char](5)=null,
	 @analiticocodigo 	[char](15)=null, 	 
	 @monedacodigo 	[char](2)=null,
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
     @ctacteanaliticocancel bit=0
)
AS
DECLARE @sqlcad nvarchar(4000),@sqlparm nvarchar(1000)
--Pararametros de la cadena
SET @sqlparm='@empresa varchar(2),@cabcomprobmes int,@cabcomprobnumero char(10),@subasientocodigo char(4),'+
	   		 '@analiticocodigo char(15),@asientocodigo char(3),@detcomprobitem char(5),'+
	 		 '@monedacodigo char(2),@documentocodigo char(2),'+
	 		 '@operacioncodigo char(2),@cuentacodigo varchar(20),@detcomprobnumdocumento Varchar(20),'+
	 		 '@detcomprobfechaemision datetime,@detcomprobfechavencimiento datetime,@detcomprobglosa varchar(50),'+
	 		 '@detcomprobdebe numvalor,@detcomprobhaber numvalor,@detcomprobusshaber numvalor,'+
	 		 '@detcomprobussdebe numvalor,@detcomprobtipocambio float,@detcomprobruc char(13),'+
	 		 '@detcomprobauto bit,@detcomprobformacambio char(2),
                          @ctacteanaliticofechacontable datetime, @ctacteanaliticocancel bit  '
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
	 [documentocodigo],
	 [operacioncodigo],
	 [cuentacodigo],
	 [ctacteanaliticonumdocumento],
	 [ctacteanaliticofechadoc],
	 [ctacteanaliticofechaven],
	 [ctacteanaliticoglosa],
	 [ctacteanaliticodebe],
	 [ctacteanaliticohaber],
	 [ctacteanaliticousshaber],
	 [ctacteanaliticoussdebe],
	 [ctacteanaliticofechaconta],
         [ctacteanaliticocancel] )
VALUES 
	(@empresa,
	 @cabcomprobmes,
	 @cabcomprobnumero,
	 @subasientocodigo,
	 @analiticocodigo,
	 @asientocodigo,
	 @detcomprobitem,
	 @monedacodigo,
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
	 @detcomprobussdebe ,
         @ctacteanaliticofechacontable, @ctacteanaliticocancel)'
END
if @op=2 
 Begin
		SET @sqlcad =N'UPDATE '+'['+@base+'].[dbo].['+@tabla+'] 
           	    SET cabcomprobmes=@cabcomprobmes,
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
            Where empresacodigo=empresa and 
                  cabcomprobnumero=@cabcomprobnumero '
				
end
Exec sp_executesql   @sqlcad,@sqlparm,   @empresa,
				   	 @cabcomprobmes,
					 @cabcomprobnumero,
					 @subasientocodigo,
					 @analiticocodigo,
					 @asientocodigo,
					 @detcomprobitem,
					 @monedacodigo,
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
					 @ctacteanaliticocancel 
SET QUOTED_IDENTIFIER OFF
GO
