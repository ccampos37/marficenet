SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [al_SaldosNegXDia_rpt] 'ziyaz','##70554751'
*/


CREATE proc [al_SaldosNegXDia_rpt]
@base varchar(50),
@computer varchar(50)
as

declare @sql varchar(4000)

set @sql='select caalma,almacendescripcion,decodigo,codigodescripcion , cafecdoc,catipmov, decantid,saldo 
from ['+@computer +'_neg] ' 

execute(@sql)
GO
