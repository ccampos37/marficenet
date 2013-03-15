SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_RegVentas] 		/*EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente varchar(11)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.cargoapefecemi as Fecha_Emision,a.documentocargo as Tipo_Documento,
	a.cargonumdoc as Comprobante,b.clienteruc as RUC,
	a.clientecodigo as Cod_Cliente,
RAZON_SOCIAL = CASE 
		WHEN b.pedidofechaanu IS NULL THEN b.clienterazonsocial
		ELSE  ''A N U L A D O''
end,
TIPO_CAMBIO = CASE 
		WHEN b.pedidomoneda = 02 AND b.pedidofechaanu IS NULL THEN c.tipocambioventa
		ELSE 0
end,
IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = 02 AND b.pedidofechaanu IS NULL THEN b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0)
		ELSE 0        
end,
BASE_IMPONIBLE = CASE 
		WHEN b.pedidomoneda = 01 AND  b.pedidofechaanu IS NULL THEN (b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0))
		WHEN b.pedidomoneda = 02 AND  b.pedidofechaanu IS NULL THEN (isnull((b.pedidototneto*c.tipocambioventa),0)-isnull((b.pedidototimpuesto*c.tipocambioventa),0)-isnull((b.pedidototinafecto*c.tipocambioventa),0))
		ELSE 0        
end,
INAFECTO = CASE 
		WHEN b.pedidomoneda = 01 AND b.pedidofechaanu IS NULL THEN isnull(b.pedidototinafecto,0)
		WHEN b.pedidomoneda = 02 AND b.pedidofechaanu IS NULL THEN isnull((b.pedidototinafecto*c.tipocambioventa),0)
		ELSE 0        
end,
IMPUESTOS = CASE 
		WHEN b.pedidomoneda = 01 AND  b.pedidofechaanu IS NULL THEN isnull(b.pedidototimpuesto,0)
		WHEN b.pedidomoneda = 02 AND  b.pedidofechaanu IS NULL THEN isnull((b.pedidototimpuesto*c.tipocambioventa),0)
		ELSE 0        
end,
IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = 01 AND  b.pedidofechaanu IS NULL THEN b.pedidototneto
		WHEN b.pedidomoneda = 02 AND  b.pedidofechaanu IS NULL THEN isnull((b.pedidototneto*c.tipocambioventa),0)
		ELSE 0       
end,
PEDIDO	 = CASE 
		WHEN b.pedidofechaanu IS NULL THEN b.pedidonumero
		ELSE  ''A N U L A D O''
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
	d.documentocodigo = a.documentocargo
WHERE	
	a.cargoapefecemi 
        BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND LTRIM(RTRIM(a.clientecodigo)) LIKE ('''+@codcliente+''')
	AND d.documentoregventas = 1
ORDER BY 
	a.cargonumdoc '
exec (@sensql)
RETURN
GO
