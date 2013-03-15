SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_replistabloquesdeconfeccion_rep]
@base varchar(50),
@proceso varchar(10)
as
Declare @ncade as nvarchar(1000)
Declare @npara as nvarchar(1000)
set @ncade=N'select b.procesoscodigo,b.procesosconfeccion,
					a.bloquescodigo,a.bloquesdescripcion,
					case when bloquesimpresiontickets=1 then ''S'' else ''N'' end as estado
			 from ['+@base+'].dbo.cf_bloquesdeconfeccion a
					inner join ['+@base+'].dbo.cf_procesosdeconfeccion b
					on a.procesoscodigo=b.procesoscodigo
			 where a.procesoscodigo like @proceso
			 order by a.procesoscodigo'
set @npara=N'@proceso varchar(10)'
execute sp_executesql @ncade,@npara,@proceso
GO
