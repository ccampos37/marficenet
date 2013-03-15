SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*

EXECUTE  [dbo].[al_kardexvalTransaccion_rpt] 'ZIYAZ', '02','201201','1'
select  x=decantid*deprecio,decantid,deprecio, cafecdoc, cacosmov,* from v_kardexvalorizado where mesproceso='201201' and cacodmov='98' 
order by 1 desc

*/

CREATE     procedure [al_kardexvalTransaccion_rpt]
(
@base varchar(50),
@empresa varchar(2),
@aaaamm varchar(6),
@tipo char(1)
)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT empresadescripcion,a.tipotransadescripcion, cacodmov,
    tipo= case when a.catipmov=''I'' then
           ''INGRESOS'' else ''SALIDAS '' end, familiadescripcion,
    transacciondescripcion, puntovtadescripcion ,
    monto=round(sum((case when catipmov=''I'' then 1 else -1 end)* decantid*deprecio),2)
    FROM ['+@base+'].dbo.v_kardexvalorizado a 
    where almacenempresa='''+@empresa+'''and mesproceso='''+@aaaamm+''' 
    group by empresadescripcion,a.tipotransadescripcion,puntovtadescripcion,cacodmov, 
         transacciondescripcion , catipmov , familiadescripcion
    having round(sum(decantid*deprecio),2)<> 0  '

execute (@NCADENA)
--EXEC al_kardexvaltransaccion_rpt 'ziyaz','02','201001',1


--- select * from ziyaz.dbo.v_kardexvalorizado
GO
