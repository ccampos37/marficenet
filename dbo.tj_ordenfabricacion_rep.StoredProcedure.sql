SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [tj_ordenfabricacion_rep]
@base varchar(50),
@base2 varchar(50),
@pedido varchar(5),
@producto varchar(20),
@orden varchar(5)
as
declare @ncade as nvarchar(2000)
declare @npara as nvarchar(2000)
set @ncade=N'
select b.tjordenum,b.detorditem,b.acodigo,a.cabordtipohilo,
	   e.adescri,
	   f.detordrendim,f.detunimedida,
	   c.clientecodigo,c.tipoempre,
	   d.clienterazonsocial,
       a.cabordtitulo,a.cabordmezcla,a.cabordancho,a.caborddensidad,a.caborddiametro,
       a.cabordgalga,a.cabordacabado,a.cabordacabadotela,a.cabordkgs,
       a.fecha,a.fecharec,a.fechaentre,
       b.detordcorrel,b.detordkgs,b.detordkgsxrollo,b.detordrollo,b.detordlm
from ['+@base+'].dbo.tj_cabeceraordendefabricacion a 
inner join ['+@base+'].dbo.tj_detordendefabricacion b
on a.tjordenum=b.tjordenum 
   and a.detorditem=b.detorditem
   and a.acodigo=b.acodigo
inner join ['+@base+'].dbo.tj_cabeceraorden c
on a.tjordenum=c.tjordenum 
inner join ['+@base2+'].dbo.vt_cliente d
on c.clientecodigo=d.clientecodigo
inner join ['+@base2+'].dbo.maeart e 
on a.acodigo=e.acodigo COLLATE Modern_Spanish_CI_AS   
inner join ['+@base+'].dbo.tj_detalleorden f
on a.acodigo=f.acodigo COLLATE Modern_Spanish_CI_AS
AND c.tjordenum=f.tjordenum   
where a.tjordenum = '''+@pedido+'''
and a.acodigo = '''+@producto+''' 
and a.detorditem = '''+@orden+'''
'
set @npara=N'@pedido varchar(5),@producto varchar(20),@orden varchar(5)'
execute sp_executesql @ncade,@npara,@pedido,@producto,@orden
GO
