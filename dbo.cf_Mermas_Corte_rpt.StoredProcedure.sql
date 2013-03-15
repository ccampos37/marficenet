SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  PROCEDURE [cf_Mermas_Corte_rpt]
--declare
@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)
as
--set @base='sanildefonso'
declare @cadena as varchar(1000)
set @cadena='
select a.cortenumero,a.cortefecha,SUM(b.detallecortekgs)AS kgs_cortados,(a.cortekgsretazos+a.cortekgsmerma) AS kgs_merma
from ['+@base+'].dbo.cf_cabecerahojacorte a
inner join ['+@base+'].dbo.cf_detallehojacortetela b
		 on a.cortenumero=b.cortenumero
where a.cortefecha>='''+@fechaini+''' and a.cortefecha<='''+@fechafin+'''
group by a.cortenumero,a.cortefecha,a.cortekgsretazos,a.cortekgsmerma
'		
exec (@cadena)
--print(@cadena)
-- exec cf_hojadehabilitado_rpt 'desarrollo5'
GO
