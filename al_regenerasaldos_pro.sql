SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute al_RegeneraSaldos_pro 'ALITERm2012','01'

select * from aliterm2012.dbo.stkart  where stCODIGO='c01010129'
*/
ALTER proc [al_RegeneraSaldos_pro]
@base varchar(50),
@alma varchar(2)
as

declare @sql varchar(4000)
set @sql ='insert '+@base+'.dbo.stkart ( stalma,stcodigo) 
SELECT DISTINCT dealma,deCODIGO FROM '+@base+'.dbo.movalmdet  
WHERE  dealma+decodigo NOT IN  ( SELECT X=stalma+stcodigo FROM '+@base+'.dbo.stkart where STalma='''+@alma+''' )
and dealma='''+@alma+'''  '

execute(@sql)

set @sql=' update '+@base+'.dbo.stkart set stskdis=0 where stalma='''+@alma+''' '

execute(@sql)
 
set @sql='update '+@base+'.dbo.stkart set stskdis=ingresos-salidas
from '+@base+'.dbo.stkart a ,
(  select dealma,decodigo,ingresos=round(sum(case catipmov when ''I'' then round(decantid,2) else 0 end),2),
   salidas=round(sum(case catipmov when ''S'' then round(decantid,2) else 0 end),2)
   from '+@base+'.dbo.movalmcab 
   inner join '+@base+'.dbo.movalmdet on catd+caalma+canumdoc= detd+dealma+denumdoc  
   where dealma='''+@alma+''' and isnull(casitgui,'''')<>''A'' group by dealma,decodigo 
 ) b 
 where a.stalma+a.stcodigo=b.dealma+b.decodigo    '

execute (@sql) 
