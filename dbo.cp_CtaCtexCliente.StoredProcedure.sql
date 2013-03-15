SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.cp_CtaCtexproveedor    fecha de la secuencia de comandos: 18/10/2006 03:12:52 p.m. ******/
/*
exec cp_CtaCtexproveedor 'ziyaz','ziyaZ','01/06/2010','08/08/2010','08/08/2010','%','20508814586','02'
drop proc [dbo].[cp_CtaCtexproveedor]
*/
CREATE       proc [cp_CtaCtexCliente] (
@base varchar(50),
@compu varchar(20),
@fechaini varchar(10),
@fechafin varchar(10),
@fecha varchar(10),
@codmoneda varchar(2),
@codcliente varchar(50),
@empresa varchar(2)
)
as
set nocount on
DECLARE @sqlcad varchar(3000)
declare @cadtmp varchar(2000)
set @cadtmp='SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
		B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
		B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
        	B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,b.abonocanflreg,
		B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,
		simbmonabo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=B.abonocanmoncan),
		B.abonocantipcam,
		B.abonocanbco,
		B.abonocanctabco
  		INTO ##tmp_saldodoc' +@compu+ '  
	FROM [' +@base+ '].dbo.vt_abono B,[' +@base+ '].dbo.cc_tipodocumento C
	where abonocancli =''*'' AND isnull(b.abonocanflreg,0)<>1 '
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldodoc'+@compu)
  exec('DROP TABLE ##tmp_saldodoc'+@compu)
exec(@cadtmp)
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldoinicial'+@compu)
exec('DROP TABLE ##tmp_saldoinicial' +@compu )
set @sqlcad='
	SELECT 	A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
			A.cargoapefecvct,A.bancocodigo,A.monedacodigo,
            cargoapeimpape=isnull(A.cargoapeimpape,0)*( case when E.tdocumentotipo=''C'' then 1 else -1 end )
            ,cargoapeimppag=isnull(A.cargoapeimppag,0),
            cargopagadoux=isnull(A.cargoapeimppag,0),	SaldoInicial=cast(0 as numeric(25,9)),A.cargoapeflgcan,A.cargoapecarabo,
 			Y.*,
 			E.tdocumentodescripcion,bancodescripcion=G.bancodescrcorta,I.clienteruc,I.clienterazonsocial,H.monedasimbolo
    	INTO 	##tmp_saldoinicial' +@compu+ '
	FROM 	[' +@base+ '].dbo.vt_cargo A, ##tmp_saldodoc' +@compu+ ' Y,
 			[' +@base+ '].dbo.cc_tipodocumento E,[' +@base+ '].dbo.gr_banco G,
			[' +@base+ '].dbo.gr_moneda H,[' +@base+ '].dbo.vt_cliente I
	WHERE 	A.clientecodigo*=Y.abonocancli AND A.documentocargo*=Y.documentoabono AND 
		A.cargonumdoc*=Y.abononumdoc AND A.documentocargo=E.tdocumentocodigo AND
		A.bancocodigo*=G.bancocodigo AND A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND a.empresacodigo like ('''+@empresa + ''') and 
                A.clientecodigo like ''' +@codcliente+ ''' AND A.monedacodigo like ''' +@codmoneda+ '''	AND
	        floor(cast(A.cargoapefecemi as real)) <=' + cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))  + ' AND
		A.cargoapeflgcan=0  AND isnull(A.cargoapeflgreg,0)<>1
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
EXECUTE(@sqlcad)
--IF @fecha<convert(varchar(10),getdate(),103)
--BEGIN
	exec('UPDATE ##tmp_saldoinicial' +@compu+ ' SET cargopagadoux=0')
	SET @sqlcad=''
	SET @sqlcad=N'
	UPDATE ##tmp_saldoinicial' +@compu+ ' SET ##tmp_saldoinicial' +@compu+ '.cargopagadoux=Y.saldoactual
				FROM ##tmp_saldoinicial' +@compu+ ' A,
			(SELECT B.abonocancli,B.documentoabono,B.abononumdoc,
                   saldoactual=SUM(ISNULL(B.abonocanimpsol,0)* ( case when tdocumentocodigo =''C'' then 1 else -1 end ))
			FROM [' +@base+ '].dbo.vt_abono B,[' +@base+ '].dbo.cc_tipodocumento C,
 					(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.vt_cargo D, [' +@base+ '].dbo.cc_tipodocumento E
	 							where FLOOR(CAST(cargoapefecemi AS REAL)) <=' + CAST(DBO.fn_datenumber(DAY(@fecha),MONTH(@fecha),YEAR(@fecha)) as varchar(20)) +  '  AND  cargoapeflgcan=0 AND
								cargoapeflgreg IS NULL AND D.documentocargo=E.tdocumentocodigo ) AS Z
	 		WHERE 	B.abonocancli=Z.clientecodigo AND B.documentoabono=Z.documentocargo AND B.abononumdoc=Z.cargonumdoc AND
					FLOOR(CAST (B.abonocanfecan AS REAL)) <='  + CAST(DBO.fn_datenumber(DAY(@fecha),MONTH(@FECHA),YEAR(@FECHA)) AS VARCHAR(20)) + ' AND 
					B.abonocantdqc=C.tdocumentocodigo AND isnull(b.abonocanflreg,0)<>1 and
					B.abonocancli like ''' +@codcliente+   '''
        	GROUP BY B.abonocancli,B.documentoabono,B.abononumdoc) as Y
		WHERE A.clientecodigo=Y.abonocancli AND A.documentocargo=Y.documentoabono AND
	  		A.cargonumdoc=Y.abononumdoc'
	exec(@sqlcad)
