SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [al_kardexDetxestab_rpt] 'xx_almacen_ziyaz','02','03','201101','201012','%%','%%'


*/

CREATE procedure [al_kardexDetxestab_rpt]

@base  varchar(50),
@empresa char(2),
@puntovta varchar(2),
@mesact varchar(6),
@mesant varchar(6),
@codigo1 varchar(20),
@codigo2 varchar(20)
as
Declare @cadena1 nvarchar(4000)
Declare @cadena2 nvarchar(4000)

set @cadena1=' select COD_ART=smcodigo, DESCRIPCION=adescri, 
    FEC_DOC=''01/''+right(smmespro,2)+''/''+left(smmespro,4)+'''', HOR_DOC='' '',COD_MOV='' '' ,TIP_TRANSA=''I'',
    DES_TRANSA='' saldo Inicial '', NUM_DOC=''S.INICIAL '', CAN_ART=smsaldoini+smcanent-smcansal, PRE_UNIT=smmnpreuni, COS_PRO=smmnpreuni,
    SAL_STOCK=0,SER_LOT='' '',ING_SAL='''', alma='''' ,cacodmon=''''
	from '+@base+'.dbo.al_movresmes a 
	inner join '+@base+'.dbo.maeart d on a.smcodigo=acodigo 
	where empresacodigo='''+@empresa+''' and smmespro='''+@mesant+''' and puntovtacodigo='''+@puntovta+''' '

if @codigo2='%%' and @codigo1<>'%%' set @cadena1=@cadena1+' and smcodigo='''+@codigo1+''' ' 


set @cadena2=' union all
    select COD_ART=decodigo, DESCRIPCION=adescri, FEC_DOC=cafecdoc, HOR_DOC='' '',COD_MOV=cacodmov ,TIP_TRANSA=catipmov,
    DES_TRANSA=tt_descri , NUM_DOC=canumdoc , CAN_ART=decantid, PRE_UNIT=deprecio , COS_PRO=0, SAL_STOCK=0,SER_LOT='' '', 
	ING_SAL=catipmov, alma=caalma , cacodmon
	from '+@base+'.dbo.movalmcab a 
	inner join '+@base +'.dbo.movalmdet b on a.caalma+a.catd+a.canumdoc=b.dealma+b.detd+b.denumdoc
	inner join '+@base+'.dbo.tabtransa c on a.cacodmov=c.tt_codmov
	inner join '+@base+'.dbo.maeart d on b.decodigo=acodigo 
	inner join '+@base+'.dbo.tabalm e on a.caalma=taalma 
	where a.empresacodigo='''+@empresa+''' and 
          right( Replicate(''0'',4)+rtrim(ltrim(cast(year(cafecdoc)as varchar(4)))),4)+
	      right( Replicate(''0'',2)+rtrim(ltrim(cast(month(cafecdoc)as varchar(2)))),2)='+@mesact+'
	      and isnull(a.casitgui,'' '')=''V'' '
if @codigo2='%%' and @codigo1<>'%%' set @cadena2=@cadena2+' and decodigo='''+@codigo1+''' ' 

execute(@cadena1+@cadena2)
GO
