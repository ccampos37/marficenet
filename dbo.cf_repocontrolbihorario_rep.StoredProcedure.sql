SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_repocontrolbihorario_rep]
@base varchar(50),
@fecha varchar(10),
@orden varchar(20)
as
Declare @ncade as nvarchar(4000)
Declare @npara as nvarchar(2000)
/*
						  sum(case  when	a.secuenciaxpqteestado=''1'' then 1 else 0 end) as a,
						  sum(case  when	a.secuenciaxpqteestado=''2'' then 1 else 0 end) as b,
						  sum(case  when	a.secuenciaxpqteestado=''3'' then 1 else 0 end) as c,
						  sum(case  when	a.secuenciaxpqteestado=''4'' then 1 else 0 end) as d,							
						  sum(case  when	a.secuenciaxpqteestado=''5'' then 1 else 0 end) as e,
						  sum(case  when	a.secuenciaxpqteestado=''6'' then 1 else 0 end) as f,
						  sum(case  when	a.secuenciaxpqteestado=''7'' then 1 else 0 end) as g,
						  sum(case  when	a.secuenciaxpqteestado=''8'' then 1 else 0 end) as h,
						  sum(case  when	a.secuenciaxpqteestado=''9'' then 1 else 0 end)	as i						
*/
set @ncade=N'Select a.secuenciacorrelativo,c.operacioncodigo,a.personalcodigo,b.personalapellidopaterno,b.personalapellidomaterno,b.personalnombres,
						  sum(case  when	a.secuencialectura=''1'' then 1 else 0 end) as a,
						  sum(case  when	a.secuencialectura=''2'' then 1 else 0 end) as b,
						  sum(case  when	a.secuencialectura=''3'' then 1 else 0 end) as c,
						  sum(case  when	a.secuencialectura=''4'' then 1 else 0 end) as d,							
						  sum(case  when	a.secuencialectura=''5'' then 1 else 0 end) as e,
						  sum(case  when	a.secuencialectura=''6'' then 1 else 0 end) as f,
						  sum(case  when	a.secuencialectura=''7'' then 1 else 0 end) as g,
						  sum(case  when	a.secuencialectura=''8'' then 1 else 0 end) as h,
						  sum(case  when	a.secuencialectura=''9'' then 1 else 0 end)	as i						
							From ['+@base+'].dbo.cf_secuenciaxpaqte A
								inner join ['+@base+'].dbo.cf_personal B
								 on a.personalcodigo=b.personalcodigo
								inner join ['+@base+'].dbo.cf_secuenciaoperaciones C
								 on a.ordennumero=c.ordennumero and a.secuenciacorrelativo=c.secuenciacorrelativo
						 where a.secuenciafechalectura=@fecha and a.ordennumero like @orden
  	  				group by a.secuenciacorrelativo,c.operacioncodigo,a.personalcodigo,b.personalapellidopaterno,b.personalapellidomaterno,b.personalnombres'
/*						 where a.secuenciaxpqtefecha=@fecha and a.ordennumero like @orden
  	  				group by a.secuenciacorrelativo,c.operacioncodigo,a.personalcodigo,b.personalapellidopaterno,b.personalapellidomaterno,b.personalnombres'
*/
set @npara=N'@fecha varchar(10),
						 @orden varchar(20)'
execute sp_executesql @ncade,@npara,@fecha,@orden
GO