--END
exec('UPDATE ##tmp_saldoinicial' +@compu+ ' SET saldoinicial=(cargoapeimpape-cargopagadoux)')
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_abonos'+@compu)
exec('DROP TABLE ##tmp_abonos' +@compu )
declare @cadsql nvarchar(4000)
SET @cadsql='
	SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
			B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
			B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
			B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,simbmonabo=D.monedasimbolo,
			B.abonocantipcam,B.abonocanbco,B.abonocanctabco
		INTO ##tmp_abonos' +@compu+ '
		FROM [' +@base+ '].dbo.vt_abono B,[' +@base+ '].dbo.cc_tipodocumento C,[' +@base+ '].dbo.gr_moneda D
 		WHERE B.abonocanfecan between ''' +@fechaini+ ''' AND ''' +@fechafin+ ''' AND B.abonocantdqc=C.tdocumentocodigo AND
			B.abonocanmoncan=D.monedacodigo AND isnull(b.abonocanflreg,0)<>1 and B.abonocancli LIKE ''' +@codcliente+   '''' 
EXECUTE(@cadsql)
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_CtaCtexProvee'+@compu)
exec('DROP TABLE ##tmp_CtaCtexProvee' +@compu )
SET @cadsql='SELECT distinct AA.*,C.clienteruc,C.clienterazonsocial,descdoccargo=D.tdocumentodescripcion,
			numplanillacargo=E.abononumplanilla,Desc_Banco=(select bancodescripcion from [' +@base+ '].dbo.gr_banco M where M.bancocodigo=AA.abonocanbco),
			SaldoProvee=cast(0 as numeric(25,9)),Rendicion=cast('' '' as varchar(6))
		INTO 	##tmp_CtaCtexProvee' +@compu+ '
		FROM  (SELECT A.clientecodigo, A.documentocargo, A.cargonumdoc, B.abononumplanilla, A.cargoapefecemi,A.cargoapefecvct, A.monedacodigo, 
                    A.monedasimbolo,cargoapeimpape=A.cargoapeimpape* ( case when cargoapecarabo=''C'' then 1 else -1 end ),
				   	B.abonocantdqc,B.tipodescripcion,B.abonocanndqc,B.abonocanmoncan,abonocanimpcan=ISNULL(B.abonocanimpcan,0),abonocanimpsol=ISNULL(B.abonocanimpsol,0),
			   		B.abonocanfecan, B.simbmonabo,SaldoInicial,B.abonocanbco,B.abonocanctabco
			        FROM  ##tmp_saldoinicial' +@compu+ ' A left join ##tmp_abonos' +@compu+ ' B 
                          on A.clientecodigo+A.documentocargo+A.cargonumdoc=B.abonocancli+B.documentoabono+B.abononumdoc 
				    where a.clientecodigo LIKE ''' +@codcliente+  '''
			   UNION ALL	
			   SELECT 	A.clientecodigo,A.documentocargo,A.cargonumdoc, B.abononumplanilla, A.cargoapefecemi, A.cargoapefecvct, A.monedacodigo,
                        C.monedasimbolo, cargoapeimpape=A.cargoapeimpape* ( case when cargoapecarabo=''C'' then 1 else -1 end ), 
				    	B.abonocantdqc,B.tipodescripcion,B.abonocanndqc,B.abonocanmoncan,
                        abonocanimpcan=ISNULL(B.abonocanimpcan,0)* ( case when cargoapecarabo=''C'' then 1 else -1 end ),
                        abonocanimpsol=ISNULL(B.abonocanimpsol,0) * ( case when cargoapecarabo=''C'' then 1 else -1 end ),
					    B.abonocanfecan, B.simbmonabo,SaldoInicial=cast(0 as numeric(25,9)),B.abonocanbco,B.abonocanctabco
			           FROM  [' +@base+ '].dbo.vt_cargo A left join ##tmp_abonos' +@compu+ ' B
                              on A.clientecodigo+A.documentocargo+A.cargonumdoc=B.abonocancli+B.documentoabono+B.abononumdoc
                       left join [' +@base+ '].dbo.gr_moneda C on A.monedacodigo=C.monedacodigo
			           WHERE  a.empresacodigo like ''' +@empresa+  ''' and isnull(A.cargoapeflgreg,0)<>1 
                              and A.cargoapefecemi between ''' +@fechaini+ ''' AND ''' +@fechafin+ ''' 
		                      and a.clientecodigo LIKE ''' +@codcliente+ '''
               ) AS AA 
        inner join [' +@base+ '].dbo.vt_cliente C On AA.clientecodigo=C.clientecodigo
        inner join [' +@base+ '].dbo.cc_tipodocumento D on AA.documentocargo =D.tdocumentocodigo
        inner join [' +@base+ '].dbo.vt_cargo E on AA.clientecodigo+AA.documentocargo + AA.cargonumdoc= E.clientecodigo+E.documentocargo+E.cargonumdoc
		WHERE isnull(AA.monedacodigo,''00'')  LIKE ''' +@codmoneda+ ''''
			
