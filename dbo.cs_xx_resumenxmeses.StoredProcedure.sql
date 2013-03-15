SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_resumenxmeses 'planta10','planta_casma','200801','200802',2

*/
CREATE    PROC [cs_xx_resumenxmeses]
@baseorigen varchar(50),
@basedestino varchar(50),
@mesprocesoinicial varchar(6),
@mesprocesofinal varchar(6),
@numero as integer
as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)


set @sql=' 
select n1=n1+'' ''+grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso=''PROMEDIO'',
importes=''IMPORTES'', importe=sum(importe)/3
from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >='''+@mesprocesoinicial+'''and mesproceso <='''+@mesprocesofinal+'''and importe > 0
group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso
union all
select n1=n1+'' ''+grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso=''PROMEDIO'',
importes=''PORCENTAJES'', importe=sum(porcentaje)/3
from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >='''+@mesprocesoinicial+'''and mesproceso <='''+@mesprocesofinal+''' and importe > 0
group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso
UNION ALL
select n1=n1+'' ''+grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso,
importes=''IMPORTES'',importe=sum(importe)
 from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >='''+@mesprocesoinicial+'''and mesproceso <='''+@mesprocesofinal+'''and importe > 0
group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso
union all
select n1=n1+'' ''+grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso,
importes=''PORCENTAJES'',importes=sum(porcentaje)
 from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >='''+@mesprocesoinicial+'''and mesproceso <='''+@mesprocesofinal+''' and importe > 0
group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion,mesproceso
order by n1 ,n2 '


execute(@sql)
GO
