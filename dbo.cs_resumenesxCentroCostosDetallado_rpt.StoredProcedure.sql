SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [cs_resumenesxCentroCostosDetallado_rpt] 'planta_casma','01/05/2012','31/05/2012',2.706,'01'

*/
CREATE PROC [cs_resumenesxCentroCostosDetallado_rpt]

@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@tipodecambio varchar(10),
@moneda varchar(2)='01'

as
declare  @sql varchar(4000),@sql1 varchar(8000)
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

set @sql = 'select tipo=1, ingresos=sum(importesoles)
    into ##ingresos from  '+@base+'.dbo.cs_resumenxmesplantillasNuevo
  where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
        and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2))  and
        tipo=''I''  '

execute ( @sql)


set @sql='Select n1,grupo1,n2,grupo2,n3,grupo3,estructuranumerolinea,estructuradescripcion,ingresos,tc='+@tipodecambio+',codigo=gastoscodigo+'' ''+gastosdescripcion,
                   l101s=sum(case when centrocostocodigo1=''101'' then  importe else 0 end),
                   l101d=sum(case when centrocostocodigo1=''101'' then  porcentaje else 0 end),
                   l102s=sum(case when centrocostocodigo1=''102'' then  importe else 0 end),
                   l102d=sum(case when centrocostocodigo1=''101'' then  porcentaje else 0 end),
                   l103s=sum(case when centrocostocodigo1=''103'' then  importe else 0 end),
                   l103d=sum(case when centrocostocodigo1=''103'' then  porcentaje else 0 end),
                   l104s=sum(case when centrocostocodigo1=''104'' then  importe else 0 end),
                   l104d=sum(case when centrocostocodigo1=''104'' then  porcentaje else 0 end),
                   l105s=sum(case when centrocostocodigo1=''105'' then  importe else 0 end),
                   l105d=sum(case when centrocostocodigo1=''105'' then  porcentaje else 0 end),
                   l106s=sum(case when centrocostocodigo1=''301'' then  importe else 0 end),
                   l106d=sum(case when centrocostocodigo1=''301'' then  porcentaje else 0 end),
                   l107s=sum(case when centrocostocodigo1=''302'' then  importe else 0 end),
                   l107d=sum(case when centrocostocodigo1=''302'' then  porcentaje else 0 end),
                   l100s=sum(isnull(case when centrocostocodigo1=''00'' then  importe else 0 end,0)),
                   l100d=sum(isnull(case when centrocostocodigo1=''00'' then  porcentaje else 0 end,0))
                  from ( select tipo1=1, centrocostocodigo1=case when ( isnull(centrocostocodigo,''00'')=''00'' or rtrim(centrocostocodigo)='''' 
                                         or left(centrocostocodigo,1)=''4'' ) then ''00'' 
                                            else left(centrocostocodigo,3) end ,importe=importesoles, importedol=importedolares,* 
                              from '+@base+'.dbo.cs_resumenxmesplantillasNuevo a
                              where mesproceso >=ltrim(str('+@annoini+')+right(''00''+ltrim(str('+@mesini+')) ,2)) 
                                    and mesproceso <=ltrim(str('+@annofin+')+right(''00''+ltrim(str('+@mesfin+')) ,2))  
                                    and tipo=''E'' and importesoles > 0 
                        ) z
                        inner join ##ingresos zz on z.tipo1=zz.tipo 
                         group by n1,grupo1,n2,grupo2,n3,grupo3,estructuranumerolinea,estructuradescripcion , ingresos, gastoscodigo,gastosdescripcion  '       
execute(@sql)
--select estructuranivel,  * from planta_casma.dbo.cs_estructurapresentacionnuevo
GO
