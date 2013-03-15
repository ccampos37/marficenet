SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [vt_EDG_RepVtasxFact]		/*EN USO*/
@base varchar(50),
@codalmacen varchar(4),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	  	 a.almacencodigo, d.almacendescripcion,
		  e.documentocargo,
		  a.pedidonrofact,a.pedidonumero,e.cargoapefecemi,
	   	  a.clientecodigo,a.clienterazonsocial,
		  b.detpeditem,b.productocodigo,
		  c.productodescripcion,
		  b.detpedcantpedida,b.detpedmontoimpto-isnull(b.detpedmontodsctoxprom,0) as Monto_Sin_Impto,
		  isnull(b.detpedmontodsctoxprom,0)as Impuesto,b.detpedmontoimpto,
		  f.monedasimbolo 
FROM 
		  ['+@base+'].dbo.vt_pedido a
		  JOIN 
		  ['+@base+'].dbo.vt_detallepedido b
		  ON a.pedidonumero=b.pedidonumero
		  JOIN 
		  ['+@base+'].dbo.vt_producto c
		  ON b.productocodigo=c.productocodigo 
		  AND a.almacencodigo = c.almacencodigo
		  JOIN
		  ['+@base+'].dbo.vt_almacen d
		  ON a.almacencodigo=d.almacencodigo 
		  JOIN 
		  ['+@base+'].dbo.vt_cargo e
		  ON a.pedidonrofact=e.cargonumdoc
		  JOIN 
		  ['+@base+'].dbo.gr_moneda f
		  ON a.pedidomoneda=f.monedacodigo
		 
WHERE 
		  a.almacencodigo LIKE ('''+@codalmacen+''')
		  AND e.cargoapefecemi 
		  BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
		  AND a.pedidofechaanu IS NULL '  
exec (@sensql)
RETURN
GO
