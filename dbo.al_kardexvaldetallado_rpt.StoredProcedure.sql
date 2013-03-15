SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
execute al_kardexvaldetallado_rpt 'ziyaz','02','03','21','201201','100010','999999' 

select * from ziyaz_2011_ult.dbo.movalmdet where depreci1 > 0

*/


CREATE      procedure [al_kardexvaldetallado_rpt]
@base varchar(50),
@empresa varchar(2),
@puntovta varchar(2),
@almacen varchar(2),
@mesproceso varchar(6),
@codigo1 varchar(20),
@codigo2 varchar(20)
as
declare @cadena as nvarchar(4000)
set @cadena='select zz.*,adescri,puntovtadescripcion,tadescri from 
( select tipo=2,puntovtacodigo, dealma,CACODMOV , catipmov, catd,canumdoc, 
carftdoc=case when carfndoc='''' then isnull(catipotransf,'''') else carftdoc end,
carfndoc=case when carfndoc='''' then isnull(canrotransf,'''') else carfndoc end,
moneda=case when cacodmon=''01'' then ''S/.'' else ''US$'' end ,
catipotransf, canrotransf,cafecdoc,DECODIGO, DECANTID=case when catipmov=''I'' then decantid else decantid*-1 end , depreci1,DEPRECIO,
preciocompra=case when tipodecosto=''C'' then round(deprecio,4) else 0 end,transacciondescripcion 
from '+@base+'.dbo.v_kardexvalorizado  aa 
where almacenempresa='''+@empresa+''' and almacenvalorizado=1 and mesproceso='''+@mesproceso +''' and decodigo>='''+@codigo1+ ''' and decodigo<='''+@codigo2+'''' 
if @puntovta <>'%%' set @cadena =@cadena + ' and puntovtacodigo='''+@puntovta +''''   
if @almacen <>'%%'  set @cadena =@cadena + ' and dealma='''+@almacen +''''
set @cadena=@cadena + ' union all
select TIPO=1 ,puntovtacodigo,taalma, ''  '',''I'','''','''','''',''SALDO INICIAL'',''S/.'',
'''','''','''',smcodigo,SMSALDOINI,0, precio=case when SMSALDOINI=0 then 0 else SMMNVALI/SMSALDOINI end, 0,''SALDO INICIAL''
from '+@base+'.dbo.AL_MOVRESMES bb
where EMPRESACODIGO='''+@empresa+''' and smmespro='''+@mesproceso+''' and smcodigo>='''+@codigo1+ ''' and smcodigo<='''+@codigo2+''''
if @puntovta <>'%%' set @cadena =@cadena + ' and puntovtacodigo='''+@puntovta +''''   
if @almacen <>'%%'  set @cadena =@cadena + ' and taalma='''+@almacen +''''
set @cadena =@cadena +' ) zz 
inner join ['+@base+'].dbo.maeart b on zz.decodigo=acodigo
left  join ['+@base+'].dbo.vt_puntoventa c on zz.puntovtacodigo=c.puntovtacodigo
inner join ['+@base+'].dbo.tabalm d on zz.dealma=d.taalma '

execute(@cadena)
GO
