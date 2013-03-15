SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [tj_repordenfabricacion_rep]
@base varchar(50),
@base2 varchar(50),
@tipo varchar(1),
@fechaini varchar(10),
@fechafin varchar(10),
@orden varchar(20)
as
declare @ncade as nvarchar(2000)
declare @npara as nvarchar(2000)
if @tipo='0'
   Begin
			set @ncade=N'Select b.acodigo,d.adescri,a.tjordenum,c.fecharec,b.dethilokgs,
													b.dethilocodigo,b.dethilodeta,b.dethiloproveedor,
													b.dethilolote
										from ['+@base+'].dbo.tj_detordendefabricacion a
										inner join ['+@base+'].dbo.tj_hiloxordendefabricacion b
										on a.tjordenum=b.tjordenum and a.acodigo=b.acodigo and a.detorditem=b.detorditem and a.detordcorrel=b.detordcorrel
										inner join ['+@base+'].dbo.tj_cabeceraordendefabricacion C
										on a.tjordenum=c.tjordenum and a.acodigo=c.acodigo and a.detorditem=c.detorditem
										left join ['+@base2+'].dbo.maeart d 
										on b.acodigo=d.acodigo COLLATE Modern_Spanish_CI_AS
										where c.fecharec>=@fechaini and c.fecharec<=@fechafin'
 			 set @npara=N'@fechaini varchar(10),
										@fechafin varchar(10)'
			Execute sp_executesql @ncade,@npara,@fechaini,
																				@fechafin
	  End
if @tipo='1'
	Begin
			Set @ncade=N'Select b.acodigo,d.adescri,a.tjordenum,c.fecharec,b.dethilokgs,
													b.dethilocodigo,b.dethilodeta,b.dethiloproveedor,
													b.dethilolote
										from ['+@base+'].dbo.tj_detordendefabricacion a
										inner join ['+@base+'].dbo.tj_hiloxordendefabricacion b
										on a.tjordenum=b.tjordenum and a.acodigo=b.acodigo and a.detorditem=b.detorditem and a.detordcorrel=b.detordcorrel
										inner join ['+@base+'].dbo.tj_cabeceraordendefabricacion C
										on a.tjordenum=c.tjordenum and a.acodigo=c.acodigo and a.detorditem=c.detorditem
										left join ['+@base2+'].dbo.maeart d 
										on b.acodigo=d.acodigo COLLATE Modern_Spanish_CI_AS
										where a.detorditem like @orden'
 			 Set @npara=N'@orden varchar(10)'
   		 Execute sp_executesql @ncade,@npara,@orden
	End
GO
