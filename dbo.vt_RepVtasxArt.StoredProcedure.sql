SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [vt_RepVtasxArt] 'ziyaz' , '03','%%','102344','01/06/2009','14/06/2009' 

*/

CREATE     PROCEDURE [vt_RepVtasxArt]  /*EN USO*/    
@base varchar(50),    
@empresa varchar(2),
@codalmacen varchar(2),    
@codproducto varchar(20),    
@fecdesde varchar(10),    
@fechasta varchar(10)   
    
AS    
    
DECLARE @sensql nvarchar (4000)    
SET @sensql = N'    
SELECT       a.almacencodigo, almacendescripcion=d.tadescri,   
    c.afamilia,fam_nombre, 
    b.productocodigo,    
    productodescripcion=c.adescri,    
    a.pedidofechafact as Fec_Emision,a.pedidonumero as Pedido,    
       a.pedidonrofact as Comprobante, a.pedidotipofac as Cod_Documento,    
    b.detpedcantpedida,    
    dbo.tipodoc  ( e.documentotipo, b.detpedmontoprecvta) as Monto ,    
    a.clientecodigo,a.clienterazonsocial,    
    f.monedasimbolo    
FROM     
    ['+@base+'].dbo.vt_pedido a  inner JOIN ['+@base+'].dbo.vt_detallepedido b 
    on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero     
    inner JOIN ['+@base+'].dbo.MAEART c ON b.productocodigo=c.acodigo    
    inner JOIN ['+@base+'].dbo.tabalm d ON a.almacencodigo=d.taalma    
    inner JOIN ['+@base+'].dbo.vt_documento e ON a.pedidotipofac=e.documentocodigo    
    inner JOIN ['+@base+'].dbo.gr_moneda f ON a.pedidomoneda = f.monedacodigo
    left JOIN ['+@base+'].dbo.familia g ON c.afamilia = g.fam_codigo
WHERE a.empresacodigo='''+@empresa+'''     
    and LTRIM(RTRIM(a.almacencodigo)) LIKE ('''+@codalmacen+''')      
    AND a.pedidofechafact  BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''    
    AND rtrim(b.productocodigo) like '''+@codproducto+'''
    AND isnull(a.estadoreg,0)<>1 and isnull(c.afstock,1)=1   
ORDER BY a.almacencodigo,c.productodescripcion,b.productocodigo,a.pedidotipofac,a.pedidonrofact '    
    
    
exec (@sensql)    
--- EXECUTE vt_RepVtasxArt 'gremco','05','01/01/2007','31/12/2007','%%'
GO
