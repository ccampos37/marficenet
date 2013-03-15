SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [vt_EMLB_RegVentas] 		/*EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente varchar(11)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 		b.pedidofechafact as Fecha_Emision, b.pedidotipofac as Cod_Documento,
		b.pedidonrofact as Comprobante,b.clienteruc as RUC,
		b.clientecodigo as Cod_Cliente,
	RAZON_SOCIAL = CASE 
		WHEN b.pedidofechaanu IS NULL THEN b.clienterazonsocial
		ELSE  ''A N U L A D O''
	END,
	TIPO_CAMBIO = CASE 
		WHEN b.pedidomoneda = ''02'' AND b.pedidofechaanu IS NULL THEN  ISNULL(c.tipocambioventa,0)
		ELSE 0
	END,
	IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = ''02'' AND b.pedidofechaanu IS NULL THEN b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0)
		ELSE 0        
	END,
	BASE_IMPONIBLE = CASE 
		WHEN b.pedidomoneda = ''01'' AND  b.pedidofechaanu IS NULL THEN (b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0))
		WHEN b.pedidomoneda = ''02'' AND  b.pedidofechaanu IS NULL THEN (isnull( (b.pedidototneto* ISNULL(c.tipocambioventa,0) ),0)-isnull((b.pedidototimpuesto*ISNULL(c.tipocambioventa,0)),0)-isnull((b.pedidototinafecto*ISNULL(c.tipocambioventa,0)),0))
		ELSE 0        
	END,
	INAFECTO = CASE 
		WHEN b.pedidomoneda = ''01'' AND b.pedidofechaanu IS NULL THEN isnull(b.pedidototinafecto,0)
		WHEN b.pedidomoneda = ''02'' AND b.pedidofechaanu IS NULL THEN isnull((b.pedidototinafecto*ISNULL(c.tipocambioventa,0)),0)
		ELSE 0        
	END,
	IMPUESTOS = CASE 
		WHEN b.pedidomoneda = ''01'' AND  b.pedidofechaanu IS NULL THEN isnull(b.pedidototimpuesto,0)
		WHEN b.pedidomoneda = ''02'' AND  b.pedidofechaanu IS NULL THEN isnull((b.pedidototimpuesto*ISNULL(c.tipocambioventa,0) ),0)
		ELSE 0        
	END,
	IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = ''01'' AND  b.pedidofechaanu IS NULL THEN b.pedidototneto
		WHEN b.pedidomoneda = ''02'' AND  b.pedidofechaanu IS NULL THEN isnull((b.pedidototneto*ISNULL(c.tipocambioventa,0) ),0)
		ELSE 0       
	END,
	PEDIDO	 = b.pedidonumero
FROM 	['+@base+'].dbo.vt_documento a 
	JOIN 
	['+@base+'].dbo.vt_pedido b
	ON  
	a.documentocodigo = b.pedidotipofac
	LEFT JOIN
	['+@base+'].dbo.ct_tipocambio c
	ON
	c.tipocambiofecha = b.pedidofechafact
WHERE	
	b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND LTRIM(RTRIM(b.clientecodigo)) LIKE ('''+@codcliente+''')
	AND a.documentoregventas = 1
ORDER BY 
	b.pedidonrofact '
exec (@sensql)
RETURN
GO
