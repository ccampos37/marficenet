SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_resumenesmensualesGeneral_rpt 'planta_casma','01/01/2008','31/05/2008','01'

*/
CREATE   PROC [cs_resumenesmensualesGeneral_rpt]

@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@moneda varchar(2)='02'

as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @annoini varchar(4),@mesini varchar(2)
declare @annofin varchar(4),@mesfin varchar(2)
declare @totalingresos varchar(20) ,@totalegresos float

set @annoini=year(@fechaini)
set @mesini =month(@fechaini)
set @annofin=year(@fechafin)
set @mesfin =month(@fechafin)

If Exists(Select name from tempdb..sysobjects where name='##ingresos') 
    Drop Table ##ingresos 

If Exists(Select name from tempdb..sysobjects where name='##ingresos') 
    Drop Table ##totingresos 

set @sql = 'select mes=mesproceso ,ingresos=sum(importesoles)
    into ##ingresos from  '+@base+'.dbo.cs_resumenxmesplantillas
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2))  and
        n1=''01''  group by mesproceso '

execute ( @sql)


set @sql='select n1,grupo1,n2,grupo2,estructuradescripcion=estructuranumerolinea+''-''+estructuradescripcion,
          importe01= sum(case when right(mesproceso,2) =''01'' then importesoles else 0 end),
          importedol01= sum(case when right(mesproceso,2) =''01'' then importedolares else 0 end),
         costo01=sum(case when right(mesproceso,2) =''01'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe02= sum(case when right(mesproceso,2) =''02'' then importesoles else 0 end),
          importedol02= sum(case when right(mesproceso,2) =''02'' then importedolares else 0 end),
          costo02=sum(case when right(mesproceso,2) =''02'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe03= sum(case when right(mesproceso,2) =''03'' then importesoles else 0 end),
          importedol03= sum(case when right(mesproceso,2) =''03'' then importedolares else 0 end),
          costo03=sum(case when right(mesproceso,2) =''03'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe04= sum(case when right(mesproceso,2) =''04'' then importesoles else 0 end),
          importedol04= sum(case when right(mesproceso,2) =''04'' then importedolares else 0 end),
          costo04=sum(case when right(mesproceso,2) =''04'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe05= sum(case when right(mesproceso,2) =''05'' then importesoles else 0 end),
          importedol05= sum(case when right(mesproceso,2) =''05'' then importedolares else 0 end),
          costo05=sum(case when right(mesproceso,2) =''05'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe06= sum(case when right(mesproceso,2) =''06'' then importesoles else 0 end),
          importedol06= sum(case when right(mesproceso,2) =''06'' then importedolares else 0 end),
          costo06=sum(case when right(mesproceso,2) =''06'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe07= sum(case when right(mesproceso,2) =''07'' then importesoles else 0 end),
          importedol07= sum(case when right(mesproceso,2) =''07'' then importedolares else 0 end),
          costo07=sum(case when right(mesproceso,2) =''07'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe08= sum(case when right(mesproceso,2) =''08'' then importesoles else 0 end),
          importedol08= sum(case when right(mesproceso,2) =''08'' then importedolares else 0 end),
          costo08=sum(case when right(mesproceso,2) =''08'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe09= sum(case when right(mesproceso,2) =''09'' then importesoles else 0 end),
          importedol09= sum(case when right(mesproceso,2) =''09'' then importedolares else 0 end),
          costo09=sum(case when right(mesproceso,2) =''09'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe10= sum(case when right(mesproceso,2) =''10'' then importesoles else 0 end),
          importedol10= sum(case when right(mesproceso,2) =''10'' then importedolares else 0 end),
          costo10=sum(case when right(mesproceso,2) =''10'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe11= sum(case when right(mesproceso,2) =''11'' then importesoles else 0 end),
          importedol11= sum(case when right(mesproceso,2) =''11'' then importedolares else 0 end),
          costo11=sum(case when right(mesproceso,2) =''11'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end),
          importe12= sum(case when right(mesproceso,2) =''12'' then importesoles else 0 end),
          importedol12= sum(case when right(mesproceso,2) =''12'' then importedolares else 0 end),
          costo12=sum(case when right(mesproceso,2) =''12'' then 
                       case when '''+@moneda+'''=''01'' then 
                              importesoles/ingresos else importedolares/ingresos end
                      else 0 end)
          from '+@base+'.dbo.cs_resumenxmesplantillas
          inner join   ##ingresos on mesproceso=mes
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2))  and
        n1<>''01'' 
       group by n1,grupo1,n2,grupo2,estructuranumerolinea,estructuradescripcion
  order  by n1,estructuranumerolinea '

execute(@sql)
GO
