SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [vt_VentasxFormaPago] 'ziyaz','02','%%','12/04/2009','12/04/2009'

*/


CREATE   PROC [vt_VentasxFormaPago]   
@base varchar(50),
@codpuntoventa varchar(2),
@codformapago varchar(2),  
@fecdesde varchar(10),  
@fechasta varchar(10) 
AS  
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT  e.empresadescripcion,
    tipocontado=case when pagotipocontado=''1'' then ''CONTADO'' ELSE ''CREDITO'' END,
    pagodescripcion=pagodescripcion,h.pagotipodescripcion,b.formapagocodigo,d.formapagodescripcion,
	b.pedidofechafact as Fecha_Emision,b.pedidotipofac as Cod_Documento,  
	b.pedidonrofact as Comprobante,b.clienteruc as RUC,  
	b.clientecodigo as Cod_Cliente,  
	b.clienterazonsocial,
	b.pedidonumero as Pedido,
IMPORTE_SOLES = CASE   
  WHEN b.pedidomoneda = ''01'' THEN isnull(f.pagoimporte,0) 
  ELSE 0          
end,  
IMPORTE_DOLARES = CASE   
  WHEN b.pedidomoneda = ''02'' THEN isnull(f.pagoimporte,0) 
  ELSE 0          
end,  
TIPO_CAMBIO = CASE   
  WHEN b.pedidomoneda = ''02'' THEN ISNULL(c.tipocambioventa,0)
  ELSE 0  
end,  
TOTAL_SOLES = CASE   
  WHEN b.pedidomoneda = ''01''  THEN f.pagoimporte  
  WHEN b.pedidomoneda = ''02''  THEN isnull((f.pagoimporte*ISNULL(c.tipocambioventa,0)),0)  
  ELSE 0         
end
  
FROM  ['+@base+'].dbo.vt_documento a   
inner JOIN ['+@base+'].dbo.vt_pedido b ON a.documentocodigo = b.pedidotipofac
LEFT JOIN  ['+@base+'].dbo.ct_tipocambio c ON c.tipocambiofecha = b.pedidofechafact 
left JOIN  ['+@base+'].dbo.vt_formapago d ON d.formapagocodigo = b.formapagocodigo
inner join ['+@base+'].dbo.co_multiempresas e ON b.empresacodigo = e.empresacodigo
inner JOIN  ['+@base+'].dbo.vt_pagosencaja f ON b.empresacodigo+b.pedidonumero = f.empresacodigo+f.pedidonumero
inner JOIN  ['+@base+'].dbo.vt_conceptosdepago g ON f.pagocodigo = g.pagocodigo
inner JOIN  ['+@base+'].dbo.vt_conceptostipodepago h ON f.pagocodigo +f.pagotipocodigo = h.pagocodigo+h.pagotipocodigo

WHERE b.formapagocodigo LIKE  ('''+@codformapago+''')
AND b.puntovtacodigo LIKE ('''+@codpuntoventa+''')
AND isnull(b.pedidofechaanu,0)=0
AND b.pedidofechasunat BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
ORDER BY   b.formapagocodigo , b.pedidonrofact'
exec (@sensql)
RETURN
GO
