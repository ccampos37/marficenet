SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_resumenesmensualesIngresos_rpt 'planta10','planta_casma','01/01/2008','31/03/2008','01'

*/
CREATE   PROC [cs_resumenesmensualesIngresos_rpt]

@baseorigen varchar(50),
@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@moneda varchar(2)='01'

as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @annoini varchar(4),@mesini varchar(2)
declare @annofin varchar(4),@mesfin varchar(2)
declare @totalingresos float ,@totalegresos float

set @annoini=year(@fechaini)
set @mesini =month(@fechaini)
set @annofin=year(@fechafin)
set @mesfin =month(@fechafin)

set @sql='select a.n2 ,a.grupo2,importes=case when '''+@moneda+'''=''01'' then a.importesoles else a.importedolares end,
              mesproceso=left(a.mesproceso,4)+''-''+right(a.mesproceso,2) ,a.gastoscodigo,a.gastosdescripcion 
         from '+@base+'.dbo.cs_resumenxmesplantillas a
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2)) 
        and tipo=''I'' and a.importesoles > 0 
 order  by a.n1,a.n2,a.estructuranumerolinea '

execute(@sql)
GO
