SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop  Procedure ct_ProcCanc_pro

execute ct_ProcCanc_pro 'planta_casma','01','2008','01','xx'
select * from planta_casma.dbo.ct_ctacteanalitico2008


*/
CREATE      Procedure [ct_ProcCanc_pro](
--Declare 
@BaseConta 	varchar(50),
@empresa varchar(2),
@Anno			varchar(4),
@Mes			varchar(2),
@NombrePC 	varchar(50)
)
as
Declare @sqlcad varchar(4000)
if exists(select name from tempdb.dbo.sysobjects where name='##DocCancela'+@NombrePC)
	exec('drop table ##DocCancela'+@NombrePC)

set @sqlcad= 'update [' +@BaseConta+ '].dbo.ct_ctacteanalitico' +@Anno+ '
        set ctacteanaliticocancel='''' 
        where ctacteanaliticocancel>='''+@anno+@mes+''' and 
              empresacodigo='''+@empresa+''' '
execute(@sqlcad)

set @sqlcad=' update [' +@BaseConta+ '].dbo.ct_ctacteanalitico' +@Anno+ ' 
    set ctacteanaliticocancel='''+@anno+@mes+'''
    from [' +@BaseConta+ '].dbo.ct_ctacteanalitico' +@Anno+ ' Y ,
(  select zz.* from 
   ( Select  aa.empresacodigo, AA.CuentaCodigo,AA.analiticocodigo,
	     AA.DocumentoCodigo,AA.ctacteanaliticonumdocumento,
	     saldoS= sum(Round(AA.ctacteanaliticodebe,2)) - 
			 sum(round(AA.ctacteanaliticohaber,2)),
	     saldoD= sum(Round(AA.ctacteanaliticoussdebe,2)) - 
			 sum(round(AA.ctacteanaliticousshaber ,2))
     From [' +@BaseConta+ '].dbo.ct_ctacteanalitico' +@Anno+ ' AA 
     Where Aa.analiticocodigo<>''00'' and ctacteanaliticocancel='''' and 
	   Aa.cabcomprobmes<='+@Mes+' and aa.empresacodigo='''+@empresa+'''
     Group by aa.empresacodigo,Aa.CuentaCodigo,Aa.analiticocodigo,	   
	      Aa.documentocodigo,Aa.ctacteanaliticonumdocumento 
    ) zz where zz.saldoS =0 and  zz.saldoD=0  
) ZZ
where y.empresacodigo=zz.empresacodigo and Y.analiticocodigo=ZZ.analiticocodigo and
      y.ctacteanaliticonumdocumento=ZZ.ctacteanaliticonumdocumento and
      Y.documentocodigo=ZZ.DocumentoCodigo 
      and  ctacteanaliticocancel='''' '

execute(@sqlcad)
GO
