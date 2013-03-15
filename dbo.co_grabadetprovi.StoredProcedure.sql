SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--drop proc co_grabadetprovi	
CREATE     proc [co_grabadetprovi]		
(	 @base varchar(30),
     @tabla varchar(30),
     @op int,
        @empresa	    varchar(2),
	@cabproviano      varchar(4)=null,
	@cabprovinumero 	bigint=Null,
	@cabprovimes 	    varchar(2)=Null,
	@detproviitem 	    varchar(3)=Null,
	@detprovicod1 	    varchar(2)=Null,
	@detprovicod2 	    varchar(2)=Null,
	@detprovicod3 		varchar(2)=Null,
	@detprovicod4 		varchar(2)=Null,
	@gastoscodigo 		varchar(20)=Null,
	@cuentacodigo 		varchar(20)=Null,
	@detprovimon 		varchar(2)=Null,
	@detproviestado 	varchar(1)=Null,
	@detproviimpbru 	numvalor=0,
	@detproviimpigv 	numvalor=0,
	@detproviimpina 	numvalor=0,
	@detprovitotal 	numvalor=0,
	@detprovidscto 	numvalor=0,
	@detproviimpdct 	numvalor=0,
	@detproviimpven 	numvalor=0,
	@detproviigv 	    numvalor=0,
	@detproviformcamb 	varchar(2)=Null,
	@detprovitipcam 	numvalor=0,
	@usuariocodigo 	usuariocodigo=Null,
	@fechaact 	        fechaact=Null, 
        @detproviglosa     varchar(100)=Null,
        @detproviccosto    varchar(10)=Null,
        @analitico         varchar(11)=Null)
AS 
DECLARE @sqlcad nvarchar(4000),@sqlparm nvarchar(2000)
--Pararametros de la cadena
SET @sqlparm='@cabprovinumero bigint,
              @empresa	     varchar(2),
	      @cabproviano varchar(4),
	      @cabprovimes varchar(2),
              @detproviitem  varchar(3),
              @detprovicod1 varchar(2),
              @detprovicod2 varchar(2),
              @detprovicod3 varchar(2),
	      @detprovicod4 varchar(2),
              @gastoscodigo varchar(20),
              @cuentacodigo varchar(20),
              @detprovimon varchar(2),
	      @detproviestado varchar(1),
              @detproviimpbru numvalor,
              @detproviimpigv numvalor,
	      @detproviimpina numvalor,
              @detprovitotal numvalor,
              @detprovidscto numvalor,
	      @detproviimpdct numvalor,
              @detproviimpven numvalor,
              @detproviigv  numvalor,
	      @detproviformcamb varchar(2),
              @detprovitipcam numvalor,
              @usuariocodigo usuariocodigo,
              @fechaact fechaact,
              @detproviglosa  varchar(100),
              @detproviccosto varchar(10),
              @analitico   varchar(11) '
IF @op=1 --Insertar Datos
BEGIN	
	SET @sqlcad=''+
	'INSERT INTO '+'['+@base+'].[dbo].['+@tabla+'] 
		 ( [cabprovinumero],
		 [empresacodigo],
		 [cabproviano],
		 [cabprovimes],
		 [detproviitem],
		 [detprovicod1],
		 [detprovicod2],
		 [detprovicod3],
		 [detprovicod4],
		 [gastoscodigo],
		 [cuentacodigo],
		 [detprovimon],
		 [detproviestado],
		 [detproviimpbru],
		 [detproviimpigv],
		 [detproviimpina],
		 [detprovitotal],
		 [detprovidscto],
		 [detproviimpdct],
		 [detproviimpven],
		 [detproviigv],
		 [detproviformcamb],
		 [detprovitipcam],
		 [usuariocodigo],
		 [fechaact],
                 [detproviglosa],
                 [centrocostocodigo],
                 [entidadcodigo] ) 
	 
	VALUES 
		( @cabprovinumero,
		 @empresa,
		 @cabproviano,
		 @cabprovimes,
		 @detproviitem,
		 @detprovicod1,
		 @detprovicod2,
		 @detprovicod3,
		 @detprovicod4,
		 @gastoscodigo,
                 @cuentacodigo,
		 @detprovimon,
		 @detproviestado,
		 @detproviimpbru,
		 @detproviimpigv,
		 @detproviimpina,
		 @detprovitotal,
		 @detprovidscto,
		 @detproviimpdct,
		 @detproviimpven,
		 @detproviigv,
		 @detproviformcamb,
		 @detprovitipcam,
		 @usuariocodigo,
		 @fechaact,
                 @detproviglosa,
                 @detproviccosto,
                 @analitico )'
END
IF @op=2 --Eliminar
BEGIN
	SET @sqlcad=''+	
	'DELETE '+'['+@base+'].[dbo].['+@tabla+'] 
		WHERE 
		( [cabprovinumero]	 = @cabprovinumero ) '
END
IF @op=3 --Recuperar los Datos
BEGIN
        SET @sqlcad='Select Item=detproviitem,
                     cuentacodigo=Cuentacodigo,
                     gastoscodigo=gastoscodigo,
                     ImpBruto=detproviimpbru,
                     Igv=detproviimpigv,
                     Inafecto=detproviimpina,
                     ImpCompra=detprovitotal, 
                     glosa=isnull(detproviglosa,''''), 
                     ccosto=centrocostocodigo,
                     analitico=entidadcodigo
                FROM ['+@base+'].dbo.['+@tabla+']  
                WHERE ( [cabproviano] = @cabproviano and [cabprovinumero] = @cabprovinumero ) '
   
END
exec sp_executesql @sqlcad,@sqlparm,
                 @cabprovinumero,
                 @empresa,
		 @cabproviano,
		 @cabprovimes,
		 @detproviitem,
		 @detprovicod1,
		 @detprovicod2,
		 @detprovicod3,
		 @detprovicod4,
		 @gastoscodigo,
		 @cuentacodigo,
		 @detprovimon,
		 @detproviestado,
		 @detproviimpbru,
		 @detproviimpigv,
		 @detproviimpina,
		 @detprovitotal,
		 @detprovidscto,
		 @detproviimpdct,
		 @detproviimpven,
		 @detproviigv,
		 @detproviformcamb,
		 @detprovitipcam,
		 @usuariocodigo,
		 @fechaact,
                 @detproviglosa,
                 @detproviccosto,
                 @analitico
---execute co_grabadetprovi 'aqplaya_prueba','co_detprovi2006',542,'2',2
GO
