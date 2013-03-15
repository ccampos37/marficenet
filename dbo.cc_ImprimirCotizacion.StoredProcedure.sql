SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cc_ImprimirCotizacion]
@base as varchar(50),
@nrodoc as varchar(11),
@bruto as varchar(15),
@igv as varchar(15),
@empresa as char(2),
@TipoDoc as varchar(11),
@Letras as varchar(255)

as
declare @cadena as nvarchar(2000)

SET @cadena =N'Select a.pedidonumero,a.pedidofecha,a.clienterazonsocial,a.clientecodigo,a.clientedireccion,
b.documentodescripcion,p.adescri as Producto,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str( '+@bruto+',9,2)) as Bruto,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end  + ltrim(str('+@igv+',9,2))  as Igv,
case a.pedidomoneda when ''01'' then ''S/.'' when ''02'' then ''US$.'' when ''03'' then ''e/.'' end + ltrim(str(a.pedidototneto, 9,2)) as Total,
'''+@Letras+''' as Letras,d.formapagodescripcion as PagoDescripcion

from ['+@base+'].dbo.cotizalibre a 
inner join ['+@base+'].dbo.detallecotizalibre e on a.pedidonumero=e.pedidonumero
inner join ['+@base+'].dbo.gr_documento b on a.pedidotipofac=b.documentocodigo
inner join ['+@base+'].dbo.vt_formapago d on a.formapagocodigo=d.formapagocodigo
inner join ['+@base+'].dbo.maeart p on e.productocodigo=p.acodigo
where a.empresacodigo='+@empresa+' and a.pedidotipofac='+@Tipodoc+' and  a.pedidonumero='+@nrodoc+'  ' 

exec(@cadena)
-- EXEC cc_ImprimirCotizacion 'ziyaz','00100000129',100,19,'01','00','Ciento Diecinueve con 00/100 Nuevos Soles'
GO
