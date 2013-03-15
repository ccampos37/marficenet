SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Objetivo: Reporte de produccion por dia , producto valores
execute cs_xx_producciondiaria 'planta10','planta_casma','17/01/2008','18/01/2008'
select * from planta10.dbo.procesos_det
select * from planta_casma.dbo.co_cabeceraprovisiones
where cabprovifchdoc be
*/
CREATE    proc [cs_xx_produccionProductosdiario]
 
@Baseorigen varchar(50),
@basedestino varchar(50),
@fechainicial varchar(10),
@fechafinal varchar(10)
As
Declare @SqlCad varchar(8000)	
declare @producto as varchar(20)
set @producto='select familiaproductoterminado from '+@basedestino+'.dbo.cs_sistema ' 
Set @SqlCad=''+
'select a.fecha_proceso,a.id_recepcion,b.id_recepcion,b.id_proceso,c.id_proceso,
c.id_producto_obtenido,d.acodigo
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
where a.fecha_proceso >= '''+@fechainicial+''' and a.fecha_proceso <='''+@fechafinal+''' order by 1'
execute(@sqlcad)
  
SET QUOTED_IDENTIFIER OFF
GO
