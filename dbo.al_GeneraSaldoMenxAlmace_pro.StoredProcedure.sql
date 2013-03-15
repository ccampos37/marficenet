SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute al_GeneraSaldoMenxAlmace_pro 'ziyaz','02','201112','201201' 
select * from ziyaz.dbo.al_movresmes set taalma=''

*/

CREATE proc [al_GeneraSaldoMenxAlmace_pro]
@base varchar(50),
@empresa varchar(2),
@mesant varchar(6),
@mesact varchar(6)
as
declare @sql varchar(4000)

set @sql=' delete from '+@base+'.dbo.al_movresmes where empresacodigo='''+@empresa+''' and smmespro='''+@mesact +''' and taalma <>'''' '
execute (@sql) 

set @sql=' insert '+@base+'.dbo.al_movresmes ( EMPRESACODIGO, PUNTOVTACODIGO, taalma,smmespro,smcodigo,smsaldoini, smmnvali, smmnprefin )
select EMPRESACODIGO,puntovtacodigo ,taalma,smmespro='''+@mesact+''',SMCODIGO,saldouni=SUM(smsaldocant) ,saldosoles=SUM(SMMNVALI), 
precio= round(case when SUM(smsaldocant) =0 then 0 else SUM(SMMNVALI)/ SUM(smsaldocant) end,4) from
( 
select EMPRESACODIGO,puntovtacodigo ,taalma,SMCODIGO,smsaldocant=(SMSALDOINI+SMCANENT -SMCANSAL ),
SMMNVALI=(SMMNVALI+SMMNENT-smmnsal) from '+@base+'.dbo.AL_MOVRESMES 
where empresacodigo='''+@empresa+'''  and smmespro='''+@mesant+''' and taalma <>'''' 
union all
select EMPRESACODIGO,puntovtacodigo ,caalma,deCODIGO,saldouni=case when catipmov=''I'' then decantid else DECANTID*-1 end ,
total=case when catipmov=''I'' then decantid*ISNULL(deprecio,0) else decantid*ISNULL(deprecio,0) *-1 end 
from '+@base+'.dbo.v_kardexvalorizado
where almacenempresa='''+@empresa+''' and  mesproceso='''+@mesact+''' 
) z group by EMPRESACODIGO,puntovtacodigo ,taalma,SMCODIGO '

execute (@sql)
GO
