SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [al_guias_ventas]
@base varchar(50),
@empresa varchar(2),
@mesproceso varchar(6),
@puntovta varchar(2)='%%',
@codigo varchar(20)='%%'
as
declare @sql  varchar(4000)
set @sql='Select tipooperacion= (case when CASITGUI=''A'' then ''GUIA ANULADA '' else
                  (CASE WHEN AA.mesproceso > BB.mesventas THEN ''ENTREGA DIFERIDA'' 
                   else ( case when AA.mesproceso=BB.mesventas then ''ENTREGA MES ''
                         else (case when ISNULL(canroped,'''')<>'''' and ISNULL(productocodigo,'''')<>'''' then  ''ENTREGA ANTICIPADA'' else ''MOV ALMACEN'' end)
                   end) end) end),
AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,codigofamilia=AFAMILIA ,familiadescripcion, tipodoc=CARFTDOC,nrodoc=CARFNDOC,
codtransf=catipotransf ,nrotransf=canrotransf,codigoproducto=DECODIGO, CODIGODESCRIPCION,nropedido=CANROPED,CantAlmacen=SUM(DECANTID),
TotItemAlm=SUM(DEPRECIO*DECANTID) ,productocodigo,CantiVenta=sum(isnull(cantidad,0)),itemvta=sum(isnull(bb.itemventa,0))  
from '+@base+'.dbo.v_movimKardex aa 
LEFT JOIN '+@base+'.dbo.V_ventasvalorizadas BB ON AA.EMPRESACODIGO+ISNULL(AA.CANROPED,'''')+AA.DECODIGO = BB.EMPRESACODIGO+BB.PEDIDONUMERO+BB.PRODUCTOCODIGO
WHERE AA.empresacodigo='''+@empresa+''' AND CATIPMOV  =''S'' AND MESPROCESO='''+@mesproceso+''' and CARFTDOC=''GR'' and ISNULL(carfndoc,'''')<>'''' '  
If @puntovta<>'%%' set @sql=@sql + ' and aa.puntovtacodigo='''+@puntovta +''' ' 
If @codigo<>'%%' set @sql=@sql + ' and aa.decodigo='''+@codigo +''' ' 
set @sql= @sql + ' group by AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,AFAMILIA ,familiadescripcion,DECODIGO, CODIGODESCRIPCION,CANROPED,
catipotransf, canrotransf , CARFTDOC , CARFNDOC , mesproceso , mesventas , CASITGUI , productocodigo 
order by 1, CARFNDOC '

execute(@sql)

-----
/*
--------------

select TIPO= (case when isnull(pedidocondicionfactura,'0') ='1' then 'DOCUMENTO ANULAD0 ' else
                  (CASE WHEN AA.mesventas > BB.mesproceso THEN 'ENTREGA ANTICIPADA' 
                   else ( case when AA.mesventas=BB.mesproceso  then 'ENTREGA MES '
                         else 'VENTA DIFERIDA' end) end) end),
AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,aa.AFAMILIA ,aa.familiadescripcion, pedidotipofac,pedidonrofact ,AA.bien ,
productocodigo, aa.productodescripcion,pedidonumero,cantidad=sum(isnull(cantidad,0)),itemvta=sum(isnull(aa.itemventa,0)),
decodigo,DECANTID=SUM(DECANTID),DEPRECIO=SUM(DEPRECIO*DECANTID) 
from v_ventas AA
LEFT JOIN v_kardexvalorizado  BB ON aa.EMPRESACODIGO+aa.PEDIDONUMERO+aa.PRODUCTOCODIGO= bb.EMPRESACODIGO+ISNULL(bb.CANROPED,'')+bb.DECODIGO 
WHERE AA.empresacodigo='02'  and aa.MESventas ='201201'  and aa.bien=1
group by AA.empresacodigo,AA.puntovtacodigo,AA.puntovtadescripcion ,aa.AFAMILIA ,aa.familiadescripcion, pedidotipofac,pedidonrofact ,
productocodigo, aa.productodescripcion ,pedidonumero,pedidocondicionfactura,mesventas, mesproceso , DECODIGO, AA.bien  
order by 1, AA.puntovtacodigo,  pedidotipofac,pedidonrofact

*/
GO
