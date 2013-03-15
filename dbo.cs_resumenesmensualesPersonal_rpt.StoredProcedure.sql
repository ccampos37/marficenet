SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_resumenesmensualesPersonal_rpt 'planta_casma','01/01/2008','31/03/2008','01'

*/
CREATE        PROC [cs_resumenesmensualesPersonal_rpt]
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
declare @codigo varchar(2)



set @codigo=(select codigopersonalplantilla from planta_casma.dbo.cs_sistema ) 

set @annoini=year(@fechaini)
set @mesini =month(@fechaini)
set @annofin=year(@fechafin)
set @mesfin =month(@fechafin)

/*
set @sql=' declare @codigo varchar(2)
set @codigo=(select codigopersonalplantilla from '+@base+'.dbo.cs_sistema )' 
execute(@sql)
*/
set @sql=' select grupo2=a.estructuranumerolinea+''-''+a.estructuradescripcion,importes=case when '''+@moneda+'''=''01'' then importesoles else importedolares end,
              mesproceso=left(mesproceso,4)+''-''+right(mesproceso,2) ,gastoscodigo,gastosdescripcion 
         from '+@base+'.dbo.cs_resumenxmesplantillas a
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2)) 
        and n1='''+@codigo+''' and importesoles > 0 
 order  by n1,n2,estructuranumerolinea '

execute(@sql)
GO
