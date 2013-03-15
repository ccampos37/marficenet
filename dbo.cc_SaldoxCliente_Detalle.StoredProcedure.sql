SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute cc_SaldoxCliente_Detalle 'aliterm2012','##JCK','13/11/2012','0','%%','%%','%%','%%','01',3

select * from ##tmp_saldodoc##jck
select * from ##tmp_saldoactualizado##jck where cargonumplan='000722'
*/
CREATE            proc [cc_SaldoxCliente_Detalle](
@base varchar(50),
@compu varchar(50),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codcliente varchar(50),
@ctacontable varchar(20),
@coddocumento varchar(2),
@empresa varchar(2),
@inter integer =3
)
as
DECLARE @sqlcad varchar(3000)
DECLARE @condctacontable nvarchar (2000)
SET @condctacontable=''
IF @ctacontable <> '%%'
BEGIN
  SET @condctacontable=' AND(LTRIM(RTRIM(E.tdocumentocuentasoles)) LIKE ('''+@ctacontable+''') OR LTRIM(RTRIM(E.tdocumentocuentadolares)) LIKE ('''+@ctacontable+''')) '
  IF @codmoneda <> '%%'
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
		B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,
		simbmonabo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=B.abonocanmoncan),
		B.abonocantipcam
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
	Set @sqlcad=' SELECT B.abonocancli,B.documentoabono,B.abononumdoc,B.abonocancarabo,
			B.abonocantdqc,tipodescripcion=C.tdocumentodescripcion,B.abonocanndqc,B.abonocanmoncan,
			B.abonocanimpcan,B.abonocanimpsol,B.abonocanfecan,
     		B.abonocanmoneda,B.abonocanimcan,B.abonocanforcan,
			B.abonocancuenta,B.abononumplanilla,B.abonotipoplanilla,
			simbmonabo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=B.abonocanmoncan),
			B.abonocantipcam
  		INTO ##tmp_saldodoc' +@compu+ '  
		FROM 
			[' +@base+ '].dbo.vt_abono B,
			[' +@base+ '].dbo.cc_tipodocumento C,
 				(select empresacodigo,clientecodigo,documentocargo,cargonumdoc from [' +@base+ '].dbo.vt_cargo D, [' +@base+ '].dbo.cc_tipodocumento E
 						where floor(cast(cargoapefecemi as real)) <=' +cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))+  '  AND  cargoapeflgcan=0 AND
							isnull(cargoapeflgreg,0)=0  ' +@condctacontable+ ' AND
							D.documentocargo=E.tdocumentocodigo ) AS Z
 		WHERE 	B.abonocancli=Z.clientecodigo AND
	        		B.documentoabono=Z.documentocargo AND 
					B.abononumdoc=Z.cargonumdoc AND
					floor(cast(B.abonocanfecan as real)) <=' +cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20)) + ' AND
					B.abonocantdqc=C.tdocumentocodigo AND
                                        isnull(b.abonocanflreg,0)<>1 and 
					B.abonocancli like ''' +@codcliente+   ''' '
 	EXECUTE(@sqlcad)
END
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_saldoactualizado'+@compu)
exec('DROP TABLE ##tmp_saldoactualizado' +@compu )
set @sqlcad=' SELECT 	a.empresacodigo,A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
		A.cargoapefecvct,A.bancocodigo,A.monedacodigo,
		cargoapeimpape=ISNULL( dbo.tipodoc(E.tdocumentotipo,A.cargoapeimpape) ,0 ),
		cargoapeimppag=ISNULL(A.cargoapeimppag,0 ),
		cargopagadoux=isnull(A.cargoapeimppag,0),
		A.cargoapeflgcan,A.cargoapecarabo,
		A.abonotipoplanilla as tipoplan, A.abononumplanilla as cargonumplan,
		A.cargoapefecpla as fechaplan,
 		Y.*,
 		E.tdocumentodescripcion,G.bancodescripcion,
		I.clienteruc,I.clienterazonsocial,
		H.monedasimbolo
    	INTO 	##tmp_saldoactualizado' +@compu+ '
	FROM	[' +@base+ '].dbo.vt_cargo A, ##tmp_saldodoc' +@compu+ ' Y,
 			[' +@base+ '].dbo.cc_tipodocumento E,
			[' +@base+ '].dbo.gr_banco G,
			[' +@base+ '].dbo.gr_moneda H,
			[' +@base+ '].dbo.vt_cliente I
	WHERE A.clientecodigo*=Y.abonocancli AND
        	A.documentocargo*=Y.documentoabono AND 
			A.cargonumdoc*=Y.abononumdoc AND
	    	A.documentocargo=E.tdocumentocodigo AND A.documentocargo LIKE ''' +@coddocumento+''' AND
			A.bancocodigo*=G.bancocodigo AND
			A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
			A.clientecodigo like ''' +@codcliente+ ''' AND 
			A.monedacodigo like ''' +@codmoneda+ '''	AND
			floor(cast(A.cargoapefecemi as real)) <=' +cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20)) + ' AND '
if @inter=1 set @sqlcad=@sqlcad+' isnull(i.interempresas,0)=1 and '
if @inter=2 set @sqlcad=@sqlcad+' isnull(i.interempresas,0)=0 and '
   set @sqlcad=@sqlcad+ ' A.cargoapeflgcan=0  AND
			isnull(A.cargoapeflgreg,0)=0   ' +@condctacontable + '
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
exec(@sqlcad)
--floor(cast(A.cargoapefecemi as real)) <=' + cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))	
IF @acuenta='0' 
BEGIN
	set @sqlcad=' UPDATE ##tmp_saldoactualizado' +@compu+ ' SET ##tmp_saldoactualizado' +@compu+ '.cargopagadoux=B.saldoactual
			FROM ##tmp_saldoactualizado' +@compu+ ' A,
				 (SELECT clientecodigo,documentocargo,cargonumdoc,saldoactual=SUM(ISNULL(abonocanimpcan,0)) 
					FROM ##tmp_saldoactualizado' +@compu+ ' 
 					GROUP BY clientecodigo,documentocargo,cargonumdoc ) as B
					WHERE A.clientecodigo=B.clientecodigo AND A.documentocargo=B.documentocargo AND
	  				A.cargonumdoc=B.cargonumdoc'
	exec(@sqlcad)
END
--IF @fecha<convert(varchar(10),getdate(),103) AND @acuenta='1'
IF cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))<floor(cast(getdate() as real)) AND @acuenta='1'
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
	 							where floor(cast(cargoapefecemi as real))<=' +cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))+  '  
	   						   AND cargoapeflgcan=0 
									AND isnull(cargoapeflgreg,0)=0  ' +@condctacontable+ ' 
									AND D.documentocargo=E.tdocumentocodigo ) AS Z
	 		WHERE 	B.abonocancli=Z.clientecodigo AND
    	    			B.documentoabono=Z.documentocargo AND 
						B.abononumdoc=Z.cargonumdoc AND
						floor(cast(B.abonocanfecan as real)) <=' + cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))+ ' AND
						B.abonocantdqc=C.tdocumentocodigo AND
						B.abonocancli like ''' +@codcliente+   ''' and 
                                                isnull(b.abonocanflreg,0)<>1 
        	GROUP BY B.abonocancli,B.documentoabono,B.abononumdoc) as Y
		WHERE A.clientecodigo=Y.abonocancli AND A.documentocargo=Y.documentoabono AND
	  			A.cargonumdoc=Y.abononumdoc'
	exec(@sqlcad)
END
--floor(cast(A.cargoapefecemi as real)) <=' + cast(dbo.fn_datenumber(day(@fecha),month(@fecha),year(@fecha)) as varchar(20))
set @sqlcad='SELECT b.empresadescripcion,a.* FROM ##tmp_saldoactualizado' +@compu+ ' a 
inner join [' +@base+ '].dbo.co_multiempresas B on a.empresacodigo=b.empresacodigo
WHERE ROUND(cargoapeimpape,2)-ROUND(cargopagadoux,2)<> 0
 and a.empresacodigo like ('''+@empresa+''') '
execute( @sqlcad)
GO
