SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [tj_repoconsistencia_rep]
@base varchar(50),
@base2 varchar(50),
@tipo varchar(1),
@fini varchar(10),
@ffin varchar(10),
@orden integer
as 
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0' 
	begin
		Set @ncade=N'SELECT a.tjordenum,
												 a.cabordfecdoc,
												 d.partenume,	
												 d.partefecha,	
												 b.detordkgs,
												 a.clientecodigo,
												 f.clienterazonsocial,
												 c.detorditem,
												 c.fecha,
												 b.acodigo,
						             g.adescri,	
									       e.detalleturno,
												 e.codope,	 
									  		 d.cod_mq,
												 e.detallerollo,
												 e.detallepeso				 			 
									FROM ['+@base+'].dbo.tj_cabeceraorden a
									inner join ['+@base+'].dbo.tj_detalleorden b
									on a.tjordenum=b.tjordenum
									inner join ['+@base+'].dbo.tj_cabeceraordendefabricacion c
									on c.tjordenum=b.tjordenum and c.acodigo=b.acodigo
									inner join ['+@base+'].dbo.tj_parteproduccion d
									on d.tjordenum=c.tjordenum and d.acodigo=c.acodigo and d.detorditem=c.detorditem
									inner join ['+@base+'].dbo.tj_detparteproduccion e
									on e.partenume=d.partenume
									inner join ['+@base2+'].dbo.vt_cliente f
									on f.clientecodigo=a.clientecodigo COLLATE Modern_Spanish_CI_AS
									inner join ['+@base2+'].dbo.maeart g
									on g.acodigo=b.acodigo COLLATE Modern_Spanish_CI_AS
									Where a.cabordfecdoc>=@fini and a.cabordfecdoc<=@ffin'
				set @npara=N'@fini varchar(10),
										 @ffin varchar(10)'
				--execute sp_executesql @ncade,@npara,@fini,@ffin
				print @ncade
	end
if @tipo='1'
	begin
		Set @ncade=N'SELECT a.tjordenum,
												 a.cabordfecdoc,
												 d.partenume,	
												 d.partefecha,	
												 b.detordkgs,
												 a.clientecodigo,
												 f.clienterazonsocial,
												 c.detorditem,
												 c.fecha,
												 b.acodigo,
						             g.adescri,	
									       e.detalleturno,
												 e.codope,	 
									  		 d.cod_mq,
												 e.detallerollo,
												 e.detallepeso				 			 
									FROM ['+@base+'].dbo.tj_cabeceraorden a
									inner join ['+@base+'].dbo.tj_detalleorden b
									on a.tjordenum=b.tjordenum
									inner join ['+@base+'].dbo.tj_cabeceraordendefabricacion c
									on c.tjordenum=b.tjordenum and c.acodigo=b.acodigo
									inner join ['+@base+'].dbo.tj_parteproduccion d
									on d.tjordenum=c.tjordenum and d.acodigo=c.acodigo and d.detorditem=c.detorditem
									inner join ['+@base+'].dbo.tj_detparteproduccion e
									on e.partenume=d.partenume
									inner join ['+@base2+'].dbo.vt_cliente f
									on f.clientecodigo=a.clientecodigo COLLATE Modern_Spanish_CI_AS
									inner join ['+@base2+'].dbo.maeart g
									on g.acodigo=b.acodigo COLLATE Modern_Spanish_CI_AS
									Where a.tjordenum=@orden'
				set @npara=N'@orden integer'
				--execute sp_executesql @ncade,@npara,@orden
				print @ncade
	end
GO
