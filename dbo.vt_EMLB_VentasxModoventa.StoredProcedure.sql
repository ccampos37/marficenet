SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   PROC [vt_EMLB_VentasxModoventa]   	/*EN USO*/  
@base varchar(50),
@codpuntoventa varchar(2),
@codmodovta varchar(2),  
@fecdesde varchar(10),  
@fechasta varchar(10) 
AS  
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT  b.modovtacodigo,d.modovtadescripcion,b.pedidototitem,
	b.pedidofechafact as Fecha_Emision,b.pedidotipofac as Cod_Documento,  
	b.pedidonrofact as Comprobante,b.clienteruc as RUC,  
	b.clientecodigo as Cod_Cliente,  
	b.clienterazonsocial,
	b.pedidonumero as Pedido,
IMPORTE_SOLES = CASE   
  WHEN b.pedidomoneda = ''01'' THEN isnull(b.pedidototneto,0) 
  ELSE 0          
end,  
IMPORTE_DOLARES = CASE   
  WHEN b.pedidomoneda = ''02'' THEN isnull(b.pedidototneto,0) 
  ELSE 0          
end,  
TIPO_CAMBIO = CASE   
  WHEN b.pedidomoneda = ''02'' THEN ISNULL(c.tipocambioventa,0)
  ELSE 0  
end,  
TOTAL_SOLES = CASE   
  WHEN b.pedidomoneda = ''01''  THEN b.pedidototneto  
  WHEN b.pedidomoneda = ''02''  THEN isnull((b.pedidototneto*ISNULL(c.tipocambioventa,0)),0)  
  ELSE 0         
end
  
FROM  
['+@base+'].dbo.vt_documento a   
JOIN   
['+@base+'].dbo.vt_pedido b  
ON    
  a.documentocodigo = b.pedidotipofac
LEFT JOIN  
['+@base+'].dbo.ct_tipocambio c  
ON  
  c.tipocambiofecha = b.pedidofechafact 
JOIN 
['+@base+'].dbo.vt_modoventa d
ON
 d.modovtacodigo = b.modovtacodigo
WHERE
b.modovtacodigo LIKE  ('''+@codmodovta+''')
AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
AND b.pedidofechaanu IS NULL
AND b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
ORDER BY   
b.modovtacodigo , b.pedidonrofact'
exec (@sensql)
RETURN
GO
