SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_detalleresumenxmeses 'planta10','planta_casma','200801','200802'

*/
CREATE PROC [cs_xx_detalleresumenxmeses]
@baseorigen varchar(50),
@basedestino varchar(50),
@mesprocesoinicial varchar(6),
@mesprocesofinal varchar(6)
as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)


set @sql=' 
select n1=n1+'' ''+grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,gastosdescripcion,mesproceso,importe=sum(importe)
from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >='''+@mesprocesoinicial+''' and mesproceso <='''+@mesprocesofinal+''' and importe > 0 and tipo=''E''
group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,gastosdescripcion,mesproceso '


execute(@sql)
GO
