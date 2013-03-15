SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_resumenesmensualesGastos_rpt 'planta_casma','01/01/2008','31/03/2008','01'

*/
CREATE      PROC [cs_resumenesmensualesGastos_rpt]

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

set @sql='select grupo2=a.estructuranumerolinea+''-''+b.estructuradescripcion,importes=case when '''+@moneda+'''=''01'' then a.importesoles else a.importedolares end,
              mesproceso=left(a.mesproceso,4)+''-''+right(a.mesproceso,2) ,a.gastoscodigo,a.gastosdescripcion 
         from '+@base+'.dbo.cs_resumenxmesplantillas a
          inner join '+@base+'.dbo.cs_estructurapresentacion b on a.estructuranumerolinea=b.estructuranumerolinea
          inner join '+@base+'.dbo.co_gastos c on a.gastoscodigo=c.gastoscodigo
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2)) 
        and b.tipocodigo=''G'' and a.importesoles > 0 and left(c.gastoscodigo,2) not in (''01'',''02'')
 order  by a.n1,a.n2,a.estructuranumerolinea '

execute(@sql)
GO
