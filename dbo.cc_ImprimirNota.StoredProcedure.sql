SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [cc_ImprimirNota] 'ziyaz','00100000130','12.00','1.25','02','07'
*/



CREATE        procedure [cc_ImprimirNota]
@base as varchar(50),
@nrodoc as varchar(14),
@bruto as varchar(15),
@igv as varchar(15),
@empresa as char(2),
@TipoDoc as varchar(2)
--@Letras as varchar(255)

as
declare @cadena as nvarchar(2000)

SET @cadena =N'Select a.pedidofecha,a.pedidonrofact,a.pedidofechasunat,a.clienterazonsocial,a.clientecodigo,a.clientedireccion,
a.pedidotiporefe,b.documentodescripcion,a.pedidonrorefe,c.conceptocodigo,monedasimbolo,
Bruto='+@bruto+' ,
dscto=a.pedidototaldsctoxitem,
valorventa='+@bruto+'-a.pedidototaldsctoxitem,
Igv='+@igv+' ,
Total=c.cargoapeimpape,
e.productocodigo as CodPro,m.adescri as Producto,e.detpedcantpedida as Cantidad,
e.detpedpreciopact as PreUnit,e.detpedimpbruto as Subtotal,x.conceptodescripcion

from ['+@base+'].dbo.vt_pedido a 
left join ['+@base+'].dbo.vt_documento b on a.pedidotiporefe=b.documentocodigo
left join ['+@base+'].dbo.vt_cargo c on a.empresacodigo+a.pedidotipofac+a.pedidonrofact=c.empresacodigo+c.documentocargo+c.cargonumdoc
left join ['+@base+'].dbo.vt_detallepedido e on a.empresacodigo+a.pedidonumero=e.empresacodigo+e.pedidonumero
left join ['+@base+'].dbo.maeart m on e.productocodigo=m.acodigo
left join ['+@base+'].dbo.cc_conceptos x on c.conceptocodigo=x.conceptocodigo
LEFT JOIN ['+@base+'].dbo.GR_MONEDA gr on c.monedacodigo=gr.monedacodigo 
where a.empresacodigo='+@empresa+' and a.pedidotipofac='+@Tipodoc+' and  a.pedidonrofact='+@nrodoc+'  ' 

exec(@cadena)
-- EXEC cc_ImprimirNota 'desarrollo','12700000009',1764.7059,335.29,'01','07'

/*'''+@Letras+''' as Letras,*/
GO
