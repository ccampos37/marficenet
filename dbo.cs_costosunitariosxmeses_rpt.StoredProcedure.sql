SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_costosunitariosxmeses_rpt 'planta_casma','01/01/2008','31/03/2008','01'

*/

CREATE     PROC [cs_costosunitariosxmeses_rpt]
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

set @sql='select z.mesproceso,z.importesingresos,
            costo=case when z.importesingresos > 0 then (z.importesegresosobra+z.importesegresosgastos)/z.importesingresos else 0 end,
            mano_obra=z.importesegresosobra/importesingresos,
            gastos_generales=z.importesegresosgastos/importesingresos,
            empaque=z.empaque/z.importesingresos, plaqueado=z.plaqueado/z.importesingresos,
            produccion=z.produccion/z.importesingresos, 
            administracion=z.administracion/z.importesingresos,
            mantenimiento=z.mantenimiento/z.importesingresos,
            materiales_directos=z.directos/z.importesingresos,
            varios=z.varios/z.importesingresos
   from (  select importesingresos=sum(case when tipo=''I'' then 
                         case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                     else 0 end),
                importesegresosobra=sum(case when n1<>''02'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
                importesegresosgastos=sum(case when n1<>''03'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               empaque=sum(case when estructuranumerolinea<>''020119'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               plaqueado=sum(case when estructuranumerolinea<>''020218'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               produccion=sum(case when estructuranumerolinea<>''020301'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               administracion=sum(case when estructuranumerolinea<>''020302'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               mantenimiento=sum(case when estructuranumerolinea<>''030301'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               directos=sum(case when left(estructuranumerolinea,4)<>''0304'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),
               varios=sum(case when estructuranumerolinea<>''030304'' or tipo=''I''  then 0 
                           else  case when '''+@moneda+'''=''01'' then importesoles else importedolares end
                           end),

                mesproceso=left(mesproceso,4)+''-''+right(mesproceso,2) from '+@base+'.dbo.cs_resumenxmesplantillas 
          where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
                and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2)) and importesoles > 0 
           group by mesproceso 
      ) as z '

execute(@sql)
GO
