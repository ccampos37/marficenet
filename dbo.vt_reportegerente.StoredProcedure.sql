SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

exec vt_reportegerente 'ZIYAZ','30/06/2012','30/06/2012','04','02'

select pedidotipofac,* from ziyaz.dbo.vt_pedido where pedidofechafact between  '06/05/2010' and '06/05/2010'
--didotipofac='07'
select * from ziyaz.dbo.vt_pedido where empresacodigo='03'
select * from ziyaz.dbo.vt_puntoventa

*/
CREATE Proc [vt_reportegerente]
@base varchar(50),
@desde varchar(15),
@hasta varchar(15),
@punto varchar(2),
@empresa varchar(2)
As
Declare @Sql varchar(8000)
set @sql=' If Exists(Select name from tempdb..sysobjects where name=''##tmpaa'') 
    Drop Table [##tmpaa]  '

execute(@sql)
Set @Sql='

select Cliente=case when len(cliente1)> 2 then upper(left(cliente1,1))+lower(substring(cliente1,2,len(cliente1)-1)) else cliente1 end,
producto=case when isnull(z.pedidocondicionfactura,0)=0 then case when len(b.adescri)> 2 
                then upper(left(adescri,1))+lower(substring(adescri,2,len(adescri)-1)) else adescri end
              else ''A n u l a d o '' end ,
vendedor=case when len(c.vendedornombres)> 2 then upper(left(c.vendedornombres,1))+lower(substring(c.vendedornombres,2,len(c.vendedornombres)-1)) else c.vendedornombres end,
Contacto=case when len(d.tipocontactodescripcion)> 2 then upper(left(d.tipocontactodescripcion,1))+lower(substring(d.tipocontactodescripcion,2,len(d.tipocontactodescripcion)-1)) else d.tipocontactodescripcion end,
tdocumentodesccorta=case when len(tdocumentodesccorta)> 2 then upper(left(tdocumentodesccorta,1))+lower(substring(tdocumentodesccorta,2,len(tdocumentodesccorta)-1)) else tdocumentodesccorta end, 
Efectivo=case when (SELECT count(pagocodigo) from ['+@base+'].dbo.vt_pagosencaja  where empresacodigo+pedidonumero=z.empresacodigo+z.pedidonumero
         and pagocodigo=''01'')>''0'' then ''x'' else '''' end,
tarjeta=case when (SELECT count(pagocodigo) from ['+@base+'].dbo.vt_pagosencaja  where empresacodigo+pedidonumero=z.empresacodigo+z.pedidonumero
and pagocodigo=''02'')>''0'' then ''x'' else '''' end,
cheque=case when (SELECT count(pagocodigo) from ['+@base+'].dbo.vt_pagosencaja  where empresacodigo+pedidonumero=z.empresacodigo+z.pedidonumero
and pagocodigo=''03'')>''0'' then ''x'' else '''' end,
Otros=case when (SELECT count(pagocodigo) from ['+@base+'].dbo.vt_pagosencaja  where empresacodigo+pedidonumero=z.empresacodigo+z.pedidonumero
       and not pagocodigo in  (''01'',''02'',''03''))>''0'' then ''x'' else '''' end ,
UniTC=case when z.pedidomoneda=''01'' then
           (Case When upper(e.tdocumentotipo)=''A'' then -1 else 1 end)* 
      z.detpedpreciopact/(isnull(f.tipocambioventa,1))
      else (Case When upper(e.tdocumentotipo)=''A'' then -1 else 1 end)* z.detpedpreciopact end ,
SubTC=case when isnull(z.pedidocondicionfactura,0)=0 then 
           case when z.pedidomoneda=''01'' then 
           (Case When upper(e.tdocumentotipo)=''A'' then -1 else 1 end)* 
           z.detpedmontoprecvta/(isnull(f.tipocambioventa,1)) 
           else (Case When upper(e.tdocumentotipo)=''A'' then -1 else 1 end)* z.detpedmontoprecvta end
           else 0 end ,
 z.*
from 
(
select distinct tipo=''  CONTADO    '',a.empresacodigo,Cliente1=a.clienterazonsocial ,a.pedidonrofact as Numero,
productocodigo,b.detpedcantpedida as Cantidad,b.detpedpreciopact,b.detpedmontoprecvta ,
a.vendedorcodigo,a.tipocontactocodigo , a.pedidotipofac,documentodescripcion=a.pedidonrofact,
a.pedidomoneda,detpeddsctoxitem as Dscto,'''' as newww,a.pedidofechafact,a.pedidonumero,a.pedidocondicionfactura,j.pagonumdoc
from ['+@base+'].dbo.vt_pedido a 
left join ['+@base+'].dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero
inner join ['+@base+'].dbo.vt_modoventa d on a.modovtacodigo=d.modovtacodigo
left join ['+@base+'].dbo.ct_tipocambio h on a.pedidofechafact=h.tipocambiofecha
left join ['+@base+'].dbo.cc_tipodocumento g on a.pedidotipofac=g.tdocumentocodigo
left join ['+@base+'].dbo.vt_pagosencaja j on a.empresacodigo+a.pedidonumero=j.empresacodigo+j.pedidonumero
left join ['+@base+'].dbo.vt_conceptosdepago i on j.pagocodigo=i.pagocodigo
where a.pedidofechafact between '''+@desde+''' and '''+@hasta+'''
and a.puntovtacodigo like '''+@punto+''' and a.empresacodigo='''+@empresa+''' 
and ( g.tdocumentonotaconta=''1'' or i.pagoefectivogerente = 1 )
union all
select tipo=''  CONTADO'',a.empresacodigo,a.clienterazonsocial as Cliente,a.pedidonrofact as Numero,productocodigo='' '',
Cantidad=0,PreUnit=0,Subtotal=a.pedidototneto ,Vendedorcodigo,tipocontactocodigo,a.pedidotipofac,documentodescripcion=a.pedidonrofact,
a.pedidomoneda,Dscto=0,'''' as newww,a.pedidofechafact,a.pedidonumero,a.pedidocondicionfactura,j.pagonumdoc
from ['+@base+'].dbo.vt_pedido a 
left join ['+@base+'].dbo.ct_tipocambio h on a.pedidofechafact=h.tipocambiofecha
left join ['+@base+'].dbo.cc_tipodocumento g on a.pedidotipofac=g.tdocumentocodigo
left join [ZIYAZ].dbo.vt_pagosencaja j on a.empresacodigo+a.pedidonumero=j.empresacodigo+j.pedidonumero
where a.empresacodigo='''+@empresa+''' and a.empresacodigo+a.pedidonumero not in 
     ( select empresacodigo+pedidonumero from ['+@base+'].dbo.vt_detallepedido ) 
      and g.tdocumentonotaconta=''1'' and a.pedidofechafact between '''+@desde+''' and '''+@hasta+'''
     and a.puntovtacodigo like '''+@punto+''' 
union all
select distinct tipo='' CREDITO'',a.empresacodigo,Cliente1=a.clienterazonsocial,a.pedidonrofact as Numero,
b.productocodigo ,b.detpedcantpedida as Cantidad,b.detpedpreciopact as PreUnit,b.detpedmontoprecvta as Subtotal,
a.vendedorcodigo,a.tipocontactocodigo ,pedidotipofac,documentodescripcion=a.pedidonrofact,a.pedidomoneda,
detpeddsctoxitem as Dscto,'''' as newww,a.pedidofechafact,a.pedidonumero,a.pedidocondicionfactura,h.pagonumdoc
from ['+@base+'].dbo.vt_pedido a 
inner join ['+@base+'].dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero
inner join ['+@base+'].dbo.vt_cargo c on a.empresacodigo+a.pedidotipofac+a.pedidonrofact=c.empresacodigo+c.documentocargo+c.cargonumdoc 
inner join ['+@base+'].dbo.vt_modoventa d on a.modovtacodigo=d.modovtacodigo
left join ['+@base+'].dbo.cc_tipodocumento g on a.pedidotipofac=g.tdocumentocodigo
left join ['+@base+'].dbo.vt_pagosencaja h on a.empresacodigo+a.pedidonumero=h.empresacodigo+h.pedidonumero
left join ['+@base+'].dbo.vt_conceptosdepago i on h.pagocodigo=i.pagocodigo
where a.pedidofechafact between '''+@desde+''' and '''+@hasta+''' and a.puntovtacodigo like '''+@punto+''' 
and a.empresacodigo='''+@empresa+''' and  ( g.tdocumentonotaconta=''0'' AND  i.pagoefectivogerente = 0)
union all
select tipo=''COBRANZA'',a.empresacodigo,
a.clienterazonsocial ,a.pedidonrofact ,productocodigo='' '' ,0 as Cantidad,detpedpreciopact=0 ,
Subtotal=sum(c.abonocanimpcan),
a.vendedorcodigo,tipocontactocodigo , a.pedidotipofac,
documentodescripcion=a.pedidonrofact,
C.ABONOCANMONCAN,0 as Dscto,'''' as newww,a.pedidofechafact,a.pedidonumero,a.pedidocondicionfactura,j.pagonumdoc
from ['+@base+'].dbo.vt_pedido a 
inner join ['+@base+'].dbo.vt_abono c on a.clientecodigo+a.pedidotipofac+a.pedidonrofact=c.abonocancli+c.documentoabono+c.abononumdoc 
left join ['+@base+'].dbo.cc_tipodocumento g on a.pedidotipofac=g.tdocumentocodigo
left join ['+@base+'].dbo.ct_tipocambio h on a.pedidofechasunat=h.tipocambiofecha
left join ['+@base+'].dbo.vt_pagosencaja j on a.empresacodigo+a.pedidonumero=j.empresacodigo+j.pedidonumero
left join ['+@base+'].dbo.vt_conceptosdepago i on j.pagocodigo=i.pagocodigo
where convert (varchar(10),c.fechaact,103)>= '''+@desde+''' and convert (varchar(10),c.fechaact,103)<='''+@hasta+''' and a.puntovtacodigo like '''+@punto+''' 
and a.empresacodigo='''+@empresa+''' and g.tdocumentonotaconta=''0'' and isnull(c.abonocanflreg,0)<>1
and isnull(i.pagoefectivogerente,0) = 0 
group by a.empresacodigo,a.clienterazonsocial ,a.pedidonrofact , C.ABONOCANMONCAN,a.vendedorcodigo,tipocontactocodigo , a.pedidotipofac,
a.pedidonrofact,a.pedidofechafact,a.pedidonumero,a.pedidocondicionfactura,j.pagonumdoc
) z
left join ['+@base+'].dbo.maeart b on z.productocodigo=b.acodigo
left join ['+@base+'].dbo.vt_vendedor c on z.vendedorcodigo=c.vendedorcodigo
left join ['+@base+'].dbo.vt_tipodecontacto d on z.tipocontactocodigo=d.tipocontactocodigo
left join ['+@base+'].dbo.cc_tipodocumento e on z.pedidotipofac=e.tdocumentocodigo
left join ['+@base+'].dbo.ct_tipocambio f on z.pedidofechafact=f.tipocambiofecha
 '

execute(@Sql) 

/*
select * from desarrollo.dbo.vt_pagosencaja where pedidonumero='24000001096'
select * from ziyaz.dbo.vt_pedido where pedidonumero='24000001096'
*/
GO
