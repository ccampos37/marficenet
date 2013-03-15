SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec al_requerimientos ziyaz
*/

CREATE    procedure [al_requerimientos]
@base as varchar(50)
as

declare @cadena as nvarchar(2000)

SET @cadena =N'select a.stalma as CodAlm,d.tadescri as Almacen,b.pedidofecha as Fecha,a.stcodigo as Codigo,b.adescri as Producto,
	a.stskdis as Stock,
	isnull((sum(b.detpedcantpedida)-isnull(sum(decantid),0)),0) as Pedido,
	floor(isnull(c.stskdis,0)) as Receta,
	Requerido=(a.stskdis)-(isnull((sum(b.detpedcantpedida)-isnull(sum(decantid),0)),0))
from ['+@base+'].dbo.stkart a 
	left join ['+@base+'].dbo.v_almacenyventas b on a.stalma=b.almacencodigo and  a.stcodigo=b.productocodigo
	left join (select stalma,codkit,stskdis=min(stskdis)
			from 
			(select stalma,codkit,codart,stskdis=(stskdis)/canart 
				from  ['+@base+'].dbo.kits b  
				inner join  ['+@base+'].dbo.stkart c on codart=stcodigo) z 
	group by stalma,codkit) c on a.stalma=c.stalma and a.stcodigo=c.codkit
	inner join ['+@base+'].dbo.tabalm d on a.stalma=d.taalma

where a.stalma like ''%'' and a.stcodigo like ''%'' AND a.stcodigo<>''210001'' and a.stcodigo<>''7000000005''
group by a.stalma,a.stcodigo,c.stskdis,a.stskdis,b.adescri,b.pedidofecha,d.tadescri
having isnull((sum(b.detpedcantpedida)-isnull(sum(decantid),0)),0)>0 and 
(a.stskdis)-(isnull((sum(b.detpedcantpedida)-isnull(sum(decantid),0)),0))<0
order by 1,3'

exec(@cadena)
GO
