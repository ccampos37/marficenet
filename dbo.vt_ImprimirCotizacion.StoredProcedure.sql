SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [vt_ImprimirCotizacion]
@base as varchar(50),
@nrodoc as varchar(11),
--@bruto as float,
--@igv as float,
@empresa as char(2),
@TipoDoc as varchar(11),
@Letras as varchar(255)

as
declare @cadena as nvarchar(2000)
--a.pedidototbruto,a.pedidototimpuesto,a.pedidototneto,
SET @cadena =N'Select a.pedidonumero,a.pedidofecha,a.clienterazonsocial,a.clientecodigo,a.clientedireccion,
b.documentodescripcion,e.detpeditem,p.adescri as Producto,e.detpedcantpedida,e.detpedpreciopact,e.detpedmontoprecvta,m.empresadescripcion,m.empresadireccion,empresaruc,

case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str( a.pedidototbruto,9,2)) as Bruto,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str(a.pedidototimpuesto,9,2))  as Igv,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end + ltrim(str(a.pedidototneto, 9,2)) as Total,

'''+@Letras+''' as Letras,d.formapagodescripcion as PagoDescripcion,v.vendedornombres,
a.pedidomensaje

from ['+@base+'].dbo.cotizalibre a 
inner join ['+@base+'].dbo.detallecotizalibre e on a.pedidonumero=e.pedidonumero
inner join ['+@base+'].dbo.gr_documento b on a.pedidotipofac=b.documentocodigo
inner join ['+@base+'].dbo.vt_formapago d on a.formapagocodigo=d.formapagocodigo
inner join ['+@base+'].dbo.maeart p on e.productocodigo=p.acodigo
inner join ['+@base+'].dbo.co_multiempresas m on a.empresacodigo=m.empresacodigo
inner join ['+@base+'].dbo.vt_vendedor v on a.vendedorcodigo=v.vendedorcodigo
where a.empresacodigo='+@empresa+' and a.pedidotipofac='+@Tipodoc+' and  a.pedidonumero='+@nrodoc+'  ' 

exec(@cadena)
-- EXEC vt_ImprimirCotizacion 'ziyaz','31000000006','03','0','26,167.96910'

/*
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str( a.pedidototbruto,9,2)) as Bruto,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str(a.pedidototimpuesto,9,2))  as Igv,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end + ltrim(str(a.pedidototneto, 9,2)) as Total,
*/
GO
