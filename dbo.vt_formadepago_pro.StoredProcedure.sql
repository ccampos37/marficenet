SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from ZIYAZ.DBO.te_cabecerarecibos
select * from ziyaz.dbo.vt_pedido where pedidonumero='31400000540'
execute vt_formadepago_pro 'agro2000','01','00130000000001'
select * from desarrollo.dbo.vt_pagosencaja where pedidonumero='31400000540'
*/

CREATE  proc [vt_formadepago_pro]
(
@base nvarchar(50),
@empresa char(2),
@pedido nvarchar(20)
)
as 
declare @sqlcad nvarchar(4000)

set @sqlcad=' select tipo=case when len(rtrim(isnull(d.ctactecodigo,'''')))=0 and len(rtrim(c.bancocodigo))=0 
    then ''C'' else ''B'' end ,
    tipofac=a.pedidotipofac,numero=a.pedidonrofact,tp=''T'',
    tipocancelacion=''58'',
    banco=case when len(rtrim(isnull(d.ctactecodigo,'''')))=0 and len(rtrim(c.bancocodigo))=0  then 
          e.codigocajavtas else c.bancocodigo end,
    documento='' '',moneda=a.pedidomoneda,importe=b.pagoimporte,
    fechacancelacion=a.pedidofechafact,
    ctacte=isnull(d.ctactecodigo,'' ''),obervaciones=isnull(d.pagotipodescripcion,'' '') 
    from ['+@Base+'].dbo.vt_pedido a
    inner join ['+@Base+'].dbo.vt_pagosencaja b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero
    inner join ['+@Base+'].dbo.vt_conceptosdepago c on b.pagocodigo=c.pagocodigo
    left join ['+@Base+'].dbo.vt_conceptostipodepago d on b.pagocodigo+b.pagotipocodigo=d.pagocodigo+d.pagotipocodigo
    inner join ['+@Base+'].dbo.vt_puntoventa e on a.puntovtacodigo=e.puntovtacodigo  

where a.empresacodigo='''+@empresa+''' and a.pedidonumero='''+@pedido+''''

execute (@sqlcad)
GO
