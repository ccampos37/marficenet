SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [cf_detalleorden_rpt]
--declare
(
--	@Servidor 	varchar(50),
	@base varchar(50)
)
as
declare @sqlcad as varchar(3000)
set @sqlcad='
select 
a.ordennumero, a.colorcodigo, a.tallascodigo,
b.serviciofechaentrega,
a.ordencantdiacorte,a.ordencantsemanacorte, a.ordencantcorte,
a.ordentotcorte,(a.ordencantcorte/case when a.ordentotcorte=0 then 1 else a.ordentotcorte end)*100,
a.ordencanthabilitado,(a.ordencanthabilitado/case when a.ordentotcorte=0 then 1 else a.ordentotcorte end )*100,
a.ordencantdiaconfeccion, a.ordencantsemanaconfeccion,
acumuladoconfeccion=(a.ordencantconfeccionprimera+ a.ordencantconfeccionsegunda+ a.ordencantserviciosprimera+ a.ordencantserviciossegunda+ a.ordencantserviciossegunda+ a.ordencantsinconfeccionservicios),
a.ordencantconfeccionprimera, a.ordencantconfeccionsegunda+ a.ordencantsinconfeccionservicios,
a.ordentotconfeccion,
a.ordencantconfeccionprimera, a.ordencantconfeccionsegunda,
a.ordencantserviciosprimera,
a.ordencantsinconfeccion,
a.ordencantsinconfeccionservicios,
a.ordencantdiaacabado, a.ordencantsemanaacabado,
a.ordencantacabado,
a.ordentotacabado
from  ['+@base+'].dbo.cf_detalleordendefabricacion a
inner join ['+@base+'].dbo.cf_cabeceraordendefabricacion b 
on a.ordennumero  =b.ordennumero 
where b.ordencierre=0 '
exec(@sqlcad)
--execute cf_detalleorden_rpt 'produccion'
GO
