SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute vt_EMLB_SubRegVentas '01','planta_casma','%','01/01/2008','31/01/2008','%' 
CREATE  PROC [vt_EMLB_SubRegVentas] 		/* EN USO*/
@base varchar(50),
@empresa varchar(2),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente nvarchar(11)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 		d.documentocodigo,d.documentodescripcion,
	IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = ''01'' THEN 0
		WHEN b.pedidomoneda = ''02'' 
			THEN SUM ( dbo.tipodoc(d.documentotipo,b.pedidototneto) 
				- isnull( dbo.tipodoc(d.documentotipo,b.pedidototimpuesto) ,0) 
				- isnull( dbo.tipodoc(d.documentotipo,b.pedidototinafecto) ,0) )
	END,
	AFECTO_IMPONIBLE = CASE 
		WHEN b.pedidomoneda = ''01'' 
			THEN SUM( ( dbo.tipodoc(d.documentotipo,b.pedidototneto)
				-isnull( dbo.tipodoc(d.documentotipo,b.pedidototimpuesto) ,0)
				-isnull( dbo.tipodoc(d.documentotipo,b.pedidototinafecto),0)  	) )
		WHEN b.pedidomoneda = ''02'' 
			THEN SUM( (isnull( (dbo.tipodoc(d.documentotipo,b.pedidototneto) * ISNULL(c.tipocambioventa,0) ) ,0)
				-isnull( (dbo.tipodoc(d.documentotipo,b.pedidototimpuesto) * ISNULL(c.tipocambioventa,0) ) ,0)	
				-isnull( (dbo.tipodoc(d.documentotipo,b.pedidototinafecto) * ISNULL(c.tipocambioventa,0) ),0) ) )
	END,
	INAFECTO = CASE 
		WHEN b.pedidomoneda = ''01'' THEN SUM(isnull( dbo.tipodoc(d.documentotipo,b.pedidototinafecto) ,0) )
		WHEN b.pedidomoneda = ''02'' 
			THEN SUM(isnull( ( dbo.tipodoc(d.documentotipo,b.pedidototinafecto) * ISNULL(c.tipocambioventa,0) ) ,0) )
	END,
	IMPUESTOS = CASE 
		WHEN b.pedidomoneda = ''01'' THEN SUM(isnull(  dbo.tipodoc(d.documentotipo,b.pedidototimpuesto) ,0) )
		WHEN b.pedidomoneda = ''02'' 
			THEN SUM(isnull( (dbo.tipodoc(d.documentotipo,b.pedidototimpuesto) * ISNULL(c.tipocambioventa,0) ) ,0) )
	END,
	IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = ''01'' THEN SUM(  dbo.tipodoc(d.documentotipo,b.pedidototneto)  )
		WHEN b.pedidomoneda = ''02'' 
			THEN SUM(isnull(  (dbo.tipodoc(d.documentotipo,b.pedidototneto)*ISNULL(c.tipocambioventa,0) ) ,0) )
	END
FROM 	
	['+@base+'].dbo.vt_pedido b
	LEFT JOIN
	['+@base+'].dbo.ct_tipocambio c
	ON
	c.tipocambiofecha = b.pedidofechafact
	JOIN
	['+@base+'].dbo.vt_documento d
	ON 
	d.documentocodigo = b.pedidotipofac
WHERE	
	b.empresacodigo='''+@empresa+'''
        AND b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND LTRIM(RTRIM(b.clientecodigo)) LIKE ('''+@codcliente+''')
	AND b.pedidofechaanu IS NULL 
	AND d.documentoregventas = 1
GROUP BY
	d.documentocodigo,d.documentodescripcion,b.pedidomoneda '
EXEC (@sensql)
RETURN
GO
