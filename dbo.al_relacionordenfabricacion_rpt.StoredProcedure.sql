SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [al_relacionordenfabricacion_rpt]
@base varchar(50),
@tipo varchar(1),
@ordfab varchar(10),
@fechaini varchar(10),
@fechafin varchar(10)
as 
declare @cadena varchar(1000)
set @cadena='
select z.deordfab,z.decodigo,saldo=sum(z.saldo) from 
(
select deordfab,decodigo,
saldo=case when catipmov=''I'' then decantid else decantid*-1 end
from [' +@base+ '].dbo.movalmdet inner join [' +@base+ '].dbo.movalmcab  
         on dealma+detd+denumdoc=caalma+catd+canumdoc 
where deordfab in ( select distinct deordfab from [' +@base+ '].dbo.movalmdet a 
                           inner join [' +@base+ '].dbo.movalmcab b 
                                 on dealma+detd+denumdoc=caalma+catd+canumdoc
                    where  b.casitgui=''V'' and rtrim(a.deordfab)<>'''''
 
if @tipo='1' set @cadena=@cadena+ ' and b.cafecdoc 
                           between '''+@fechaini+''' and '''+@fechafin+''')'
if @tipo='0' set @cadena=@cadena+' and a.deordfab like ('''+@ordfab+'''))'
set @cadena=@cadena+' 
 )as z
group by z.deordfab,z.decodigo
having sum(z.saldo)<>0 '
execute (@cadena)
---execute al_relacionordenfabricacion 'acop_centro','0','%%','01/01/2006','31/12/2006'
GO
