SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [cp_EMLB_CtaCteAbonosxCliente](
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codcliente varchar(50),
@ctacontable varchar(20)
)
as
/*
declare @base varchar(50), @compu varchar(20), @fecha varchar(10), @acuenta char(1) 
declare @codmoneda varchar(2), @codcliente varchar(50), @ctacontable varchar(20)
set @base='ventas_prueba'
SET @compu='DESARROLLO3'
SET @fecha='18/10/2002'
SET @codmoneda='%'
SET @codcliente='%'
SET @ctacontable='%'
SET @acuenta='0'
*/
set nocount on
DECLARE @sqlcad varchar(3000)
declare @cadtmp varchar(2000)
set @cadtmp='SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
		B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
		B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
        B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
		B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,
		simbmonabo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=B.abonocanmoncan),
		B.abonocantipcam,
		B.abonocanbco
  		INTO ##tmp_saldodoc' +@compu+ '  
	FROM 
		[' +@base+ '].dbo.cp_abono B,
		[' +@base+ '].dbo.cp_tipodocumento C
	where abonocancli =''*'''
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldodoc'+@compu)
  exec('DROP TABLE ##tmp_saldodoc'+@compu)
if @acuenta='1'
BEGIN
  exec(@cadtmp)
END
if @acuenta='0'
BEGIN
	Set @sqlcad=' 
 		SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
			B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
			B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
        	B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
			B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,
			simbmonabo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=B.abonocanmoncan),
			B.abonocantipcam,
			B.abonocanbco
  		INTO ##tmp_saldodoc' +@compu+ '  
		FROM 
			[' +@base+ '].dbo.cp_abono B,
			[' +@base+ '].dbo.cp_tipodocumento C,
 				(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.cp_cargo D, [' +@base+ '].dbo.cp_tipodocumento E
 						where cargoapefecemi<=''' +@fecha+  '''  AND  cargoapeflgcan=0 AND
							cargoapeflgreg IS NULL AND
							D.documentocargo=E.tdocumentocodigo ) AS Z
 		WHERE 	B.abonocancli=Z.clientecodigo AND
        		B.documentoabono=Z.documentocargo AND 
				B.abononumdoc=Z.cargonumdoc AND
				B.abonocanfecan<='''  +@fecha+ ''' AND 
				B.abonocantdqc=C.tdocumentocodigo AND
				B.abonocancli like ''' +@codcliente+   ''''
  	exec(@sqlcad)
END
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldoactualizado'+@compu)
exec('DROP TABLE ##tmp_saldoactualizado' +@compu )
set @sqlcad='
	SELECT 	A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
			A.cargoapefecvct,A.bancocodigo,A.monedacodigo,cargoapeimpape=isnull(A.cargoapeimpape,0),
			cargoapeimppag=isnull(A.cargoapeimppag,0),
			cargopagadoux=isnull(A.cargoapeimppag,0),
			A.cargoapeflgcan,A.cargoapecarabo,
 			Y.*,
 			E.tdocumentodescripcion,G.bancodescripcion,
			I.clienteruc,I.clienterazonsocial,
			H.monedasimbolo
    INTO 	##tmp_saldoactualizado' +@compu+ '
	FROM 	[' +@base+ '].dbo.cp_cargo A, ##tmp_saldodoc' +@compu+ ' Y,
 			[' +@base+ '].dbo.cp_tipodocumento E,
			[' +@base+ '].dbo.gr_banco G,
			[' +@base+ '].dbo.gr_moneda H,
			[' +@base+ '].dbo.cp_proveedor I
	WHERE 	A.clientecodigo*=Y.abonocancli AND
        	A.documentocargo*=Y.documentoabono AND 
			A.cargonumdoc*=Y.abononumdoc AND
	    	A.documentocargo=E.tdocumentocodigo AND
			A.bancocodigo*=G.bancocodigo AND
			A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
			A.clientecodigo like ''' +@codcliente+ ''' AND 
			A.monedacodigo like ''' +@codmoneda+ '''	AND
            A.cargoapefecemi<=''' +@fecha+ ''' AND
			A.cargoapeflgcan=0  AND
			A.cargoapeflgreg IS NULL 
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
exec(@sqlcad)
IF @acuenta='0' 
BEGIN
	set @sqlcad='
		UPDATE ##tmp_saldoactualizado' +@compu+ ' SET ##tmp_saldoactualizado' +@compu+ '.cargopagadoux=B.saldoactual
			FROM ##tmp_saldoactualizado' +@compu+ ' A,
				 (SELECT clientecodigo,documentocargo,cargonumdoc,saldoactual=SUM(ISNULL(abonocanimpsol,0)) 
					FROM ##tmp_saldoactualizado' +@compu+ ' 
 					GROUP BY clientecodigo,documentocargo,cargonumdoc ) as B
			WHERE A.clientecodigo=B.clientecodigo AND A.documentocargo=B.documentocargo AND
	  			A.cargonumdoc=B.cargonumdoc'
	exec(@sqlcad)
END
IF @fecha<convert(varchar(10),getdate(),103) AND @acuenta='1'
BEGIN
	exec('UPDATE ##tmp_saldoactualizado' +@compu+ ' SET cargopagadoux=0')
		
	SET @sqlcad=''
	SET @sqlcad='
	UPDATE ##tmp_saldoactualizado' +@compu+ ' SET ##tmp_saldoactualizado' +@compu+ '.cargopagadoux=Y.saldoactual
				FROM ##tmp_saldoactualizado' +@compu+ ' A,
			(SELECT B.abonocancli,B.documentoabono,B.abononumdoc,saldoactual=SUM(ISNULL(B.abonocanimpsol,0))
			FROM 
				[' +@base+ '].dbo.cp_abono B,
				[' +@base+ '].dbo.cp_tipodocumento C,
 					(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.cp_cargo D, [' +@base+ '].dbo.cp_tipodocumento E
	 							where cargoapefecemi<=''' +@fecha+  '''  AND  cargoapeflgcan=0 AND
								cargoapeflgreg IS NULL AND
								D.documentocargo=E.tdocumentocodigo ) AS Z
	 		WHERE 	B.abonocancli=Z.clientecodigo AND
    	    		B.documentoabono=Z.documentocargo AND 
					B.abononumdoc=Z.cargonumdoc AND
					B.abonocanfecan<='''  +@fecha+ ''' AND 
					B.abonocantdqc=C.tdocumentocodigo AND
					B.abonocancli like ''' +@codcliente+   '''
        	GROUP BY B.abonocancli,B.documentoabono,B.abononumdoc) as Y
		WHERE A.clientecodigo=Y.abonocancli AND A.documentocargo=Y.documentoabono AND
	  		A.cargonumdoc=Y.abononumdoc'
	exec(@sqlcad)
END
exec('SELECT * FROM  ##tmp_saldoactualizado' +@compu )
set nocount off
--select * from ##tmp_saldodocdesarrollo3 order by abonocancli,documentoabono,abononumdoc
--exec cp_EMLB_SaldoxCliente_Detalle 'ventas_prueba','DESARROLLO3','18/11/2002','1','%','%','%'
--exec cp_EMLB_CtaCteAbonosxCliente 'ventas_prueba','desa3','01/12/2002','0','%','%','%'
GO
