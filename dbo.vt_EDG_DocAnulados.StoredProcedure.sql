SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_DocAnulados] 		/*EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.cargoapefecemi as Fecha_Emision,a.documentocargo as Tipo_Documento,
	a.cargonumdoc as Comprobante,b.clienteruc as RUC,
	a.clientecodigo as Cod_Cliente,
	b.clienterazonsocial,
	b.pedidonumero,
TIPO_CAMBIO = CASE 
		WHEN b.pedidomoneda = 02  THEN c.tipocambioventa
		ELSE 0
end,
IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = 01  THEN isnull(b.pedidototneto,0)
		ELSE 0        
end,
IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = 02  THEN isnull(b.pedidototneto,0)
		ELSE 0        
end,
TOTAL_SOLES = CASE 
		WHEN b.pedidomoneda = 01 THEN b.pedidototneto
		WHEN b.pedidomoneda = 02 THEN isnull((b.pedidototneto*c.tipocambioventa),0)
		ELSE 0       
end
FROM 	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.vt_pedido b
	ON  
	(a.cargonumdoc = b.pedidonrofact 
	OR a.cargonumdoc = b.pedidonroboleta)
	JOIN
	['+@base+'].dbo.ct_tipocambio c
	ON
	c.tipocambiofecha = a.cargoapefecemi
WHERE	
	a.cargoapefecemi 
	BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND b.pedidofechaanu IS NOT NULL
ORDER BY 
	a.cargonumdoc '
exec (@sensql)
RETURN
GO
