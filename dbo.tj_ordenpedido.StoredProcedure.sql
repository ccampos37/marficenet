SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [tj_ordenpedido]
@base varchar(50),
@base2 varchar(50),
@base3 varchar(50),
@corre varchar(10)
as
declare @ncade as nvarchar(2000)
declare @npara as nvarchar(2000)
set @ncade=N'
select a.tjordenum,a.cabordfecdoc,a.cabordfecentrega,a.cabordnrorecep,
		a.caborddocrecep,g.descri_doc,
		a.cabord_oc_ref,a.clientecodigo,
		c.clientecodigo,c.clienteruc,c.clienterazonsocial,
		a.cabpedcorrel,a.tipoempre,
		a.cabordservicio,f.descri_servi,
		a.cabordreferencia,e.descri_refe,
		a.cabordestado,a.observacion,a.cabordfeccomprometida,a.cabordfecrecepcion,
		b.tjordenum,b.acodigo,
		d.adescri,		
		b.detordtitulo,b.detordancho,
		b.detorddensidad,b.detordkgs,b.detordcolor,b.detordcolorcodigo,
		b.detordrendim,b.detordhilocodigo,b.detsaldo,b.detunimedida,
		h.cod_color,i.descr_pnt,h.cantidad,h.acabado,h.proceso        
from ['+@base+'].dbo.tj_cabeceraorden a
inner join ['+@base+'].dbo.tj_detalleorden b
on a.tjordenum = b.tjordenum
inner join ['+@base2+'].dbo.vt_cliente c
on a.clientecodigo=c.clientecodigo collate Modern_Spanish_CS_AI
inner join ['+@base2+'].dbo.maeart d
on b.acodigo=d.acodigo collate Modern_Spanish_CS_AI
left join ['+@base+'].dbo.tj_servicio f
on a.cabordservicio=f.cod_servicio 
left join ['+@base+'].dbo.tj_referencia e
on a.cabordreferencia=e.cod_referencia 
left join ['+@base+'].dbo.tj_documento_ref g
on g.cod_documento=a.caborddocrecep
left join ['+@base+'].dbo.tj_det_detalleorden h
on a.tjordenum=h.tjordenum
and b.acodigo=h.acodigo
left join ['+@base3+'].dbo.pantone i
on h.cod_color=i.cod_pnt collate Modern_Spanish_CS_AI
where a.tjordenum='''+@corre+''' 
'
set @npara=N'@corre varchar(10)'
execute sp_executesql @ncade,@npara,@corre
GO
