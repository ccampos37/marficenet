SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [vt_EDG_RepVtasxArt]		/*EN USO*/
@base varchar(50),
@codalmacen varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codarticulo varchar(20)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	  	 a.almacencodigo, d.almacendescripcion,
		  b.productocodigo,
		  c.productodescripcion,
		  a.pedidofecha,a.pedidonumero,
	   	  e.cargonumdoc,e.documentocargo,
		  b.detpedcantpedida,
		  b.detpedmontoimpto,
		  a.clientecodigo,a.clienterazonsocial,
		  f.monedasimbolo
FROM 
		  ['+@base+'].dbo.vt_pedido a
		  JOIN
		  ['+@base+'].dbo.vt_detallepedido b
		  ON a.pedidonumero=b.pedidonumero 
		  JOIN 
		  ['+@base+'].dbo.vt_almacen d
		  ON a.almacencodigo=d.almacencodigo
		  JOIN 	
		  ['+@base+'].dbo.vt_producto c 
		  ON b.productocodigo=c.productocodigo
		  AND a.almacencodigo = c.almacencodigo
		  JOIN
		  ['+@base+'].dbo.vt_cargo e
		  ON (a.pedidonrofact=e.cargonumdoc  OR
		      a.pedidonroboleta=e.cargonumdoc  OR
		      a.pedidonrogiarem=e.cargonumdoc)
		  JOIN 	
		  ['+@base+'].dbo.gr_moneda f 
		  ON a.pedidomoneda = f.monedacodigo
WHERE 
		  a.almacencodigo LIKE ('''+@codalmacen+''') 	
		  AND LTRIM(RTRIM(b.productocodigo)) LIKE ('''+@codarticulo+''')
		  AND e.cargoapefecemi
		  BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
		  AND a.pedidofechaanu IS NULL '
exec (@sensql)
RETURN
GO
