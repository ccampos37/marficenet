SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_analitico_rpt
exec ct_analitico_rpt 'migra2008','12','2008','00','00','%','%%','%','%%','%%','3','0',0,'0'
select * from ##ct_analitico


*/

CREATE            proc [ct_analitico_rpt]

(	@base 			varchar(50),
        @empresa		varchar(2),	 
        @anno 			varchar(4),
	@cabcomprobmesini	varchar(2),
	@cabcomprobmesfin	varchar(2),
	@cuentacodigo 		varchar(20),
	@asientocodigo 		varchar(3),
	@subasientocodigo 	varchar(3),
	@analiticocodigo 	varchar(14),
	@tipoanaliticocodigo 	varchar(3),
	@op   			char(1),  /** 2: Pendientes //  1:Cancelados  // 3:Todos  **/
	@detalle		char(1)='0',  /* 0:Detallado - 1:Resumido x Entidad - 2:Resumido x Cuenta */ 
        @modo                   integer=0 ,  /* 0: sin archivo 1: con archivo */
	@AjusteDifCambio	char(1)='%'

)
as
declare @sqlcad as varchar(5000)
If Exists(Select name from tempdb.dbo.sysobjects where name ='##ct_analitico'+@empresa)
	Exec('Drop Table ##ct_analitico'+@empresa)

If @detalle = 0
 Begin
  set @sqlcad='SELECT DISTINCT --D.tipoanaliticocodigo, B.tipoanaliticodescripcion,
	A.analiticocodigo,A.monedacodigo,D.entidadcodigo, D.entidadruc,D.entidadrazonsocial,
	A.cuentacodigo,C.cuentadescripcion, 
	A.cabcomprobnumero,A.detcomprobitem,A.ctacteanaliticofechaconta,A.documentocodigo, 
	A.ctacteanaliticonumdocumento, 
	A.ctacteanaliticofechadoc, 
	A.ctacteanaliticoglosa, 
	A.ctacteanaliticodebe, 
	A.ctacteanaliticohaber, 
	A.ctacteanaliticoussdebe, 
	A.ctacteanaliticousshaber, 
	A.ctacteanaliticocancel,
	A.operacioncodigo,D.tipoanaliticocodigo '
 End
If @detalle = 1
 Begin
  Set @sqlcad = 'SELECT DISTINCT --D.tipoanaliticocodigo, B.tipoanaliticodescripcion, 
	A.analiticocodigo,A.monedacodigo,D.entidadcodigo,D.entidadruc,D.entidadrazonsocial,
	A.cuentacodigo,C.cuentadescripcion,
	'''+' '+''' as cabcomprobnumero,'''+' '+''' as detcomprobitem,'''+' '+''' as ctacteanaliticofechaconta,
	'''+' '+''' as documentocodigo,'''+' '+''' as ctacteanaliticonumdocumento,
	'''+' '+''' as ctacteanaliticofechadoc,'''+' '+''' as ctacteanaliticoglosa,
	sum(A.ctacteanaliticodebe) as ctacteanaliticodebe, 
	sum(A.ctacteanaliticohaber) as ctacteanaliticohaber, 
	sum(A.ctacteanaliticoussdebe) as ctacteanaliticoussdebe, 
	sum(A.ctacteanaliticousshaber) as ctacteanaliticousshaber, 
	'''+' '+''' as ctacteanaliticocancel,
	A.operacioncodigo,D.tipoanaliticocodigo '
 End 
If @detalle = 2
 Begin
  Set @sqlcad = 'SELECT DISTINCT --D.tipoanaliticocodigo, B.tipoanaliticodescripcion,
	 A.analiticocodigo,A.monedacodigo,D.entidadcodigo,D.entidadruc,D.entidadrazonsocial,
	A.cuentacodigo,C.cuentadescripcion,  
	'''+' '+''' as cabcomprobnumero,'''+' '+''' as detcomprobitem,'''+' '+''' as ctacteanaliticofechaconta,
	'''+' '+''' as documentocodigo,'''+' '+''' as ctacteanaliticonumdocumento,
	'''+' '+''' as ctacteanaliticofechadoc,'''+' '+''' as ctacteanaliticoglosa,
	sum(A.ctacteanaliticodebe) as ctacteanaliticodebe, 
	sum(A.ctacteanaliticohaber) as ctacteanaliticohaber, 
	sum(A.ctacteanaliticoussdebe) as ctacteanaliticoussdebe, 
	sum(A.ctacteanaliticousshaber) as ctacteanaliticousshaber, 
	'''+' '+''' as ctacteanaliticocancel,
	A.operacioncodigo,D.tipoanaliticocodigo '
 End

if @modo=1 set @sqlcad = @sqlcad + ' into ##ct_analitico'+@empresa

