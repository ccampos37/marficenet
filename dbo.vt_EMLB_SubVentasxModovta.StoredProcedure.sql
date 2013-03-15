SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--sp_helptext vt_EMLB_SubVentasxFormaPago
CREATE  PROC [vt_EMLB_SubVentasxModovta]   	/*EN USO*/  
@base varchar(50),
@codpuntoventa varchar(2),
@codmodovta varchar(2),  
@fecdesde varchar(10),  
@fechasta varchar(10) 
AS  
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	b.modovtacodigo,c.modovtadescripcion,
	IMPORTES_DOLARES = CASE 
	WHEN b.pedidomoneda = ''02'' THEN SUM(isnull( dbo.tipodoc(a.documentotipo,b.pedidototneto) ,0) )
	ELSE 0
	END,
	IMPORTES_SOLES = CASE 
	WHEN b.pedidomoneda = ''01'' THEN SUM(isnull( dbo.tipodoc(a.documentotipo,b.pedidototneto) ,0) )
	ELSE 0
	END  
FROM  
['+@base+'].dbo.vt_documento a   
JOIN   
['+@base+'].dbo.vt_pedido b  
ON    
  a.documentocodigo = b.pedidotipofac   
JOIN 
['+@base+'].dbo.vt_modoventa c
ON
  c.modovtacodigo = b.modovtacodigo
WHERE
b.modovtacodigo LIKE ('''+@codmodovta+''')
AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
AND b.pedidofechaanu IS NULL
and b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
GROUP BY   b.modovtacodigo,c.modovtadescripcion,b.pedidomoneda '
exec (@sensql)
RETURN
GO
