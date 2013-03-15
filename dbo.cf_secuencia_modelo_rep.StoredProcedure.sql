SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [cf_secuencia_modelo_rep]
@base varchar(50),
@modelo varchar(20)
as
Declare @SqlCad nVarchar(4000)
Declare @StadoPara varchar(2)
Declare @npara as varchar(50)
set @StadoPara='2'
--g.bloquesdescripcion,
set @SqlCad='
select a.modelocodigo,c.modelodescripcion,a.serviciofechaentrega,
a.ordennumero,a.tipotallascodigo,
(select top 1 ['+@base+'].dbo.Configura_talla(a.tipotallascodigo) 
from ['+@base+'].dbo.cf_tallasxtipodetallas
where tipotallascodigo=a.tipotallascodigo) as talla,
sum(b.ordencanpedida) as TotalCorte,
d.modelosecuencia,
d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,d.modelotiempo,e.bloquescodigo,g.bloquesdescripcion,
estado=case when e.estadoperacioncodigo<>'''+@StadoPara+''' then CAST( ''*'' AS varchar(4)) end 
from ['+@base+'].dbo.cf_cabeceraordendefabricacion a
inner join ['+@base+'].dbo.cf_detalleordendefabricacion b
on a.ordennumero = b.ordennumero
inner join ['+@base+'].dbo.cf_modelos c
on a.modelocodigo = c.modelocodigo
inner join ['+@base+'].dbo.cf_secuenciaxmodelos d
on a.modelocodigo = d.modelocodigo
inner join ['+@base+'].dbo.cf_operaciones e
on d.operacioncodigo = e.operacioncodigo
inner join ['+@base+'].dbo.cf_Tipo_Maquina f
on e.maquinacodigo = f.maquinacodigo
inner join ['+@base+'].dbo.cf_bloquesdeconfeccion g
on e.bloquescodigo = g.bloquescodigo
and e.procesoscodigo = g.procesoscodigo
where d.modelocodigo='''+@modelo+'''
group by a.modelocodigo,c.modelodescripcion,a.serviciofechaentrega,
a.ordennumero,a.tipotallascodigo,
d.modelosecuencia,
d.operacioncodigo,e.operaciondescripcion,e.maquinacodigo,
f.Maquinadescripcion,d.modelotiempo,e.estadoperacioncodigo,e.bloquescodigo,g.bloquesdescripcion
'
--set @npara=N'@numeroorden varchar(20)'
--execute sp_executesql @SqlCad,@npara,@numeroorden
Exec(@SqlCad)
GO
