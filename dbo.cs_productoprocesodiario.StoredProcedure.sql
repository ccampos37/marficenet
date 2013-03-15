SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Objetivo: Reporte de produccion por dia , producto valores
execute cs_productoprocesodiario 'planta10','planta_casma','020200','01/01/2008','31/01/2008'
select * from planta_casma.dbo.ct_centrocosto
*/
CREATE        proc [cs_productoprocesodiario]
 
@Baseorigen varchar(50),
@basedestino varchar(50),
@linea varchar(6),
@fechainicial varchar(10),
@fechafinal varchar(10)
As
Declare @SqlCad varchar(8000)	
Set @SqlCad=''+
'select nn=''02'',x='''+@linea+''',proceso,producto_id,adescri,
cantidadproducida=sum(peso_total-tara),
importepagado=sum(case when peso_total-tara > b.valormaximo  then 
               b.valormaximo * b.precio/isnull(factordepago,1)
             else (peso_total-tara)* b.precio / isnull(factordepago,1) end)
--into ##temp020200
from '+@baseorigen+'.dbo.control_peso a
inner join '+@baseorigen+'.dbo.tarifa_productos b on a.id_tarifa=b.id_tarifa
inner join '+@basedestino+'.dbo.maeart c on a.producto_id=c.acodigo
where fecha_proceso between '''+@fechainicial+''' and '''+@fechafinal+'''
group by proceso,a.producto_id,c.adescri  '
execute (@sqlcad)
GO
