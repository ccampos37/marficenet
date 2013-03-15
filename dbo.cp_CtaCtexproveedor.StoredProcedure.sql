SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.cp_CtaCtexproveedor    fecha de la secuencia de comandos: 18/10/2006 03:12:52 p.m. ******/
/*
exec cp_CtaCtexproveedor 'aliterm2012','##xxxx','01/01/2012','17/10/2012','31/12/2011','%%','20100130204','01'
drop proc [dbo].[cp_CtaCtexproveedor]
*/
CREATE       proc [cp_CtaCtexproveedor] (
@base varchar(50),
@compu varchar(50),
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
	FROM [' +@base+ '].dbo.cp_abono B,[' +@base+ '].dbo.cp_tipodocumento C
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
	FROM 	[' +@base+ '].dbo.cp_cargo A, ##tmp_saldodoc' +@compu+ ' Y,
 			[' +@base+ '].dbo.cp_tipodocumento E,[' +@base+ '].dbo.gr_banco G,
			[' +@base+ '].dbo.gr_moneda H,[' +@base+ '].dbo.cp_proveedor I
	WHERE 	A.clientecodigo*=Y.abonocancli AND A.documentocargo*=Y.documentoabono AND 
		A.cargonumdoc*=Y.abononumdoc AND A.documentocargo=E.tdocumentocodigo AND
		A.bancocodigo*=G.bancocodigo AND A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND a.empresacodigo like ('''+@empresa + ''') and 
                A.clientecodigo like ''' +@codcliente+ ''' AND A.monedacodigo like ''' +@codmoneda+ '''	AND
	        A.cargoapefecemi<='''+@fecha+''' AND
		A.cargoapeflgcan=0  AND isnull(A.cargoapeflgreg,0)<>1
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
execute(@sqlcad)
--IF @fecha<convert(varchar(10),getdate(),103)
--BEGIN
	exec('UPDATE ##tmp_saldoinicial' +@compu+ ' SET cargopagadoux=0')
	SET @sqlcad=''
	SET @sqlcad=N'
	UPDATE ##tmp_saldoinicial' +@compu+ ' SET ##tmp_saldoinicial' +@compu+ '.cargopagadoux=Y.saldoactual
				FROM ##tmp_saldoinicial' +@compu+ ' A,
			(SELECT B.abonocancli,B.documentoabono,B.abononumdoc,
                   saldoactual=SUM(ISNULL(B.abonocanimpsol,0)* ( case when tdocumentocodigo =''C'' then 1 else -1 end ))
			FROM [' +@base+ '].dbo.cp_abono B,[' +@base+ '].dbo.cp_tipodocumento C,
 					(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.cp_cargo D, [' +@base+ '].dbo.cp_tipodocumento E
	 							where FLOOR(CAST(cargoapefecemi AS REAL)) <=' + CAST(DBO.fn_datenumber(DAY(@fecha),MONTH(@fecha),YEAR(@fecha)) as varchar(20)) +  ' 
	 							AND  cargoapeflgcan=0 AND isnull(cargoapeflgreg,0)<> 1 AND D.documentocargo=E.tdocumentocodigo
	 				 ) AS Z
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
		FROM [' +@base+ '].dbo.cp_abono B
             inner join [' +@base+ '].dbo.cp_tipodocumento C on B.abonocantdqc=C.tdocumentocodigo 
             inner join [' +@base+ '].dbo.gr_moneda D on B.abonocanmoncan=D.monedacodigo
 		WHERE B.abonocanfecan between ''' +@fechaini+ ''' AND ''' +@fechafin+ '''  
    		 AND isnull(b.abonocanflreg,0)<>1 and B.abonocancli LIKE ''' +@codcliente+   '''' 
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
                        abonocanimpsol=(CASE WHEN a.MONEDACODIGO<>abonocanmoncan then 
                                   ISNULL(B.abonocanimpsol,0) else  ISNULL(B.abonocanimpcan,0) end )* ( case when cargoapecarabo=''C'' then 1 else -1 end ),
 					    B.abonocanfecan, B.simbmonabo,SaldoInicial=cast(0 as numeric(25,9)),B.abonocanbco,B.abonocanctabco
			           FROM  [' +@base+ '].dbo.cp_cargo A left join ##tmp_abonos' +@compu+ ' B
                              on A.clientecodigo+A.documentocargo+A.cargonumdoc=B.abonocancli+B.documentoabono+B.abononumdoc
                       left join [' +@base+ '].dbo.gr_moneda C on A.monedacodigo=C.monedacodigo
			           WHERE  a.empresacodigo like ''' +@empresa+  ''' and isnull(A.cargoapeflgreg,0)<>1 
                              and A.cargoapefecemi between ''' +@fechaini+ ''' AND ''' +@fechafin+ ''' 
		                      and a.clientecodigo LIKE ''' +@codcliente+ '''
               ) AS AA 
        inner join [' +@base+ '].dbo.cp_proveedor C On AA.clientecodigo=C.clientecodigo
        inner join [' +@base+ '].dbo.cp_tipodocumento D on AA.documentocargo =D.tdocumentocodigo
        inner join [' +@base+ '].dbo.cp_cargo E on AA.clientecodigo+AA.documentocargo + AA.cargonumdoc= E.clientecodigo+E.documentocargo+E.cargonumdoc
		WHERE isnull(AA.monedacodigo,''00'')  LIKE ''' +@codmoneda+ ''' and isnull(e.cargoapeflgreg,0)<>1 '
			
execute (@cadsql)
--SALDOS INICIALES DEL CLIENTE
Set @cadsql='Update ##tmp_CtaCtexProvee' +@compu+ ' Set SaldoProvee=ss.SaldoProvee
From ##tmp_CtaCtexProvee' +@compu+ ' a,
	(Select a.clientecodigo,Cargo,Abono=isnull(b.Abono,0),SaldoProvee=Cargo-isnull(b.Abono,0)
	From
		(Select a.clientecodigo,Cargo=sum(a.cargoapeimpape) From [' +@base+ '].dbo.cp_cargo a 
		        Where a.cargoapefecemi<''' +@fechaini+ ''' and isnull(a.cargoapeflgreg,0)<> 0 Group by a.clientecodigo
		 ) A
	Left Join
	(Select b.abonocancli,Abono=sum(b.abonocanimpsol) From [' +@base+ '].dbo.cp_abono b 
		        Where b.abonocanfecan<''' +@fechaini+ ''' and isnull(b.abonocanflreg,0)<>1 
		        Group by b.abonocancli 
	) B On a.clientecodigo=b.abonocancli) ss
Where a.clientecodigo=ss.clientecodigo'

exec(@cadsql)
--NUMERO DE RENDICION
Set @cadsql='Update ##tmp_CtaCtexProvee' +@compu+ ' Set Rendicion=isnull(b.rendicion,'''')
	From ##tmp_CtaCtexProvee' +@compu+ ' a,
		(Select rendicion=isnull(b.rendicionnumero,''''),a.abononumplanilla 
		From [' +@base+ '].dbo.cp_abono a
		Left Join [' +@base+ '].dbo.te_detallerecibos b On a.abononumplanilla=b.cabrec_numrecibo
		Where rendicionnumero<>'''' and isnull(a.abonocanflreg,0)<>1  ) b 
	Where a.abononumplanilla=b.abononumplanilla'

exec(@cadsql)

Set @cadsql='Select * From ##tmp_CtaCtexProvee' +@compu

exec(@cadsql)
GO
