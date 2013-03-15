SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC vt_impresionfacturas_rpt 'desarrollo','00100000571','01','02','01'

select * from desarrollo.dbo.vt_pedido where empresacodigo='02' and pedidonumero='00100000404'
*/

CREATE           procedure [vt_impresionfacturas_rpt]
@base as varchar(50),
@pedidonumero as varchar(15),
@empresa as char(2),
@puntovta as char(2),
@moneda as char(2)

as
declare @cadena as nvarchar(4000)

SET @cadena =N'SELECT Item=cast(b.detpeditem as integer),a.pedidonrofact,A.PEDIDOFECHAfact,F.FORMAPAGOCODIGO,F.FORMAPAGODESCRIPCION,A.CLIENTECODIGO,
A.CLIENTERAZONSOCIAL,A.CLIENTEDIRECCION,B.PRODUCTOCODIGO,B.DETPEDCANTPEDIDA,M.ADESCRI,A.PEDIDOMENSAJE,
porcentajedscto=detpeddsctoxitem,detpedmontoimpto,unidadcodigo=aunidad,detpeddsctoxitem,
DETPEDPRECIOPACT=
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),b.DETPEDPRECIOPACT) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),b.DETPEDPRECIOPACT) as varchar) else  ''€.''+ cast(convert(decimal(9,2),b.DETPEDPRECIOPACT) as varchar) end ,
DETPEDMONTOPRECVTA=
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),b.DETPEDMONTOPRECVTA) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),DETPEDMONTOPRECVTA) as varchar) else  ''€.''+ cast(convert(decimal(9,2),DETPEDMONTOPRECVTA) as varchar) end ,
A.PEDIDOTOTBRUTO,A.PEDIDOTOTIMPUESTO,A.PEDIDOTOTNETO,V.VENDEDORCODIGO,V.VENDEDORNOMBRES,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) end as TotalBruto,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.pedidototaldsctoxitem+a.pedidomontodsctoglobal) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.pedidototaldsctoxitem+a.pedidomontodsctoglobal) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.pedidototaldsctoxitem+A.pedidomontodsctoglobal) as varchar) end as Totaldescuento,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO-A.pedidototaldsctoxitem - a.pedidomontodsctoglobal) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO-A.pedidototaldsctoxitem-A.pedidodsctoglobal) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO-A.pedidototaldsctoxitem-pedidodsctoglobal) as varchar) end as Totalvalorventa,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) end as TotalIGV,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) end as NetoPagar

FROM ['+@base+'].dbo.VT_PEDIDO A 
left JOIN ['+@base+'].dbo.VT_DETALLEPEDIDO B ON a.empresacodigo=b.empresacodigo and A.PEDIDONUMERO=B.PEDIDONUMERO
left JOIN ['+@base+'].dbo.MAEART M ON B.PRODUCTOCODIGO=M.ACODIGO
left JOIN ['+@base+'].dbo.VT_VENDEDOR V ON A.VENDEDORCODIGO=V.VENDEDORCODIGO
left JOIN ['+@base+'].dbo.VT_FORMAPAGO F ON A.FORMAPAGOCODIGO=F.FORMAPAGOCODIGO
where a.pedidonumero='''+@pedidonumero+''' and a.empresacodigo='''+@empresa+''' and 
a.puntovtacodigo='''+@puntovta+''' order by item' 

execute(@cadena)
GO
