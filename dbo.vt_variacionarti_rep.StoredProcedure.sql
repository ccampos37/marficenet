SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute vt_variacionarti_rep 'tabor','%%','01/01/2007','31/12/2007','%%',2,1
CREATE         PROCEDURE [vt_variacionarti_rep]  /*EN USO*/    
@base varchar(50),    
@codalmacen varchar(2),    
@fecdesde varchar(10),    
@fechasta varchar(10),    
@codarticulo varchar(20),
@tipo as integer,
@valor varchar(10)
AS       
DECLARE @sensql nvarchar (4000)    
SET @sensql = N'    
	SELECT   a.almacencodigo, d.almacendescripcion,    
	    b.productocodigo,c.aprecio,    
	    productodescripcion=c.adescri,    
	    a.pedidofechafact as Fec_Emision,a.pedidonumero as Pedido,    
	    a.pedidonrofact as Comprobante, a.pedidotipofac as Cod_Documento,    
	    b.detpedcantpedida as detpedcantpedida,    
	    b.detpedimpbruto as Monto ,    
	    a.clientecodigo,a.clienterazonsocial,    
	    f.monedasimbolo,
            b.detpedmontoprecvta    
	FROM     
	    ['+@base+'].dbo.vt_pedido a    
	    inner JOIN ['+@base+'].dbo.vt_detallepedido b ON a.pedidonumero=b.pedidonumero     
	    inner JOIN  ['+@base+'].dbo.maeart c ON b.productocodigo=c.acodigo     
	    left JOIN ['+@base+'].dbo.vt_almacen d ON a.almacencodigo=d.almacencodigo    
	    left JOIN ['+@base+'].dbo.vt_documento e ON a.pedidotipofac=e.documentocodigo    
	    left JOIN ['+@base+'].dbo.gr_moneda f ON a.pedidomoneda = f.monedacodigo    
	WHERE     
	    LTRIM(RTRIM(a.almacencodigo)) LIKE ('''+@codalmacen+''')      
	    AND LTRIM(RTRIM(b.productocodigo)) LIKE ('''+@codarticulo+''')    
	    AND a.pedidofechafact   
	    BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''    
	    AND a.pedidofechaanu IS NULL '
If @tipo=1 set @sensql=@sensql+ ' AND (round(c.aprecio,2)-round(b.detpedimpbruto,2))>'+@valor+' '
if @tipo=2 set @sensql=@sensql+' and (ABS(round(c.aprecio,2)-round(b.detpedimpbruto,2))/round(C.aprecio,2)*100)>'+@valor+' '
set @sensql=@sensql+' order by a.almacencodigo,c.productodescripcion,b.productocodigo,a.pedidotipofac,a.pedidonrofact '    
    
execute (@sensql)    
RETURN
GO