execute(@cadsql)
--SALDOS INICIALES DEL CLIENTE
Set @cadsql='Update ##tmp_CtaCtexProvee' +@compu+ ' Set SaldoProvee=ss.SaldoProvee
From ##tmp_CtaCtexProvee' +@compu+ ' a,
	(Select a.clientecodigo,Cargo,Abono=isnull(b.Abono,0),SaldoProvee=Cargo-isnull(b.Abono,0)
	From
		(Select a.clientecodigo,Cargo=sum(a.cargoapeimpape)
		From [' +@base+ '].dbo.vt_cargo a Where a.cargoapefecemi<''' +@fechaini+ ''' Group by a.clientecodigo) A
	Left Join
		(Select b.abonocancli,Abono=sum(b.abonocanimpsol)
		From [' +@base+ '].dbo.vt_abono b Where b.abonocanfecan<''' +@fechaini+ ''' Group by b.abonocancli) B On a.clientecodigo=b.abonocancli) ss
Where a.clientecodigo=ss.clientecodigo'
exec(@cadsql)

Set @cadsql='Select * From ##tmp_CtaCtexProvee' +@compu

exec(@cadsql)

/*
select * from ##tmp_saldodocdesarrollo3 order by abonocancli,documentoabono,abononumdoc
select * from ziyaz.dbo.cp_CARGO WHERE CARGOnumd
select * from GREEN.DBO.CP_ABONO WHERE ABONOnumdoc='00100001088'
select * from green.dbo.te_detallerecibos where detrec_numdocumento='00100001088'
select a.* from green.dbo.te_cabecerarecibos a inner join green.dbo.te_detallerecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo where b.detrec_numdocumento='00100001088'
*/
GO
