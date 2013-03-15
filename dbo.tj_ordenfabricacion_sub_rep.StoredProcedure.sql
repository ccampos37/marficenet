SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [tj_ordenfabricacion_sub_rep]
@base varchar(50),
@base2 varchar(50),
@pedido varchar(5),
@producto varchar(20),
@orden varchar(5)
as
declare @ncade as nvarchar(2000)
declare @npara as nvarchar(2000)
set @ncade=N'
select a.* 
from ['+@base+'].dbo.tj_hiloxordendefabricacion a
inner join ['+@base+'].dbo.tj_cabeceraordendefabricacion b 
on a.tjordenum=b.tjordenum 
   and a.detorditem=b.detorditem
   and a.acodigo=b.acodigo
where a.tjordenum = '''+@pedido+'''
and a.acodigo = '''+@producto+''' 
and a.detorditem = '''+@orden+'''
'
set @npara=N'@pedido varchar(5),@producto varchar(20),@orden varchar(5)'
execute sp_executesql @ncade,@npara,@pedido,@producto,@orden
GO
