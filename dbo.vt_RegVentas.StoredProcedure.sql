SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute vt_RegVentas 'ziyaz','02','%%','01/01/2010','31/01/2010','%%','%%'
select * from desarrollo.dbo.vt_pedido

*/
CREATE                PROC [vt_RegVentas] 		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@cliente varchar(11),
@moneda varchar(2)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 		b.pedidofechafact as Fecha_Emision, b.pedidotipofac as Cod_Documento,
		b.pedidonrofact as Comprobante,b.clienteruc as RUC,
		b.clientecodigo as Cod_Cliente,A.documentodescripcion,puntovtadescripcion,
	RAZON_SOCIAL = CASE 
		WHEN isnull(b.estadoreg,0)=0  THEN b.clienterazonsocial
		ELSE  ''A N U L A D O''
	END,
	TIPO_CAMBIO = CASE 
		WHEN b.pedidomoneda = ''02'' AND isnull(b.estadoreg,0)=0 THEN  ISNULL(c.tipocambioventa,0)
		ELSE 0
	END,
	IMPORTE_DOLARES = CASE 
		WHEN b.pedidomoneda = ''02'' AND isnull(b.estadoreg,0)=0 and b.pedidotipofac <>''07''THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0)
		WHEN b.pedidomoneda = ''02'' AND isnull(b.estadoreg,0)=0 and b.pedidotipofac =''07''THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		b.pedidototneto+isnull(b.pedidototimpuesto,0)+isnull(b.pedidototinafecto,0)
		ELSE 0       
	END,
	BASE_IMPONIBLE = CASE 
		WHEN b.pedidomoneda = ''01'' AND  isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		(b.pedidototneto-isnull(b.pedidototimpuesto,0)-isnull(b.pedidototinafecto,0)) 
		WHEN b.pedidomoneda = ''02'' AND isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		(isnull( (b.pedidototneto* ISNULL(c.tipocambioventa,0) ),0)-isnull((b.pedidototimpuesto*ISNULL(c.tipocambioventa,0)),0)-isnull((b.pedidototinafecto*ISNULL(c.tipocambioventa,0)),0))
		ELSE 0        
	END,
	INAFECTO = CASE 
		WHEN b.pedidomoneda = ''01'' AND isnull(b.estadoreg,0)=0 THEN isnull(b.pedidototinafecto,0)
		WHEN b.pedidomoneda = ''02'' AND isnull(b.estadoreg,0)=0 THEN isnull((b.pedidototinafecto*ISNULL(c.tipocambioventa,0)),0)
		ELSE 0        
	END,
	IMPUESTOS = CASE 
		WHEN b.pedidomoneda = ''01'' AND  isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		isnull(b.pedidototimpuesto,0)
		WHEN b.pedidomoneda = ''02'' AND  isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		isnull((b.pedidototimpuesto*ISNULL(c.tipocambioventa,0) ),0)
		ELSE 0        
	END,
	IMPORTE_SOLES = CASE 
		WHEN b.pedidomoneda = ''01'' AND  isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		b.pedidototneto 
		WHEN b.pedidomoneda = ''02'' AND  isnull(b.estadoreg,0)=0 THEN 
		(Case When upper(e.documentotipo)=''A'' then -1 else 1 end)*
		isnull((b.pedidototneto*ISNULL(c.tipocambioventa,0) ),0)
		ELSE 0       
	END,
	PEDIDO	 = b.pedidonumero,cp.pagodescripcion
FROM 	['+@base+'].dbo.vt_documento a 
	INNER JOIN ['+@base+'].dbo.vt_pedido b ON a.documentocodigo = b.pedidotipofac
	LEFT JOIN ['+@base+'].dbo.ct_tipocambio c ON c.tipocambiofecha = b.pedidofechafact
	left JOIN ['+@base+'].dbo.vt_puntoventa d ON b.puntovtacodigo = d.puntovtacodigo
	left JOIN ['+@base+'].dbo.vt_documento e on b.pedidotipofac=e.documentocodigo 
	left join ['+@base+'].dbo.vt_conceptosdepago cp on cp.pagocodigo=b.formapagocodigo 
WHERE	b.empresacodigo ='''+@empresa+'''
    AND b.clientecodigo LIKE '''+@cliente+''' 
	AND b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
	AND a.documentoregventas = 1 and b.pedidomoneda like '''+@moneda+'''
ORDER BY b.pedidotipofac,b.pedidonrofact '

execute (@sensql)
-- select * from ziyaz.dbo.vt_conceptosdepago
GO
