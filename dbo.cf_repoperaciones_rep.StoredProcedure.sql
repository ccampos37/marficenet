SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_repoperaciones_rep]
@base varchar(50),
@tela varchar(20),
@maquina varchar(20)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
set @ncade=N'Select  
			  b.telacodigo,b.teladescripcion,
			  c.maquinacodigo,c.maquinadescripcion,
			  d.familiacodigo,d.familiadescripcion,
			  a.operacioncodigo,a.operaciondescripcion,
			  a.operaciontiempo,a.estadoperacioncodigo							
			 From ['+@base+'].dbo. cf_operaciones a 
			  inner join ['+@base+'].dbo.cf_tipo_tela b
			  on a.telacodigo=b.telacodigo	
			  inner join ['+@base+'].dbo.cf_tipo_maquina c
			  on a.maquinacodigo=c.maquinacodigo
			  inner join ['+@base+'].dbo.cf_familia_operaciones d
			  on a.familiacodigo=d.familiacodigo
		    Where a.telacodigo like @tela and a.maquinacodigo like @maquina'
set @npara=N'@tela varchar(20),@maquina varchar(20)'
execute sp_executesql @ncade,@npara,@tela,@maquina
GO
