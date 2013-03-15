SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute vt_rankingnegocioxmes 'tabor','01','01/01/2007','31/12/2007'
CREATE   PROCEDURE [vt_rankingnegocioxmes]  /*EN USO*/    
@base varchar(50),    
@codalmacen varchar(2),    
@fecdesde varchar(10),    
@fechasta varchar(10)   
    
AS    
    
DECLARE @sensql nvarchar (4000)    
SET @sensql = N'    
SELECT       a.almacencodigo, d.almacendescripcion,   
    c.afamilia,fam_nombre,i.negociodescripcion, 
    b.productocodigo,    
    productodescripcion=c.adescri,    
    a.pedidofechafact as Fec_Emision,a.pedidonumero as Pedido,    
       a.pedidonrofact as Comprobante, a.pedidotipofac as Cod_Documento,    
    b.detpedcantpedida,    
    b.detpedmontoimpto  as Monto ,    
    a.clientecodigo,a.clienterazonsocial,    
    f.monedasimbolo ,x=rtrim(str(year(a.pedidofechafact)))+''-''+right(''00''+ltrim(str(month(a.pedidofechafact))),2)
FROM     
    ['+@base+'].dbo.vt_pedido a  
    inner JOIN ['+@base+'].dbo.vt_detallepedido b on a.pedidonumero=b.pedidonumero     
    inner JOIN ['+@base+'].dbo.MAEART c ON b.productocodigo=c.acodigo    
    inner JOIN ['+@base+'].dbo.vt_almacen d ON a.almacencodigo=d.almacencodigo    
    inner JOIN ['+@base+'].dbo.vt_documento e ON a.pedidotipofac=e.documentocodigo    
    inner JOIN ['+@base+'].dbo.gr_moneda f ON a.pedidomoneda = f.monedacodigo
    inner JOIN ['+@base+'].dbo.familia g ON c.afamilia = g.fam_codigo
    inner join ['+@base+'].dbo.vt_cliente h ON a.clientecodigo = h.clientecodigo
    inner join ['+@base+'].dbo.vt_negocio i ON h.negociocodigo = i.negociocodigo
WHERE     
    LTRIM(RTRIM(a.puntovtacodigo)) LIKE ('''+@codalmacen+''')      
    AND a.pedidofechafact    
    BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''    
    AND a.pedidofechaanu IS NULL   
ORDER BY a.almacencodigo,c.productodescripcion,b.productocodigo,a.pedidotipofac,a.pedidonrofact '    
    
    
exec (@sensql)    
--- EXECUTE vt_RepVtasxArt 'gremco','05','01/01/2007','31/12/2007','%%'
GO
