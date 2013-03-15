SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  proc [al_cruceLiquidacionVentas]
as 
select z.pedidonrorefe,a.clienterazonsocial,z.factura,z.pedidonrofact,z.tipo,
z.liquidacion,z.ventas
--liquida==sum(z.liquidacion)
--liquidacion=sum(z.liquidacion),
--venta=sum(z.ventas)
from 
(
select tipo='2',
pedidonrorefe,
factura=case when pedidonumero<>'' then
(select pedidonrofact from acop_centro.dbo.vt_pedido b where a.pedidonrorefe=b.pedidonumero )
else '' end, pedidonrofact,
liquidacion=pedidototneto,ventas=00.00
from acop_centro.dbo.al_liquidacionCompra a
where modovtacodigo='LC' 
and month(pedidofechafact)=1 
and year(pedidofechafact)=2007
and isnull(estadoreg,0)<>1
and pedidonrorefe<>''
union all
select tipo='1',pedidonumero,pedidonrofact,'',00.00,ventas=pedidototneto
from acop_centro.dbo.vt_pedido
where modovtacodigo='01' 
and month(pedidofechafact)=1 
and year(pedidofechafact)=2007
and isnull(estadoreg,0)<>1
) as z
left join acop_centro.dbo.al_liquidacioncompra a on z.pedidonrorefe=a.pedidonumero
inner join acop_centro.dbo.vt_pedido b on z.pedidonrorefe=b.pedidonumero
--group by z.pedidonrorefe,a.clienterazonsocial,z.factura,z.pedidonrofact
--having abs( round(sum(z.ventas),2)- round(sum(z.liquidacion)*1.03,2))>=1
order by 2,3 
--SELECT * FROM acop_centro.dbo.AL_LIQUIDACIONCOMPRA
--SELECT * FROM acop_centro.dbo.vt_pedido
GO
