SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [vt_listaproducto_pro]
@base varchar(50),
@almacen varchar(2)
as
Declare @cadena nvarchar(4000)
Declare @parame nvarchar(4000)
Declare @valor char(1)
Declare @dato char(1)
Declare @ref char(1)
Declare @usua varchar(8)
Declare @fecha char(10)
set @valor='0'
set @dato='1'
set @ref='REF'
set @usua='elozano'
set @fecha='06/09/2002'
set @cadena=N'SELECT DISTINCT
		ARTI.ART_KEY as productocodigo,
		ARTI.ART_NOMBRE as productodescripcion,
		left(ARTI.ART_NOMBRE,30) as productodescrcorta,
		ARTI.ART_LINEA as grupovtacodigo,
		ARTI.ART_FAMILIA as productofamiliacodigo,
		ARTI.ART_SUBFAM as productocategoriacodigo,
		ARTI.ART_TIPO as productotipo,
		ARTI.ART_UNIDAD as unidadcodigo,
		@valor as productoporcimpto,
		@valor as productoestunidreferencia,
		@ref as unidadreferencial,
		@dato as unidadfactorconv,
		PRECIOS.PRE_EQUIV as productoprecvta,
		ARTI.ART_MONEDA as monedacodigo,
		@ref as usuariocodigo,
		@fecha as fechaact,
		ARTI.ART_CODCIA as almacencodigo
		From 
		['+@base+'].dbo.ARTI ARTI INNER JOIN ['+@base+'].dbo.ARTICULO ARTICULO ON 
		  ARTI.ART_KEY = ARTICULO.ARM_CODART AND ARTI.ART_CODCIA = ARTICULO.ARM_CODCIA 
		  INNER JOIN ['+@base+'].dbo.PRECIOS PRECIOS ON  ARTI.ART_CODCIA = PRECIOS.PRE_CODCIA AND 
		  ARTI.ART_KEY = PRECIOS.PRE_CODART 
                --GROUP BY 
		--ARTI.ART_KEY,
		--ARTI.ART_NOMBRE,
		--ARTI.ART_CODCIA,
		--ARTI.ART_LINEA,
		--ARTI.ART_FAMILIA,
		--ARTI.ART_SUBFAM,
		--ARTI.ART_TIPO,
		--ARTI.ART_UNIDAD,
		--PRECIOS.PRE_EQUIV,
		--ARTI.ART_MONEDA
                WHERE ARTI.ART_CODCIA LIKE @ALMACEN
		ORDER BY
		ARTI.ART_KEY,
		ARTI.ART_NOMBRE,
		ARTI.ART_CODCIA,
		ARTI.ART_LINEA,
		ARTI.ART_FAMILIA,
		ARTI.ART_SUBFAM,
		ARTI.ART_TIPO,
		ARTI.ART_UNIDAD,
		PRECIOS.PRE_EQUIV,
		ARTI.ART_MONEDA'
set @parame=N'@valor char(1),@dato char(1),@ref char(1),@usua varchar(8),@fecha char(10),@almacen varchar(2)'
execute sp_executesql @cadena,@parame,@valor,@dato,@ref,@usua,@fecha,@almacen
GO
