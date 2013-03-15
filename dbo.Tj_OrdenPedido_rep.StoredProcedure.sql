SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Tj_OrdenPedido_rep]
@base as varchar(50),
@base2 as varchar(50),
@FechaInicio as varchar(10),
@FechaFin as varchar(10),
@numorden as varchar(20)
as
declare @cadena as nvarchar(1000)
declare @condi as varchar(1000)
---declare @c as varchar(2)
----set @c='13'
set @cadena='select a.tjordenum,a.cabordfecdoc,a.cabordfecentrega,                    
					a.cabordnrorecep,a.cabord_oc_ref,a.clientecodigo,
					a.cabpedcorrel,a.tipoempre,b.acodigo,c.adescri,b.detordtitulo,
					b.detordancho,b.detorddensidad,b.detordkgs,b.detordcolor,
					b.detordcolorcodigo,b.detordrendim,b.detordhilocodigo 
				from ['+@base+'].dbo.tj_cabeceraorden a 
				inner join ['+@base+'].dbo.tj_detalleorden b on 
					a.tjordenum=b.tjordenum
				left join ['+@base2+'].dbo.maeart c on 
					b.acodigo=c.acodigo COLLATE Modern_Spanish_CI_AS
				where a.cabordfecdoc>='''+@FechaInicio+''' and a.cabordfecdoc<='''+@FechaFin+''''
if len(rtrim(ltrim(@Numorden)))>0
	begin
		set @condi=' and a.tjordenum like '''+@numorden+''' '
	end
execute(@cadena+@condi)
GO
