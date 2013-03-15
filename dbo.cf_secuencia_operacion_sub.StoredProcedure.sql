SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [cf_secuencia_operacion_sub]
--Declare
@base varchar(100),
@numeroorden varchar(20)
as
Declare
@SqlCad Varchar(8000)
set @SqlCad='
select a.ordennumero, sum(b.ordencanpedida) as TotalCorte,
d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,e.operaciontiempo
from ['+@base+'].dbo.cf_cabeceraordendefabricacion a
inner join ['+@base+'].dbo.cf_detalleordendefabricacion b
on a.ordennumero = b.ordennumero
inner join ['+@base+'].dbo.cf_secuenciaoperaciones d
on a.ordennumero = d.ordennumero
inner join ['+@base+'].dbo.cf_operaciones e
on d.operacioncodigo = e.operacioncodigo
inner join ['+@base+'].dbo.cf_Tipo_Maquina f
on e.maquinacodigo = f.maquinacodigo
where a.ordennumero='''+@numeroorden+'''
group by a.ordennumero,d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,e.operaciontiempo
'
Exec(@SqlCad)
GO
