SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*


select * from desarrollo.dbo.te_detallerecibos where detrec_fechacancela='11/02/2010'
select * from desarrollo.dbo.vt_abono where 


select * from ziyaz.dbo.vt_pedido where pedidonrofact='00300002646' and pedidotipofac='14'

select * from ziyaz.dbo.vt_detallepedido where pedidonumero='31400001691'
select * from ziyaz.dbo.maeart where acodigo='7000000019'

select aa.* from ziyaz.dbo.vt_cargo aa 
inner join ziyaz.dbo.vt_abono cc on aa.empresacodigo+aa.documentocargo+aa.cargonumdoc=cc.empresacodigo+cc.documentoabono+cc.abononumdoc
where cargonumdoc='00300002646'
select * from ziyaz.dbo.vt_abono where abononumdoc='00300002646'

select * from ziyaz.dbo.vt_vendedor
select * from ziyaz.dbo.cc_tipodocumento


execute vt_ComisionesVendedores_rpt 'ziyaz','02','016' ,'01/07/2012','31/07/2012'

*/

CREATE  PROC  [vt_ComisionesVendedores_rpt]

@base varchar(50),
@empresa varchar(50),
@vendedor varchar(3),
@fecdesde varchar(10),
@fechasta varchar(10)

AS  

DECLARE @sql varchar(5000)


set @sql=' select d.vendedornombres,tipo=''VTA CONTADO       '',a.empresacodigo , a.clienterazonsocial,
a.pedidotipofac ,e.tdocumentodescripcion, 
a.pedidonrofact,a.pedidomoneda,a.pedidofechasunat,fechapago=pedidofechasunat,tipocambioventa,
cob=sum(b.detpedmontoprecvta),com=sum(b.detpedmontoprecvta-b.detpedmontoimpto ),pedidototneto=sum(b.detpedmontoprecvta)
from '+@base+'.dbo.vt_pedido a 
inner join '+@base+'.dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero
inner join '+@base+'.dbo.maeart c on b.productocodigo=c.acodigo
inner join '+@base +'.dbo.vt_vendedor d on a.vendedorcodigo=d.vendedorcodigo 
left join '+@base +'.dbo.cc_tipodocumento e on a.pedidotipofac=e.tdocumentocodigo 
left join '+@base +'.dbo.ct_tipocambio f on a.pedidofechafact=f.tipocambiofecha
where a.empresacodigo + a.pedidotipofac+a.pedidonrofact not in 
(select b.empresacodigo+b.documentocargo+b.cargonumdoc from '+@base+'.dbo.vt_cargo b) 
and a.pedidofechasunat between '''+@fecdesde+''' and '''+@fechasta+'''
and a.empresacodigo='''+@empresa+''' and isnull(c.apcom,0)=1
and a.vendedorcodigo like '''+@vendedor +''' and isnull(a.pedidocondicionfactura,0)=0
group by d.vendedornombres,a.empresacodigo , a.clienterazonsocial,a.pedidotipofac ,
e.tdocumentodescripcion,a.pedidonrofact,a.pedidomoneda,a.pedidofechasunat,tipocambioventa

union all
select z.vendedornombres,z.tipo,z.empresacodigo ,  z.clienterazonsocial,
z.pedidotipofac , z.tdocumentodescripcion,
z.pedidonrofact,z.pedidomoneda,z.pedidofechasunat,z.cargoapefeccan,tipocambioventa,z.cob,
com=z.com * ( sum(b.detpedmontoprecvta)/z.pedidototneto )/1.18 ,
pedidototneto=sum(b.detpedmontoprecvta) from
(
select a.pedidonumero,f.vendedornombres,tipo=''VTA CREDITO    '',d.empresacodigo ,  h.clienterazonsocial,
pedidotipofac=d.documentocargo , g.tdocumentodescripcion,a.pedidototneto,
pedidonrofact=d.cargonumdoc,pedidomoneda=d.monedacodigo,pedidofechasunat=d.cargoapefecemi,d.cargoapefeccan,
cob=sum( e.abonocanimpsol  ),
com=sum(e.abonocanimpsol  )
from '+@base +'.dbo.vt_abono e 
inner join '+@base+'.dbo.vt_cargo d 
on e.abonocancli+e.documentoabono+e.abononumdoc=d.clientecodigo+d.documentocargo+d.cargonumdoc
left join '+@base+'.dbo.vt_pedido a 
on d.empresacodigo+d.documentocargo+d.cargonumdoc=a.empresacodigo +a.pedidotipofac+a.pedidonrofact
inner join '+@base +'.dbo.vt_vendedor f on d.vendedorcodigo=f.vendedorcodigo 
left join '+@base +'.dbo.cc_tipodocumento g on d.documentocargo=g.tdocumentocodigo 
left join '+@base +'.dbo.vt_cliente h on d.clientecodigo=h.clientecodigo 
where (e.abonocanfecan between '''+@fecdesde+''' and '''+@fechasta+''')  
and d.empresacodigo='''+@empresa+''' AND g.tdocumentotipo=''C'' and isnull(e.abonocanflreg,0)=0
and isnull(a.pedidocondicionfactura,0)=0 and d.vendedorcodigo like '''+@vendedor +''' 
group by a.pedidonumero,f.vendedornombres,d.empresacodigo ,  h.clienterazonsocial,
d.documentocargo , g.tdocumentodescripcion,
d.cargonumdoc,d.monedacodigo,d.cargoapefecemi,d.cargoapefeccan ,a.pedidototneto
) z
left join '+@base+'.dbo.vt_detallepedido b on z.empresacodigo+z.pedidonumero=b.empresacodigo+b.pedidonumero
left join '+@base+'.dbo.maeart c on b.productocodigo=c.acodigo
left join '+@base +'.dbo.ct_tipocambio h on z.pedidofechasunat=h.tipocambiofecha
where isnull(c.apcom,1)=1
group by z.vendedornombres,z.empresacodigo ,z.tipo,z.clienterazonsocial,
z.pedidotipofac , z.tdocumentodescripcion,tipocambioventa,
z.pedidonrofact,z.pedidomoneda,z.pedidofechasunat,z.cargoapefeccan ,z.cob,z.com,z.pedidototneto

union all 

select d.vendedornombres,tipo=''NOTAS DE CREDITO    '',a.empresacodigo ,  b.clienterazonsocial,
a.documentocargo , e.tdocumentodescripcion,
a.cargonumdoc,a.monedacodigo,cargoapefecemi,cargoapefecemi,tipocambioventa,
cob=cargoapeimpape*-1,com=(cargoapeimpape/1.18*-1) ,a.cargoapeimpape*-1
from '+@base+'.dbo.vt_cargo a 
left join '+@base+'.dbo.vt_cliente b on a.clientecodigo=b.clientecodigo
left join '+@base +'.dbo.vt_vendedor d on a.vendedorcodigo=d.vendedorcodigo 
left join '+@base +'.dbo.cc_tipodocumento e on a.documentocargo=e.tdocumentocodigo 
left join '+@base +'.dbo.ct_tipocambio h on a.cargoapefecemi=h.tipocambiofecha
where (a.cargoapefecemi between '''+@fecdesde+''' and '''+@fechasta+''')  
and a.empresacodigo='''+@empresa+''' AND tdocumentotipo=''A''
and isnull(a.cargoapeflgreg,0)=0 and a.vendedorcodigo like '''+@vendedor +''' '

execute(@sql)
GO
