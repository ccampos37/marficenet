SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_SubRegVentas] 		/* EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente nvarchar(11)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 		d.documentocodigo,d.documentodescripcion,
IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = 01 THEN 0
		WHEN b.pedidomoneda = 02 THEN SUM(b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0))
end,
AFECTO_IMPONIBLE = CASE 
		WHEN b.pedidomoneda = 01 THEN SUM((b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0)))
		WHEN b.pedidomoneda = 02 THEN SUM((isnull((b.pedidototneto*c.tipocambioventa),0)-isnull((b.pedidototimpuesto*c.tipocambioventa),0)-isnull((b.pedidototinafecto*c.tipocambioventa),0)))
end,
INAFECTO = CASE 
		WHEN b.pedidomoneda = 01 THEN SUM(isnull(b.pedidototinafecto,0))
		WHEN b.pedidomoneda = 02 THEN SUM(isnull((b.pedidototinafecto*c.tipocambioventa),0))
end,
IMPUESTOS = CASE 
		WHEN b.pedidomoneda = 01 THEN SUM(isnull(b.pedidototimpuesto,0))
		WHEN b.pedidomoneda = 02 THEN SUM(isnull((b.pedidototimpuesto*c.tipocambioventa),0))
end,
IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = 01 THEN SUM(b.pedidototneto)
		WHEN b.pedidomoneda = 02 THEN SUM(isnull((b.pedidototneto*c.tipocambioventa),0))
end
	
FROM 	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.vt_pedido b
	ON  
	(a.cargonumdoc = b.pedidonrofact 
	OR a.cargonumdoc = b.pedidonroboleta
	OR a.cargonumdoc = b.pedidonrogiarem)
	JOIN
	['+@base+'].dbo.ct_tipocambio c
	ON
	c.tipocambiofecha = a.cargoapefecemi
	JOIN
	['+@base+'].dbo.vt_documento d
	ON 
	documentocargo = d.documentocodigo
WHERE	
	a.cargoapefecemi 
	BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND a.clientecodigo LIKE ('''+@codcliente+''')
	AND b.pedidofechaanu IS NULL 
	AND d.documentoregventas = 1
GROUP BY
	d.documentocodigo,d.documentodescripcion,b.pedidomoneda '
exec (@sensql)
RETURN
GO
