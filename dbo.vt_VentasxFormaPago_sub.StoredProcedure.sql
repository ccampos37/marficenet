SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 execute vt_VentasxFormaPago_sub 'ziyaz','01','%%','30/09/2008','30/10/2008'

*/
CREATE   PROC [vt_VentasxFormaPago_sub]   	/*EN USO*/  
@base varchar(50),
@codpuntoventa varchar(2),
@codformapago varchar(2),  
@fecdesde varchar(10),  
@fechasta varchar(10) 
AS  
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	d.empresadescripcion,    pagodescripcion=pagodescripcion,b.formapagocodigo,c.formapagodescripcion,
	IMPORTES_DOLARES = CASE 
	WHEN b.pedidomoneda = ''02'' THEN SUM(isnull(f.pagoimporte,0))
--	WHEN b.pedidomoneda = ''02'' THEN SUM(isnull(a.tipodoc(a.documentotipo,f.pagoimporte) ,0) )
	ELSE 0
	END,
	IMPORTES_SOLES = CASE 
	WHEN b.pedidomoneda = ''01'' THEN SUM(isnull(f.pagoimporte,0))
	ELSE 0
	END  
FROM  ['+@base+'].dbo.vt_documento a   
inner JOIN ['+@base+'].dbo.vt_pedido b ON a.documentocodigo = b.pedidotipofac   
inner JOIN ['+@base+'].dbo.vt_formapago c ON c.formapagocodigo = b.formapagocodigo
inner JOIN ['+@base+'].dbo.co_multiempresas d ON b.empresacodigo = d.empresacodigo
inner JOIN  ['+@base+'].dbo.vt_pagosencaja f ON b.empresacodigo+b.pedidonumero = f.empresacodigo+f.pedidonumero
inner JOIN  ['+@base+'].dbo.vt_conceptosdepago g ON f.pagocodigo = g.pagocodigo

WHERE b.formapagocodigo LIKE ('''+@codformapago+''')
AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
AND isnull(b.pedidofechaanu,0)=0
and b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
GROUP BY   d.empresadescripcion,pagodescripcion,b.formapagocodigo,c.formapagodescripcion,b.pedidomoneda '

exec(@sensql)

RETURN
GO
