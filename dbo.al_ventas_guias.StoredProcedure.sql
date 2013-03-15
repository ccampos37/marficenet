SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [al_ventas_guias]
@base varchar(50),
@empresa varchar(2),
@mesproceso varchar(6),
@puntovta varchar(2)='%%',
@codigo varchar(20)='%%'
as
declare @sql  varchar(4000)

set @sql = ' Select TIPO= (case when isnull(pedidocondicionfactura,''0'') =''1'' then ''DOCUMENTO ANULAD0 '' else
                  (CASE WHEN AA.mesventas > BB.mesproceso THEN ''ENTREGA ANTICIPADA'' 
                   else ( case when AA.mesventas=BB.mesproceso  then ''ENTREGA MES ''
                         else ''VENTA DIFERIDA'' end) end) end),
AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,aa.AFAMILIA ,aa.familiadescripcion, pedidotipofac,pedidonrofact ,AA.bien ,
productocodigo, aa.productodescripcion,pedidonumero,cantidad=sum(isnull(cantidad,0)),itemvta=sum(isnull(aa.itemventa,0)),
decodigo,DECANTID=SUM(DECANTID),DEPRECIO=SUM(DEPRECIO*DECANTID) 
from '+@base+'.dbo.v_ventas AA
LEFT JOIN '+@base+'.dbo.v_kardexvalorizado  BB ON aa.EMPRESACODIGO+aa.PEDIDONUMERO+aa.PRODUCTOCODIGO= bb.EMPRESACODIGO+ISNULL(bb.CANROPED,'''')+bb.DECODIGO 
WHERE AA.empresacodigo='''+@empresa+'''  and aa.MESventas ='''+@mesproceso+''' '  
If @puntovta<>'%%' set @sql=@sql + ' and aa.puntovtacodigo='''+@puntovta +''' ' 
If @codigo<>'%%' set @sql=@sql + ' and aa.productocodigo='''+@codigo +''' ' 
set @sql= @sql + ' group by AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,aa.AFAMILIA ,aa.familiadescripcion, pedidotipofac,pedidonrofact ,
productocodigo, aa.productodescripcion ,pedidonumero,pedidocondicionfactura,mesventas, mesproceso , DECODIGO, AA.bien  
order by 1, AA.puntovtacodigo,  pedidotipofac,pedidonrofact '

execute(@sql)
GO
