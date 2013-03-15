SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute vt_impresionpagoscaja_rpt 'ziyaz','01/01/2009','06/01/2009','01'

*/


CREATE     procedure [vt_impresionpagoscaja_rpt]
@base varchar(50),
@fechadesde varchar(10),
@fechahasta varchar(10),
@cajerocodigo varchar(2)

as

declare @cadena as nvarchar(2000)

/*
SET @cadena =N'select a.pedidonumero,b.monedacodigo,b.monedadescripcion,c.formapagocodigo,
c.formapagodescripcion,d.cajerocodigo,d.cajeroapellidos,d.cajeronombres,a.pagotipocodigo,
a.pagonumdoc,a.pagoimporte,a.pagotipodecambio,a.estadocierre,a.fechacierre,a.horacierre,
f.pedidofecha
from ['+@base+'].dbo.vt_pagosencaja a,['+@base+'].dbo.gr_moneda b,['+@base+'].dbo.vt_formapago c,
['+@base+'].dbo.vt_cajeros d,['+@base+'].dbo.vt_pedido f
where a.monedacodigo=b.monedacodigo and a.pagocodigo=c.formapagocodigo 
and a.cajerocodigo=d.cajerocodigo and a.pedidonumero=f.pedidonrofact and 
f.pedidofecha between ''' +@fechadesde+ ''' and ''' +@fechahasta+ ''' 
and d.cajerocodigo=''' +@cajerocodigo+ ''''
*/
SET @cadena =N'select a.pedidonumero,b.monedacodigo,b.monedadescripcion,c.formapagocodigo,
c.formapagodescripcion,d.cajerocodigo,d.cajeroapellidos,d.cajeronombres,a.pagotipocodigo,
a.pagonumdoc,a.pagoimporte,a.pagotipodecambio,a.estadocierre,a.fechacierre,a.horacierre
,f.pedidofecha
from ['+@base+'].dbo.vt_pagosencaja a
inner join ['+@base+'].dbo.gr_moneda b on a.monedacodigo=b.monedacodigo
inner join ['+@base+'].dbo.vt_formapago c on a.pagocodigo=c.formapagocodigo 
inner join  ['+@base+'].dbo.vt_cajeros d on a.cajerocodigo=d.cajerocodigo
inner join  ['+@base+'].dbo.vt_pedido f on a.pedidonumero=f.pedidonumero
where f.pedidofecha between ''' +@fechadesde+ ''' and ''' +@fechahasta+ ''' 
and d.cajerocodigo=''' +@cajerocodigo+ '''and f.pedidocondicionfactura<>''1'''



exec(@cadena)
-- EXEC vt_impresionpagoscaja_rpt 'xx'
GO
