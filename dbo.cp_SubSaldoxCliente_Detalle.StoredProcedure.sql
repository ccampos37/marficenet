SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE                proc [cp_SubSaldoxCliente_Detalle]
(
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codcliente varchar(50),
@ctacontable varchar(20),
@coddocumento varchar(2),
@empresa varchar(2)
/*@codresumen char(1)*/
)
as
DECLARE @sqlcad varchar(3000)
DECLARE @condctacontable nvarchar (2000)
--IF @CODRESUMEN='1'
--BEGIN
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
 		SELECT z.empresacodigo,B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
			B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
			B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
     		B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
			B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla
  		INTO ##tmp_saldodoc' +@compu+ '  
		FROM 
			[' +@base+ '].dbo.cp_abono B,
			[' +@base+ '].dbo.cp_tipodocumento C,
 				(select empresacodigo,clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.cp_cargo D, [' +@base+ '].dbo.cp_tipodocumento E
 						where cargoapefecemi<=''' +@fecha+  '''  AND  cargoapeflgcan=0 AND
							isnull(cargoapeflgreg,0)<>1  ' +@condctacontable+ ' AND
							D.documentocargo=E.tdocumentocodigo ) AS Z
 		WHERE 	B.abonocancli=Z.clientecodigo AND
        		B.documentoabono=Z.documentocargo AND 
			B.abononumdoc=Z.cargonumdoc AND
			B.abonocanfecan<='''  +@fecha+ ''' AND 
			B.abonocantdqc=C.tdocumentocodigo AND
			B.abonocancli like ''' +@codcliente+   ''' and 
                        isnull(b.abonocanflreg,0)<>1    '
  	execute(@sqlcad)
END
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldoactualizado'+@compu)
exec('DROP TABLE ##tmp_saldoactualizado' +@compu )
set @sqlcad='
SELECT 	A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
	A.cargoapefecvct,A.bancocodigo,A.monedacodigo,
	cargoapeimpape=ISNULL( dbo.tipodoc(E.tdocumentotipo,A.cargoapeimpape) ,0 ),
	cargoapeimppag=isnull(A.cargoapeimppag,0),
	cargopagadoux=isnull(A.cargoapeimppag,0),
	A.cargoapeflgcan,A.cargoapecarabo,
	A.abonotipoplanilla as tipoplan, A.abononumplanilla as cargonumplan,
	A.cargoapefecpla as fechaplan,
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
	WHERE	A.clientecodigo*=Y.abonocancli AND
        	A.documentocargo*=Y.documentoabono AND 
			A.cargonumdoc*=Y.abononumdoc AND
	    	A.documentocargo=E.tdocumentocodigo AND A.documentocargo LIKE ''' +@coddocumento+''' AND
			A.bancocodigo*=G.bancocodigo AND
			A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
			A.clientecodigo like ''' +@codcliente+ ''' AND 
			A.monedacodigo like ''' +@codmoneda+ '''	AND
         A.cargoapefecemi<=''' +@fecha+ ''' AND
			A.cargoapeflgcan=0  AND
			isnull(A.cargoapeflgreg,0)<>1  ' +@condctacontable + '
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
								isnull(cargoapeflgreg,0)<>1  ' +@condctacontable+ ' AND
								D.documentocargo=E.tdocumentocodigo ) AS Z
	 		WHERE 	B.abonocancli=Z.clientecodigo AND
    	    		B.documentoabono=Z.documentocargo AND 
					B.abononumdoc=Z.cargonumdoc AND
					B.abonocanfecan<='''  +@fecha+ ''' AND 
					B.abonocantdqc=C.tdocumentocodigo AND
					B.abonocancli like ''' +@codcliente+   ''' and 
                                        isnull(b.abonocanflreg,0)<> 1
        	GROUP BY B.abonocancli,B.documentoabono,B.abononumdoc) as Y
		WHERE A.clientecodigo=Y.abonocancli AND A.documentocargo=Y.documentoabono AND
	  		A.cargonumdoc=Y.abononumdoc'
	exec(@sqlcad)
END
set @sqlcad=''
set @sqlcad='SELECT empresadescripcion,cod_documento=a.documentocargo,a.monedacodigo,desc_documento=b.tdocumentodescripcion,
	SALDO_SOLES = CASE 
	WHEN a.monedacodigo = 01 THEN SUM(isnull(a.cargoapeimpape,0)) -
              SUM(isnull(case when a.cargoapeimpape > 0 then a.cargopagadoux else a.cargopagadoux* -1 end ,0))
    ELSE 0
	end,
	SALDO_DOLARES = CASE 
	WHEN a.monedacodigo = 02 THEN SUM(isnull(a.cargoapeimpape,0)) - 
             SUM(isnull(case when a.cargoapeimpape > 0 then a.cargopagadoux else a.cargopagadoux* -1 end,0))
    ELSE 0
	end
FROM  ( select distinct empresacodigo,Clientecodigo,documentocargo,cargonumdoc,monedacodigo,cargoapeimpape,cargopagadoux 
from ##tmp_saldoactualizado' +@compu+ ' where abs(round(cargoapeimpape,2)-ROUND(cargopagadoux,2))> 0.01 
) as a 
inner join [' +@base+ '].dbo.cp_tipodocumento b on a.documentocargo=b.tdocumentocodigo 
inner join [' +@base+ '].dbo.co_multiempresas c on a.empresacodigo=c.empresacodigo 
where a.empresacodigo='''+@empresa+'''
GROUP BY empresadescripcion,documentocargo,monedacodigo,b.tdocumentodescripcion'

execute(@sqlcad)

--execute cp_SubSaldoxCliente_Detalle 'planta_casma','##jck','14/05/2008','0','%','%%','%','%','01'
GO
