SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [cf_secuencia_modelo_sub]
@base varchar(100),
@modelo varchar(20)
as
Declare @SqlCad Varchar(8000)
set @SqlCad='
select a.ordennumero, sum(b.ordencanpedida) as TotalCorte,
d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,d.modelotiempo
from ['+@base+'].dbo.cf_cabeceraordendefabricacion a
inner join ['+@base+'].dbo.cf_detalleordendefabricacion b
on a.ordennumero = b.ordennumero
inner join ['+@base+'].dbo.cf_secuenciaxmodelos d
on a.modelocodigo = d.modelocodigo
inner join ['+@base+'].dbo.cf_operaciones e
on d.operacioncodigo = e.operacioncodigo
inner join ['+@base+'].dbo.cf_Tipo_Maquina f
on e.maquinacodigo = f.maquinacodigo
where a.modelocodigo='''+@modelo+'''
group by a.ordennumero,d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,d.modelotiempo
'
Exec(@SqlCad)
GO
