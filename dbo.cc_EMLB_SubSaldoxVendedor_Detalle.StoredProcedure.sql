SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE         proc [cc_EMLB_SubSaldoxVendedor_Detalle](
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codvendedor varchar(50),
@ctacontable varchar(20)
/*@codresumen char(1)*/
)
as
/*
declare @base varchar(50), @compu varchar(20), @fecha varchar(10), @acuenta char(1) 
declare @codmoneda varchar(2), @codvendedor varchar(50), @ctacontable varchar(20)
set @base='ventas_prueba'
SET @compu='DESARROLLO3'
SET @fecha='30/09/2002'
SET @codmoneda='%'
SET @codvendedor='%'
SET @ctacontable='%'
SET @acuenta='1'
*/
set nocount on
DECLARE @sqlcad varchar(3000)
DECLARE @condctacontable nvarchar (2000)
SET @condctacontable=''
IF @ctacontable <> '%'
BEGIN
  SET @condctacontable=' AND(LTRIM(RTRIM(E.tdocumentocuentasoles)) LIKE ('''+@ctacontable+''') OR LTRIM(RTRIM(E.tdocumentocuentadolares)) LIKE ('''+@ctacontable+''')) '
  IF @codmoneda <> '%'
    BEGIN
	  IF @codmoneda = '01'
	   BEGIN
		 SET @condctacontable=' AND LTRIM(RTRIM(E.tdocumentocuentasoles)) LIKE ('''+@ctacontable+''') '
	   END
	  IF @codmoneda = '02'
	   BEGIN
		 SET @condctacontable= ' AND LTRIM(RTRIM(E.tdocumentocuentadolares)) LIKE ('''+@ctacontable+''') '
	   END
	END
END
declare @cadtmp varchar(2000)
set @cadtmp='SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
		B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
		B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
	        B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
		B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla
  		INTO ##tmp_saldodoc' +@compu+ '  
	FROM 
		[' +@base+ '].dbo.vt_abono B,
		[' +@base+ '].dbo.cc_tipodocumento C
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
			B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla
  		INTO ##tmp_saldodoc' +@compu+ '  
		FROM 
			[' +@base+ '].dbo.vt_abono B,
			[' +@base+ '].dbo.cc_tipodocumento C,
 				(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.vt_cargo D, [' +@base+ '].dbo.cc_tipodocumento E
 						where cargoapefecemi<=''' +@fecha+  '''  AND  cargoapeflgcan=0 AND
							cargoapeflgreg IS NULL ' +@condctacontable+ ' AND
							D.documentocargo=E.tdocumentocodigo ) AS Z
 		WHERE 	B.abonocancli=Z.clientecodigo AND
        		B.documentoabono=Z.documentocargo AND 
			B.abononumdoc=Z.cargonumdoc AND
			B.abonocanfecan<='''  +@fecha+ ''' AND 
			B.abonocantdqc=C.tdocumentocodigo AND
			ltrim(rtrim(B.vendedorcodigo)) like ''' +@codvendedor+   ''''
  	exec(@sqlcad)
END
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldoactualizado'+@compu)
exec('DROP TABLE ##tmp_saldoactualizado' +@compu )
set @sqlcad='
	SELECT 	A.vendedorcodigo,A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
			A.cargoapefecvct,A.bancocodigo,A.monedacodigo,
			cargoapeimpape=ISNULL( dbo.tipodoc(E.tdocumentotipo,A.cargoapeimpape) ,0 ),
			cargoapeimppag=isnull(A.cargoapeimppag,0),
			cargopagadoux=isnull(A.cargoapeimppag,0),
			A.cargoapeflgcan,A.cargoapecarabo,
 			Y.*,
 			E.tdocumentodescripcion,G.bancodescripcion,
			I.clienteruc,I.clienterazonsocial,
			H.monedasimbolo
	INTO 	##tmp_saldoactualizado' +@compu+ '
	FROM 	[' +@base+ '].dbo.vt_cargo A, ##tmp_saldodoc' +@compu+ ' Y,
 			[' +@base+ '].dbo.cc_tipodocumento E,
			[' +@base+ '].dbo.gr_banco G,
			[' +@base+ '].dbo.gr_moneda H,
			[' +@base+ '].dbo.vt_cliente I
	WHERE 	A.clientecodigo*=Y.abonocancli AND
        	A.documentocargo*=Y.documentoabono AND 
		A.cargonumdoc*=Y.abononumdoc AND
	    	A.documentocargo=E.tdocumentocodigo AND
		A.bancocodigo*=G.bancocodigo AND
		A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
		ltrim(rtrim(A.vendedorcodigo)) like ''' +@codvendedor+ ''' AND 
		A.monedacodigo like ''' +@codmoneda+ '''	AND
        	A.cargoapefecemi<=''' +@fecha+ ''' AND
		A.cargoapeflgcan=0  AND
		A.cargoapeflgreg IS NULL ' +@condctacontable + '
	ORDER BY cast(A.clientecodigo as int), A.documentocargo,A.cargonumdoc'
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
				[' +@base+ '].dbo.vt_abono B,
				[' +@base+ '].dbo.cc_tipodocumento C,
 					(select clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.vt_cargo D, [' +@base+ '].dbo.cc_tipodocumento E
	 							where cargoapefecemi<=''' +@fecha+  '''  AND  cargoapeflgcan=0 AND
								cargoapeflgreg IS NULL ' +@condctacontable+ ' AND
								D.documentocargo=E.tdocumentocodigo ) AS Z
	 		WHERE 	B.abonocancli=Z.clientecodigo AND
    	    		B.documentoabono=Z.documentocargo AND 
					B.abononumdoc=Z.cargonumdoc AND
					B.abonocanfecan<='''  +@fecha+ ''' AND 
					B.abonocantdqc=C.tdocumentocodigo AND
					ltrim(rtrim(B.vendedorcodigo)) like ''' +@codvendedor+   '''
        	GROUP BY B.abonocancli,B.documentoabono,B.abononumdoc) as Y
		WHERE A.clientecodigo=Y.abonocancli AND A.documentocargo=Y.documentoabono AND
	  		A.cargonumdoc=Y.abononumdoc'
	exec(@sqlcad)
END
set @sqlcad=''
set @sqlcad='SELECT cod_vendedor=a.vendedorcodigo,des_vendedor=c.vendedornombres,cod_documento=a.documentocargo,a.monedacodigo,desc_documento=b.tdocumentodescripcion,
	SALDO_SOLES = CASE 
	WHEN a.monedacodigo = 01 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargopagadoux,0))
    				 ELSE 0
	end,
	SALDO_DOLARES = CASE 
	WHEN a.monedacodigo = 02 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargopagadoux,0))
				 ELSE 0
	end
FROM  ##tmp_saldoactualizado' +@compu+  ' a, [' +@base+ '].dbo.cc_tipodocumento b,
	[' +@base+ '].dbo.vt_vendedor c
WHERE a.documentocargo=b.tdocumentocodigo and a.vendedorcodigo=c.vendedorcodigo
GROUP BY a.vendedorcodigo,c.vendedornombres,documentocargo,monedacodigo,b.tdocumentodescripcion'
exec(@sqlcad)
set nocount off
--select * from ##tmp_saldoactualizadodesarrollo3 order by abonocancli,documentoabono,abononumdoc
--exec cc_EMLB_SubSaldoxVendedor_Detalle 'ventas_prueba','DESARROLLO3','16/12/2002','1','%','%','%'
GO
