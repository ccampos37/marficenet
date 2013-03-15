SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute al_produccionxprocesos_rpt 'newgreen','10','40','01/06/2008','30/06/2008'


*/
--SELECT * FROM maeart order by 3

CREATE     proc [al_produccionxprocesos_rpt]
@base varchar(50),
@almorig varchar(2),
@almdest varchar(2),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo integer=1

as
--drop table ##xx
declare @sql as varchar(4000)
Set @sql=''
If @tipo=1
begin
set @sql=' select zzz.cod2,sum(cant2),sum(cant1) from ( '
end
if @tipo=0
begin
set @sql=' 
select zz.canrotransf,zz.cafecdoc,zz.deitem,
cod1=a1.adescri,cant1,
cod2=a2.adescri,cant2 
from
(select canrotransf,cafecdoc,deitem ,cant1=sum(cant1),cant2=sum(cant2) from
( SELECT canrotransf,cafecdoc,deitem,
 cant1=case when catipmov=''S'' then   decantid else 0 end,
 cant2=case when catipmov=''I'' then   decantid*(c.pa* apeso) end
 from '+@base+'.dbo.movalmcab a
 inner join '+@base+'.dbo.movalmdet b on caalma+catd+canumdoc=dealma+detd+denumdoc
 inner join '+@base+'.dbo.maeart c on b.decodigo=c.acodigo
 where canrotransf in 
 ( select distinct canrotransf from '+@base+'.dbo.movalmcab where cafecdoc between '''+@fechaini +''' 
   and '''+@fechafin +''' and catipotransf=''TR'' and caalma='''+@almorig+''' and catipmov=''S'' 
   and casitgui<>''A'') and 
  isnull(decantid,0) > 0 
) as z
group by canrotransf,cafecdoc,deitem 
) as zz 
left join ( SELECT canrotransf,cafecdoc,deitem,decodigo,adescri from '+@base+'.dbo.movalmcab a 
              inner  join '+@base+'.dbo.movalmdet b on a.caalma+a.catd+a.canumdoc=b.dealma+b.detd+b.denumdoc and 
                     b.decantid > 0
             inner join '+@base+'.dbo.maeart c on b.decodigo=c.acodigo 
             WHERE a.canumdoc+a.canrotransf in ( select distinct canumdoc+canrotransf from '+@base+'.dbo.movalmcab 
                             where cafecdoc between '''+@fechaini +''' and '''+@fechafin +''' and 
                                   catipotransf=''TR'' and caalma='''+@almorig+''' and catipmov=''S'' ) 
                  and b.decantid >0 and a.catipmov=''S'' and a.casitgui<>''A''
	   ) as a1 on zz.canrotransf=a1.canrotransf and zz.deitem=a1.deitem

left join ( SELECT canrotransf,cafecdoc,deitem,decodigo,adescri from '+@base+'.dbo.movalmcab a 
              inner  join '+@base+'.dbo.movalmdet b on a.caalma+a.catd+a.canumdoc=b.dealma+b.detd+b.denumdoc and 
                     b.decantid > 0
             inner join '+@base+'.dbo.maeart c on b.decodigo=c.acodigo 
             WHERE a.canumdoc+a.canrotransf in ( select distinct canumdoc+canrotransf from '+@base+'.dbo.movalmcab 
                   where cafecdoc between '''+@fechaini +''' and '''+@fechafin+''' and catipotransf=''TR'' 
                  and caalma='''+@almdest+'''  and catipmov=''I'' and casitgui<>''A'' )
                  and b.decantid >0 and a.catipmov=''I''  ) as a2 on zz.canrotransf=a2.canrotransf and zz.deitem=a2.deitem '
print ( @sql)
end
if @tipo=1
begin
  set @sql=@sql+') as zzz group by  zzz.cod2 '

  execute(@sql)

end
GO
