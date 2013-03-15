SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [vt_EDG_RepGFB]		/*EN USO*/
@base varchar(50),
@coddocumento varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codmoneda varchar(2),
@detalle char(1)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT	  	  a.documentocargo,a.cargonumdoc,a.cargoapefecemi,	
	   	  b.clientecodigo,b.clienterazonsocial,c.monedasimbolo ,
		  b.pedidototbruto,isnull(b.pedidototimpuesto,0) as Total_Impuesto,b.pedidototneto as Total_Neto
FROM 
		  ['+@base+'].dbo.vt_cargo a
		  JOIN 
		  ['+@base+'].dbo.vt_pedido b
		  ON (a.cargonumdoc = b.pedidonrofact  OR a.cargonumdoc = b.pedidonroboleta  OR a.cargonumdoc = b.pedidonrogiarem )
		  JOIN 
		  ['+@base+'].dbo.gr_moneda c
		  ON b.pedidomoneda = c.monedacodigo		 
WHERE 
		  a.documentocargo LIKE ('''+@coddocumento+''')
		  AND a.cargoapefecemi
		  BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
		  AND b.pedidomoneda LIKE ('''+@codmoneda+''')
		  AND b.pedidofechaanu IS NULL 
		  AND ISNULL (a.cargoapeflgcan,0) LIKE ('''+@detalle+''')
  		  	
ORDER BY
		  a.documentocargo , a.cargonumdoc '
exec (@sensql)
RETURN
GO
