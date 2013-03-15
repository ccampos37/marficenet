SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [vt_RepPrueba]
@bdatos nvarchar (50),
@codalmacen nvarchar(4),
@fecdesde datetime,
@fechasta datetime
as
DECLARE @SQLString NVARCHAR(1000)
DECLARE @WHERE NVARCHAR(500)
DECLARE @errores int  
DECLARE @COMP CHAR(1)
SET @WHERE  = null
SET @SQLString = N'SELECT ' +
		  'a.almacencodigo, d.almacendescripcion,' +
		  'e.documentocargo,' +
		  'a.pedidonrofact,a.pedidonumero,a.pedidofechafact,' +
	   	  'a.clientecodigo,a.clienterazonsocial,' +
		  'b.detpeditem,b.productocodigo,' +
		  'c.productodescripcion,' +
		  'b.detpedcantpedida,b.detpedimpbruto,' +
		  'b.detpedmontoimpto,b.detpedmontoprecvta' +
		  ' FROM ' +	
		  '['+@bdatos+'].dbo.vt_pedido a' +
		  ' JOIN ' +
		  '['+@bdatos+'].dbo.vt_detallepedido b' +
		  ' ON a.pedidonumero=b.pedidonumero' +	                  
		  ' JOIN '+
		  '['+@bdatos+'].dbo.vt_producto c' +
		  ' ON b.productocodigo=c.productocodigo ' +
		  ' JOIN '+
		  '['+@bdatos+'].dbo.vt_almacen d' +
		  ' ON a.almacencodigo=d.almacencodigo ' +
		  ' JOIN '+
		  '['+@bdatos+'].dbo.vt_cargo e' +
		  ' ON a.pedidonumero=e.cargonumdoc '
		 
SET @WHERE = 'WHERE NOT a.pedidonrofact=0  AND '
if @codalmacen <> null
	begin
	SET @WHERE = @WHERE +
	' a.almacencodigo=' + @codalmacen + ' AND '
	end
if @fecdesde <> null
	begin
	SET @WHERE = @WHERE +
	' a.pedidofechafact >=' + @fecdesde + ' AND '
	end
if @fechasta <> null
	begin
	SET @WHERE = @WHERE +
	' a.pedidofechafact<=' + @fechasta + ' AND '
	end
SET @WHERE = SUBSTRING(@WHERE,1,len(RTRIM(@WHERE)) - 5 )
SET @SQLString = @SQLString + @WHERE
EXEC(@SQLString)
--if (@@error <> 0 )
--     begin
GO
