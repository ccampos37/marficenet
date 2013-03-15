SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [vt_formato_venta] 'ZIYAZ','31/08/2008','30/09/2008'

CREATE        PROC [vt_formato_venta]		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10)

AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'select a.clienterazonsocial,a.pedidonrofact,a.pedidofecha,d.adescri,b.unidadcodigo,b.detpedimpbruto,
b.detpedcantpedida,e.vendedornombres,f.tipocontactodescripcion,h.pagodescripcion
from ['+@base+'].dbo.vt_pedido a 
inner join ['+@base+'].dbo.vt_detallepedido b on a.pedidonumero=b.pedidonumero
inner join ['+@base+'].dbo.gr_documento c on a.pedidotipofac=c.documentocodigo
inner join ['+@base+'].dbo.maeart d on b.productocodigo=d.acodigo
left join ['+@base+'].dbo.vt_vendedor e on a.vendedorcodigo=e.vendedorcodigo
left join ['+@base+'].dbo.vt_tipodecontacto f on a.tipocontactocodigo=f.tipocontactocodigo
left join ['+@base+'].dbo.vt_pagosencaja g on a.pedidonrofact=g.pedidonumero
left join ['+@base+'].dbo.vt_conceptosdepago h on g.pagocodigo=h.pagocodigo
where a.pedidofecha between '''+@fecdesde+''' and '''+@fechasta+''''

--print(@sensql)
exec (@sensql)
RETURN
GO
