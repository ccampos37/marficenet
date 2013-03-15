SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    Procedure [ser_reposervicioscance_rep]
@base varchar(50),
@base2 varchar(50),
@provee varchar(15),
@fini varchar(10),
@ffin varchar(10),
@empresa varchar(2)
as
Declare @ncade as nvarchar(1000)
Declare @npara as nvarchar(1000)
Set @ncade=N'Select a.empresa_codigo,guia_tipo_factu,guia_nro_factu,guia_fecha_factu,guia_tipo,guia_nro,d.cafecdoc,
			c.prvccodigo,c.prvcnombre,a.servicio_orden,b.servicio_moneda,(b.servicio_total*(1-.18)) as valor,(b.servicio_total*.18) as igv,b.servicio_total
			from ['+@base+'].dbo.control_guia_factura A
			inner join ['+@base+'].dbo.control_servicio B
			on a.empresa_codigo=b.empresa_codigo and
		    a.servicio_orden=b.servicio_orden
			inner join ['+@base2+'].dbo.maeprov C
			on  b.servicio_proveedor=c.prvccodigo COLLATE Modern_Spanish_CI_AI  
			inner join ['+@base2+'].dbo.movalmcab D
			on d.catd=a.guia_tipo COLLATE Modern_Spanish_CI_AI  and 
               d.canumdoc=a.guia_nro COLLATE Modern_Spanish_CI_AI  and 
               d.canumord=a.servicio_orden  COLLATE Modern_Spanish_CI_AI  
			where b.servicio_proveedor like @provee and d.cafecdoc>=@fini and 
				  d.cafecdoc<=@ffin and a.empresa_codigo like @empresa and 
				  not a.guia_tipo_factu is null'
Set @npara=N'@provee varchar(15),@fini varchar(10),	@ffin varchar(10),@empresa varchar(2)'
execute sp_executesql @ncade,@npara,@provee,@fini,@ffin,@empresa
GO
