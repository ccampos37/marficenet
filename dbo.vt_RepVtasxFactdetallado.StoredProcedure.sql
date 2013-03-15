SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [vt_RepVtasxFactdetallado] 'ZIYAZ','01','01/01/2008','01/01/2009','3.10','02'
CREATE  pROCEDURE [vt_RepVtasxFactdetallado]  /*EN USO*/  
@base varchar(50),  
@codalmacen varchar(4),  
@fecdesde varchar(10),  
@fechasta varchar(10),  
@tc decimal,
@moneda varchar(2)
AS  
  
DECLARE @sensql nvarchar (4000)  
SET @sensql = N'  
SELECT       a.almacencodigo, d.almacendescripcion,  
    a.pedidotipofac as Cod_Documento,  
    a.pedidonrofact as Numero_Fact,a.pedidonumero as Pedido,a.pedidofechafact as Fec_Emision,  
       a.clientecodigo,a.clienterazonsocial,  
    b.detpeditem,b.productocodigo,  
    c.adescri,  
    b.detpedcantpedida, isnull(b.detpedimpbruto,0) as Monto_Sin_Impto,  
    isnull(b.detpedmontoimpto,0)as Impuesto , b.detpedmontoprecvta as Monto_Neto,  
    e.monedasimbolo,g.formapagodescripcion  as FormaPago,a.pedidomoneda,
	monedadescripcion as Moneda   
  
FROM   
    ['+@base+'].dbo.vt_pedido a  
    JOIN   
    ['+@base+'].dbo.vt_detallepedido b  
    ON a.pedidonumero=b.pedidonumero  
    JOIN   
    ['+@base+'].dbo.maeart c  
    ON b.productocodigo = c.acodigo   
    JOIN  
    ['+@base+'].dbo.vt_almacen d  
    ON a.almacencodigo = d.almacencodigo   
    JOIN   
    ['+@base+'].dbo.gr_moneda e  
    ON a.pedidomoneda = e.monedacodigo  
      JOIN   
    ['+@base+'].dbo.vt_documento f  
    ON f.documentocodigo = a.pedidotipofac  
    JOIN ['+@base+'].dbo.vt_formapago g ON a.formapagocodigo = g.formapagocodigo
WHERE   
    a.almacencodigo LIKE ('''+@codalmacen+''')  
    AND a.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''  
       AND f.documentocodigo = ''01''     
    AND a.pedidofechaanu IS NULL
	and a.pedidomoneda like '''+@moneda+'''	
ORDER BY  a.almacencodigo,a.pedidonrofact,b.detpeditem '  
      
/*
    ['+@base+'].dbo.vt_producto c  
    ON b.productocodigo = c.productocodigo   
    AND a.almacencodigo = c.almacencodigo  

*/  
--print(@sensql)    
exec (@sensql)  
RETURN
GO
