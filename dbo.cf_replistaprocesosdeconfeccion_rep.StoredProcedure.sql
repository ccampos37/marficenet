SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_replistaprocesosdeconfeccion_rep]
@base varchar(50)
as
Declare @ncade as nvarchar(1000)
set @ncade=N'select procesoscodigo,procesosconfeccion from ['+@base+'].dbo.cf_procesosdeconfeccion
			 order by procesoscodigo'
			
execute(@ncade)
GO
