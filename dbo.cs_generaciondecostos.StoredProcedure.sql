SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_generaciondecostos 'planta10','planta_casma','%%','17/01/2008','17/01/2008'
*/
CREATE  proc [cs_generaciondecostos]
@baseorigen varchar(50),
@basedestino varchar(50),
@producto varchar(50),
@desde varchar(10),
@hasta varchar(10)
as 
exec cs_productoprocesodiario @baseorigen, @basedestino, '020200','18/01/2008','18/01/2008'
/*
select aa='00',* from ##temp000000
union all
select aa='02',* from ##temp020200
union all
select aa='0'+cast(estructuranivel as varchar(1)),cast(estructuranivel as varchar(1)),estructuranumerolinea,0,estructuradescripcion,'',0,0
from planta_casma.dbo.cs_estructurapresentacion where estructuranivel <>3
order by 2
*/
GO
