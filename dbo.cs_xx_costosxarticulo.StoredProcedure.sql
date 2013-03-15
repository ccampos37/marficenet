SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_actualizagastos 'planta10','planta_casma','01/02/2008','29/02/2008','1'
select decencos,* from planta_casma.dbo.movalmdet where decodigo='10342'
*/
create PROC [cs_xx_costosxarticulo]
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)
as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)
declare @totalingresos float ,@totalegresos float
set @anno=year(@fechaini)
set @mes =month(@fechaini)


set @sql='select * from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  '
execute(@sql)
GO
