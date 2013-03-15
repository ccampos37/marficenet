SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [cf_movimiento_corte_rpt]
--declare
@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)
--@nrocorte varchar(10)
as
--set @base='sanildefonso'
declare @cadena as varchar(1000)
set @cadena='
select a.cortenumero,a.cortefecha,
		 a.cortecodigotizador,e.personalnombres as nom_tizador,e.personalapellidomaterno as ape_pat_tizador,e.personalapellidopaterno as ape_mat_tizador,
		 a.cortecodigocortador,f.personalnombres as nom_cortador,f.personalapellidomaterno as ape_pat_cortador,f.personalapellidopaterno as ape_mat_cortador,
		 a.cortekgsretazos,a.cortekgsmerma,b.codigotela,b.colorcodigo,d.colordescripcion,b.detallecortekgs 
from ['+@base+'].dbo.cf_cabecerahojacorte a
inner join ['+@base+'].dbo.cf_detallehojacortetela b
		 on a.cortenumero=b.cortenumero
inner join ['+@base+'].dbo.cf_colores d
		 on b.colorcodigo=d.colorcodigo
inner join ['+@base+'].dbo.cf_personal e
		 on a.cortecodigotizador=e.personalcodigo
inner join ['+@base+'].dbo.cf_personal f
		 on a.cortecodigocortador=f.personalcodigo
where a.cortefecha>='''+@fechaini+''' and a.cortefecha<='''+@fechafin+'''
order by a.cortenumero '
---and a.cortenumero like '''+@nrocorte+''' 
 
exec (@cadena)
--print(@cadena)
-- exec cf_hojadehabilitado_rpt 'desarrollo5'
GO