set @sqlcad = @sqlcad + ' FROM 
	[' +@base+ '].dbo.[ct_ctacteanalitico' +@anno+ '] A
	Inner join [' +@base+ '].dbo.ct_cuenta C On a.empresacodigo=c.empresacodigo and 
	A.cuentacodigo = C.cuentacodigo
	Inner Join [' +@base+ '].dbo.v_analiticoentidad D On A.analiticocodigo= D.analiticocodigo
	Inner join [' +@base+ '].dbo.ct_tipoanalitico B On B.tipoanaliticocodigo = D.tipoanaliticocodigo  '

	if @op='2'  -- pendientes
	BEGIN	
		set @sqlcad=@sqlcad + '  Inner Join  ( Select  aa.empresacodigo, AA.CuentaCodigo,AA.analiticocodigo,AA.DocumentoCodigo,AA.ctacteanaliticonumdocumento,
saldoS= sum(Round(AA.ctacteanaliticodebe,2)) - sum(round(AA.ctacteanaliticohaber,2)),
saldoD= sum(Round(AA.ctacteanaliticoussdebe,2)) - sum(round(AA.ctacteanaliticousshaber ,2))
     From [' +@Base+ '].dbo.ct_ctacteanalitico' +@Anno+ ' AA 
     Where Aa.analiticocodigo<>''00'' and Aa.cabcomprobmes<='+@cabcomprobmesfin+' and aa.empresacodigo='''+@empresa+'''
     Group by aa.empresacodigo,Aa.CuentaCodigo,Aa.analiticocodigo,	   
	      Aa.documentocodigo,Aa.ctacteanaliticonumdocumento  ) zz On a.empresacodigo=zz.empresacodigo And a.cuentacodigo=zz.cuentacodigo 
And a.analiticocodigo=zz.analiticocodigo And a.documentocodigo=zz.documentocodigo And a.ctacteanaliticonumdocumento=zz.ctacteanaliticonumdocumento 
And ((zz.saldoS <>0 and a.monedacodigo=''01'') Or (zz.saldoD<>0 and a.monedacodigo=''02'')) '
	END
	if @op='1' -- cancelados
	BEGIN	
		set @sqlcad=@sqlcad +'  Inner Join  ( Select  aa.empresacodigo, AA.CuentaCodigo,AA.analiticocodigo,AA.DocumentoCodigo,AA.ctacteanaliticonumdocumento,
saldoS= sum(Round(AA.ctacteanaliticodebe,2)) - sum(round(AA.ctacteanaliticohaber,2)),
saldoD= sum(Round(AA.ctacteanaliticoussdebe,2)) - sum(round(AA.ctacteanaliticousshaber ,2))
     From [' +@Base+ '].dbo.ct_ctacteanalitico' +@Anno+ ' AA 
     Where Aa.analiticocodigo<>''00'' and Aa.cabcomprobmes<='+@cabcomprobmesfin+' and aa.empresacodigo='''+@empresa+'''
     Group by aa.empresacodigo,Aa.CuentaCodigo,Aa.analiticocodigo,	   
	      Aa.documentocodigo,Aa.ctacteanaliticonumdocumento  ) zz On a.empresacodigo=zz.empresacodigo And a.cuentacodigo=zz.cuentacodigo 
And a.analiticocodigo=zz.analiticocodigo And a.documentocodigo=zz.documentocodigo And a.ctacteanaliticonumdocumento=zz.ctacteanaliticonumdocumento 
And ((zz.saldoS =0 and a.monedacodigo=''01'') Or ( zz.saldoD=0 and a.monedacodigo=''02'')) '
	END

set @sqlcad = @sqlcad + ' WHERE
	a.empresacodigo='''+@empresa+''' and 
   	A.cabcomprobmes BETWEEN ' +@cabcomprobmesini+ ' AND ' +@cabcomprobmesfin+ ' AND
	A.cuentacodigo LIKE ''' +@cuentacodigo+ ''' AND 
        c.cuentaestadoanalitico=1 and 
	A.asientocodigo LIKE ''' +@asientocodigo+ ''' AND
	A.subasientocodigo LIKE ''' +@subasientocodigo+ ''' AND
   	A.analiticocodigo LIKE ''' +@analiticocodigo+ ''' 
	AND B.tipoanaliticocodigo LIKE ''' +@tipoanaliticocodigo+ ''' 
	And isnull(A.ctacteanaliticoajustedifcambio,''0'') LIKE '''+@AjusteDifCambio+''' '
	
If @detalle = 1
 Begin
  Set @sqlcad =@sqlcad + ' Group By A.cuentacodigo,-- D.tipoanaliticocodigo, B.tipoanaliticodescripcion,
	A.analiticocodigo,D.entidadcodigo,D.entidadruc,D.entidadrazonsocial,C.cuentadescripcion, A.operacioncodigo,D.tipoanaliticocodigo,A.monedacodigo'
 End 
If @detalle = 2
 Begin
  Set @sqlcad = @sqlcad + ' Group By  A.cuentacodigo,-- D.tipoanaliticocodigo, B.tipoanaliticodescripcion,
	A.analiticocodigo,D.entidadcodigo,D.entidadruc,D.entidadrazonsocial,C.cuentadescripcion, A.operacioncodigo,D.tipoanaliticocodigo,A.monedacodigo'
 End
execute(@sqlcad)
--print(@sqlcad)
GO
