SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [vt_listamoviarti_rep]
@base varchar(50),
@fini varchar(10),
@ffin varchar(10),
@alma varchar(2),
@tipo varchar(1)
as
declare @ncade as nvarchar(1000)
declare @npara as nvarchar(1000)
if @tipo='1'     --Sin Movimiento
	Begin
		set @ncade=N'select K.*,F.ADESCRI,g.TADESCRI from ['+@base+'].dbo.stkart k 
					INNER JOIN ['+@base+'].dbo.maeart f
					on K.STCODIGO=F.ACODIGO
					inner join ['+@base+'].dbo.tabalm g
					on K.STalma=g.TAALMA
					WHERE 0=(SELECT COUNT(*) from ['+@base+'].dbo.movalmdet a inner join ['+@base+'].dbo.movalmcab b
							on a.dealma=b.caalma and a.detd=b.catd and a.denumdoc=b.canumdoc
							where cafecdoc >='''+@fini+''' and cafecdoc <='''+@ffin+''' AND K.STALMA=A.DEALMA 
					         AND K.STCODIGO=A.DECODIGO) AND STSKDIS>0 and stalma like @alma'
	end 
if @tipo='2'   --con movimiento
	begin
		set @ncade=N'select K.*,F.ADESCRI,g.TADESCRI from ['+@base+'].dbo.stkart k 
					INNER JOIN ['+@base+'].dbo.maeart f
					on K.STCODIGO=F.ACODIGO
					inner join ['+@base+'].dbo.tabalm g
					on K.STalma=g.TAALMA
					WHERE 0<(SELECT COUNT(*) from ['+@base+'].dbo.movalmdet a inner join ['+@base+'].dbo.movalmcab b
							on a.dealma=b.caalma and a.detd=b.catd and a.denumdoc=b.canumdoc
							where cafecdoc >='''+@fini+''' and cafecdoc <='''+@ffin+''' AND K.STALMA=A.DEALMA 
					         AND K.STCODIGO=A.DECODIGO) AND STSKDIS>0 and stalma like @alma'
	end 
set @npara=N'@fini varchar(10),@ffin varchar(10),@alma varchar(2)'
execute sp_executesql @ncade,@npara,@fini,@ffin,@alma
GO
