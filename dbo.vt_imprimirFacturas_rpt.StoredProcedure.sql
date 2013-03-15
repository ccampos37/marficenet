SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC vt_imprimirfacturas_rpt 'desarrollo','23000000016','02','03','01'

select * from desarrollo.dbo.gr_moneda here empresacodigo='02' and pedidonumero='00100000404'
*/

CREATE    procedure [vt_imprimirFacturas_rpt]
@base as varchar(50),
@pedidonumero as varchar(11),
@empresa as char(2),
@puntovta as char(2),
@moneda as char(2)

as
declare @cadena as nvarchar(4000)

SET @cadena =N'SELECT Item=cast(b.detpeditem as integer),a.pedidonrofact,A.PEDIDOFECHAfact,F.FORMAPAGOCODIGO,F.FORMAPAGODESCRIPCION,
 A.CLIENTECODIGO,A.CLIENTERAZONSOCIAL,A.CLIENTEDIRECCION,B.PRODUCTOCODIGO,B.DETPEDCANTPEDIDA,M.ADESCRI,
porcentajedscto=detpeddsctoxitem,detpedmontoimpto,DETPEDPRECIOPACT, DETPEDMONTOPRECVTA, A.PEDIDOTOTBRUTO,A.PEDIDOTOTIMPUESTO,A.PEDIDOTOTNETO,
V.VENDEDORCODIGO,V.VENDEDORNOMBRES,A.PEDIDOTOTBRUTO , (A.pedidototaldsctoxitem+a.pedidomontodsctoglobal) as Totaldescuento,
(A.PEDIDOTOTBRUTO-A.pedidototaldsctoxitem - a.pedidomontodsctoglobal) as Totalvalorventa,g.monedasimbolo
FROM ['+@base+'].dbo.VT_PEDIDO A 
left JOIN ['+@base+'].dbo.VT_DETALLEPEDIDO B ON a.empresacodigo=b.empresacodigo and A.PEDIDONUMERO=B.PEDIDONUMERO
left JOIN ['+@base+'].dbo.MAEART M ON B.PRODUCTOCODIGO=M.ACODIGO
left JOIN ['+@base+'].dbo.VT_VENDEDOR V ON A.VENDEDORCODIGO=V.VENDEDORCODIGO
left JOIN ['+@base+'].dbo.VT_FORMAPAGO F ON A.FORMAPAGOCODIGO=F.FORMAPAGOCODIGO
left JOIN ['+@base+'].dbo.gr_moneda g ON A.pedidomoneda = g.monedacodigo 

where a.pedidonumero='''+@pedidonumero+''' and a.empresacodigo='''+@empresa+''' and 
a.puntovtacodigo='''+@puntovta+''' order by item' 

execute(@cadena)
GO
