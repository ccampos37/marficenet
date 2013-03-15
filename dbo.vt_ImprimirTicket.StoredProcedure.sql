SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC vt_ImprimirTicket 'ziyaz','22000012294','02','02',01
select * from ziyaz.dbo.vt_puntoventa
select * from desarrollo.dbo.vt_detallepedido where pedidonumero='00100000441'

*/
CREATE    procedure [vt_ImprimirTicket]
@base as varchar(50),
@pedidonumero as varchar(11),
@empresa as char(2),
@puntovta as char(2),
@moneda as char(2)

as
declare @cadena as nvarchar(4000)
SET @cadena =N'SELECT a.pedidotipofac,PEDIDONUMERO=a.pedidonrofact,A.EMPRESACODIGO,E.EMPRESADESCRIPCION,E.EMPRESARUC,
empresadireccion= case when isnull(p.direccioncomercial,'''')='''' then E.EMPRESADIRECCION else p.direccioncomercial end,
P.PUNTOVTACODIGO,P.PUNTOVTADESCRIPCION,
PEDIDOFECHA=pedidofechasunat,V.VENDEDORCODIGO,V.VENDEDORNOMBRES,F.FORMAPAGOCODIGO,F.FORMAPAGODESCRIPCION,A.CLIENTECODIGO,
A.CLIENTERAZONSOCIAL,M.ADESCRI,B.DETPEDCANTPEDIDA,B.DETPEDMONTOPRECVTA,
totalprecioitem=case when a.pedidotipofac<>''15'' then DETPEDCANTPEDIDA*b.detpedpreciopact else b.detpedmontoprecvta end ,
A.PEDIDOTOTBRUTO,A.PEDIDOTOTIMPUESTO,A.PEDIDOTOTNETO,
moneda=case '''+@moneda+''' when ''01'' then ''S/. '' else case '''+@moneda+''' when ''02'' then ''US$. '' else ''€. '' end end , 
TotalBruto=case when a.pedidotipofac<>''15'' then 0 else A.PEDIDOTOTBRUTO end ,
Totaldescuento=case when a.pedidotipofac<>''15'' then round((A.pedidototaldsctoxitem+a.pedidomontodsctoglobal)*1.18,2)
    else A.pedidototaldsctoxitem+a.pedidomontodsctoglobal end ,
Totalvalorventa=case when a.pedidotipofac<>''15'' then 0 else A.PEDIDOTOTBRUTO-A.pedidototaldsctoxitem-pedidodsctoglobal end ,
case when a.pedidotipofac<>''15'' then 0 else A.PEDIDOTOTIMPUESTO end as TotalIGV,
A.PEDIDOTOTNETO as NetoPagar

FROM ['+@base+'].dbo.VT_PEDIDO A 
INNER JOIN ['+@base+'].dbo.VT_DETALLEPEDIDO B ON A.PEDIDONUMERO=B.PEDIDONUMERO
INNER  JOIN ['+@base+'].dbo.GR_DOCUMENTO C ON A.PEDIDOTIPOFAC=C.DOCUMENTOCODIGO
INNER JOIN ['+@base+'].dbo.CO_MULTIEMPRESAS E ON A.EMPRESACODIGO=E.EMPRESACODIGO
INNER JOIN ['+@base+'].dbo.MAEART M ON B.PRODUCTOCODIGO=M.ACODIGO
INNER JOIN ['+@base+'].dbo.VT_VENDEDOR V ON A.VENDEDORCODIGO=V.VENDEDORCODIGO
INNER JOIN ['+@base+'].dbo.VT_PUNTOVENTA P ON A.PUNTOVTACODIGO=P.PUNTOVTACODIGO
INNER JOIN ['+@base+'].dbo.VT_FORMAPAGO F ON A.FORMAPAGOCODIGO=F.FORMAPAGOCODIGO
where a.pedidonumero='''+@pedidonumero+''' and a.empresacodigo='''+@empresa+''' and 
a.puntovtacodigo='''+@puntovta+''' ' 

execute(@cadena)

/*
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTBRUTO) as varchar) end as TotalBruto,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTIMPUESTO) as varchar) end as TotalIGV,
case '''+@moneda+''' when ''01'' then ''S/.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) when ''02'' then ''US$.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) else  ''€.''+ cast(convert(decimal(9,2),A.PEDIDOTOTNETO) as varchar) end as NetoPagar
*/
GO
