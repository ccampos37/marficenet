SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute vt_cajeroxdia_rpt 'ziyaz','28/07/2008','%%','0'

*/


CREATE proc [vt_cajeroxdia_rpt]

@base varchar(50),
@fecha varchar(19),
@codigocajero varchar(2),
@tipo varchar(1)='0'

as
declare @sql as varchar(4000)

set @sql=' select pago=(select pagodescripcion from '+@base+'.dbo.vt_conceptosdepago b where b.pagocodigo=a.pagocodigo),
     pagotipo=(select pagotipodescripcion from '+@base+'.dbo.vt_conceptostipodepago b where 
               b.pagocodigo=a.pagocodigo and b.pagotipocodigo=a.pagotipocodigo ),
     b.pedidonumero,pagonumdoc,
     importesoles=case when monedacodigo=''01'' then pagoimporte else 0 end,
     importedolares=case when monedacodigo=''02'' then pagoimporte else 0 end
     from '+@base+'.dbo.vt_pagosencaja a 
     left join '+@base+'.dbo.vt_pedido b on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero
--     left join '+@base+'.dbo.vt_cajeros c on a.cajerocodigo=c.cajerocodigo
 ' 

EXECUTE(@sql)

-- select * from ziyaz.dbo.vt_pagosencaja
GO
