SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--* Updated	: Mon.12.02.2007
--* by		: Torrealba Muñoz Carlos
--* Reason	: Agregó Tipo de cambio SUNAT para la fecha de cancelación
--*------------------------------------------------------------------------------------------
--*				LISTADO DE COMPROBANTES CANCELADOS y TRANSFERENCIAS
--*------------------------------------------------------------------------------------------
CREATE  PROCEDURE [GN_spGetDocsCancel]
	@PerAno as char(4),
	@PerMes as char(2),
	@BaseName char(20)
WITH RECOMPILE
AS
declare @periodo as char(6)
Declare @strSQL varchar(8000)
set @periodo= @perano + @permes
IF EXISTS (SELECT name 
		FROM tempdb.dbo.sysobjects
		WHERE name = '##tblDocsCancel' AND type = 'U')
	DROP TABLE ##tblDocsCancel
--*------------------------------------------------------------------------------------------
--*	CANCELACION DE COMPROBANTES DE COMPRA POR CAJ.CHICA 
--*		(Al contado, contraentrega, provisionados y cancelado autoamticamente)
--*------------------------------------------------------------------------------------------
set @strSQL= '
select	''DPyCAE'' KindOfType, C.cabrec_numrecibo,C.ClienteCodigo, P.clienteruc,P.clienterazonsocial, C.Operacioncodigo,
		C.monedacodigo, C.Cabrec_TipoCambio, C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,
		C.CajaCodigo,
		case
			When CCH.cajacuentasoles is not null and rtrim(ltrim(CCH.cajacuentasoles))<>''0'' then CCH.cajacuentasoles
			When CCH.cajacuentadolares is not null and rtrim(ltrim(CCH.cajacuentadolares))<>''0'' then CCH.cajacuentadolares
			else ''NoCTA1''
		end as CuentaContable,
		cabrec_descripcion,C.cabrec_numreciboegreso,
		''-----'' as ''sepa'', TC.TipoCambioCompra, Convert(char(10), DP.cabprovifchdoc,112) as Compra_FchEmision,
		D.detrec_tipodoc_concepto, D.Detrec_MonedaDocumento,
		LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,
		D.detrec_item,D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, 
		case D.Detrec_MonedaDocumento
			When ''01'' then TD.tdocumentocuentasoles
			When ''02'' then TD.tdocumentocuentadolares
			else ''NoCTA2''
		end as CtaCntble,
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc, 
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		INTO ##tblDocsCancel
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, [' + rtrim(@BaseName) + '].dbo.te_codigocaja CCH, 
			 [' + rtrim(@BaseName) + '].dbo.cp_proveedor P, [' + rtrim(@BaseName) + '].dbo.cp_tipodocumento TD, [' + rtrim(@BaseName) + '].dbo.co_cabprovi'+ rtrim(@perano) + ' DP, 
			 [' + rtrim(@BaseName) + '].dbo.ct_tipocambio TC
		where C.operacioncodigo=''05'' --Cancelaciones de comprobantes de compra
			AND C.controlctacte=''N'' --pago de comprobantes de compra por caja chica
			AND DP.cabprovimes='''+ @permes + '''
			AND DP.proveedorcodigo=C.ClienteCodigo -- codigo del proveedor
			AND DP.documetocodigo=D.detrec_tipodoc_concepto -- Tpo. de documento
			AND (right(''000''+left(DP.cabprovinumdoc,PATINDEX(''%-%'',DP.cabprovinumdoc)-1),3) + right(''00000000''+rtrim(ltrim(substring(DP.cabprovinumdoc,PATINDEX(''%-%'',DP.cabprovinumdoc)+1,8))),8)=D.detrec_numdocumento) 
			AND DP.cabprovifchdoc=TC.tipocambiofecha 
			AND left(convert(char(10), cabrec_fechadocumento,112),6)='''+ @periodo + '''
		    AND C.Cabrec_estadoreg<>''0'' -- Registro vigente 
			AND ltrim(C.ClienteCodigo)<>'''' -- Codigo Proveedor obligatorio 
			AND C.cabrec_numrecibo=D.cabrec_numrecibo 
			AND TD.tdocumentocodigo=D.detrec_tipodoc_concepto 
			AND CCH.cajacodigo=D.detrec_cajabanco1 
			AND C.ClienteCodigo=P.clientecodigo'
Execute (@strSQL)
--print (@strSQL)
--*------------------------------------------------------------------------------------------
--*		CANCELACION (PAGO)DE OPERACIONES VARIAS POR CAJA CHICA (NO Comprobantes de compra)
--*------------------------------------------------------------------------------------------
set @strSQL='
INSERT INTO ##tblDocsCancel
select ''DNPyCC'' KindOfType, C.cabrec_numrecibo,C.ClienteCodigo, '' '' clienteRUC,'' '' clienterazonsocial, C.Operacioncodigo,
		C.monedacodigo, C.Cabrec_TipoCambio, C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,C.CajaCodigo,
		case
			When CCH.cajacuentasoles is not null and rtrim(ltrim(CCH.cajacuentasoles))<>''0'' then CCH.cajacuentasoles
			When CCH.cajacuentadolares is not null and rtrim(ltrim(CCH.cajacuentadolares))<>''0'' then CCH.cajacuentadolares
			else ''NoCTA1''
		end as CuentaContable,cabrec_descripcion,C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',CAST(0.0 AS NUMERIC(20,4)) as TipoCambioCompra, ''20000101'' as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,
		D.detrec_item,D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, G.cuentacodigo ''CtaCntble'',
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, [' + rtrim(@BaseName) + '].dbo.co_gastos G, [' + rtrim(@BaseName) + '].dbo.te_codigocaja CCH
		where C.operacioncodigo=''05'' --Cancelaciones en efectivo por caja chica
			AND left(convert(char(10), cabrec_fechadocumento,112),6)='''+ @periodo + '''
		    AND C.controlctacte=''0'' --No pago de comprobantes de compra
			AND ltrim(C.ClienteCodigo)=''''
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente
			AND G.cuentacodigo is not null 
			AND ltrim(G.cuentacodigo)<>''''
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND G.gastoscodigo=D.detrec_gastos
			AND CCH.cajacodigo=D.detrec_cajabanco1'
Execute (@strSQL)
--print (@strSQL)
--*------------------------------------------------------------------------------------------
--*		CANCELACION (PAGO)DE OPERACIONES VARIAS con BANCOS (NO Comprobantes de compra)
--*------------------------------------------------------------------------------------------
set @strSQL='
INSERT INTO ##tblDocsCancel
select	''DNPyCB'' KindOfType, C.cabrec_numrecibo,C.ClienteCodigo, '' '' clienteRUC,'' '' clienterazonsocial, C.Operacioncodigo,
		C.monedacodigo, C.Cabrec_TipoCambio, C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,
		C.CajaCodigo,
		cbanco_cuenta as CuentaContable, 
		cabrec_descripcion,C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',0.0 as TipoCambioCompra, ''20000101'' as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,
		LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,
		D.detrec_item,
		D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, G.cuentacodigo ''CtaCntble'',
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, [' + rtrim(@BaseName) + '].dbo.co_gastos G, [' + rtrim(@BaseName) + '].dbo.te_cuentabancos B
		where C.operacioncodigo=''06'' --Cancelaciones con bancos
			AND left(convert(char(10), cabrec_fechadocumento,112),6)=''' + @periodo + '''
			AND C.controlctacte=''0'' --No pago de comprobantes de compra 
			AND ltrim(C.ClienteCodigo)='''' 
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente 
			AND G.cuentacodigo is not null 
			AND ltrim(G.cuentacodigo)<>''''
			AND B.cbanco_codigo=D.detrec_cajabanco1
			AND B.monedacodigo=D.detrec_monedacancela
			and ltrim(rtrim(B.cbanco_numero)) = ltrim(rtrim(D.detrec_numctacte)) 
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND G.gastoscodigo=D.detrec_gastos
			AND B.cbanco_codigo=D.detrec_cajabanco1'
Execute (@strSQL)
--print (@strSQL)
--*------------------------------------------------------------------------------------------
--* 
--*		CANCELACION EFECTIVO DE COMPROBANTES DE COMPRA PREVIAMENTE PROVISIONADOS
--*------------------------------------------------------------------------------------------
set @strSQL= '
INSERT INTO ##tblDocsCancel
select	''DPyCPE'' KindOfType, C.cabrec_numrecibo,C.ClienteCodigo, P.clienteruc,P.clienterazonsocial, C.Operacioncodigo,C.monedacodigo, C.Cabrec_TipoCambio, 
		C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,C.CajaCodigo,
		case
			When CCH.cajacuentasoles is not null and rtrim(ltrim(CCH.cajacuentasoles))<>''0'' then CCH.cajacuentasoles
			When CCH.cajacuentadolares is not null and rtrim(ltrim(CCH.cajacuentadolares))<>''0'' then CCH.cajacuentadolares
			else ''NoCTA1''
		end as CuentaContable,cabrec_descripcion,C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',TC.TipoCambioCompra, Convert(char(10), Ca.CargoApeFecEmi,112) as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,D.detrec_item,
		D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, 
		case D.Detrec_MonedaDocumento
			When ''01'' then TD.tdocumentocuentasoles
			When ''02'' then TD.tdocumentocuentadolares
			else ''NoCTA2''
		end as CtaCntble,
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, [' + rtrim(@BaseName) + '].dbo.te_codigocaja CCH, 
			 [' + rtrim(@BaseName) + '].dbo.cp_proveedor P, [' + rtrim(@BaseName) + '].dbo.cp_tipodocumento TD, [' + rtrim(@BaseName) + '].dbo.cp_cargo Ca, 
			 [' + rtrim(@BaseName) + '].dbo.ct_tipocambio TC
		where C.operacioncodigo=''01'' --Cancelaciones EFECTIVO de comprobantes de compra
			AND C.controlctacte=''1'' -- Dctos previamente provisionados
			AND Ca.ClienteCodigo=C.ClienteCodigo -- codigo del proveedor
			AND Ca.documentoCargo=D.detrec_tipodoc_concepto -- Tpo. de documento
			AND Ca.CargoNumDoc=D.detrec_numdocumento
			and Ca.cargoapeflgcan=''1''
			AND Ca.CargoApeFecEmi=TC.tipocambiofecha
			AND left(convert(char(10), cabrec_fechadocumento,112),6)='''+ @periodo + '''
			AND ltrim(C.ClienteCodigo)<>'''' -- Codigo Proveedor obligatorio
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND TD.tdocumentocodigo=D.detrec_tipodoc_concepto
			AND CCH.cajacodigo=D.detrec_cajabanco1
			AND C.ClienteCodigo=P.clientecodigo'
Execute (@strSQL)
--print (@strSQL)
--*------------------------------------------------------------------------------------------
--*		CANCELACION por BANCOS DE COMPROBANTES DE COMPRA PREVIAMENTE PROVISIONADOS
--*------------------------------------------------------------------------------------------
set @strSQL= '
INSERT INTO ##tblDocsCancel
select	''DPyCPB'' KindOfType, C.cabrec_numrecibo,C.ClienteCodigo, P.clienteruc,P.clienterazonsocial, C.Operacioncodigo,C.monedacodigo, C.Cabrec_TipoCambio, 
		C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,C.CajaCodigo,
		cbanco_cuenta as CuentaContable,cabrec_descripcion,	C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',TC.TipoCambioCompra, Convert(char(10), Ca.CargoApeFecEmi,112) as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,D.detrec_item,
		D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, 
		case D.Detrec_MonedaDocumento
			When ''01'' then TD.tdocumentocuentasoles
			When ''02'' then TD.tdocumentocuentadolares
			else ''NoCTA2''
		end as CtaCntble,
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, 
			 [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, 
			 [' + rtrim(@BaseName) + '].dbo.te_cuentabancos B, 
			 [' + rtrim(@BaseName) + '].dbo.cp_proveedor P, 
			 [' + rtrim(@BaseName) + '].dbo.cp_tipodocumento TD, 
			 [' + rtrim(@BaseName) + '].dbo.cp_cargo Ca, 
			 [' + rtrim(@BaseName) + '].dbo.ct_tipocambio TC
		where 
			C.operacioncodigo=''02'' --Cancelaciones BANCOS de comprobantes de compra
			AND C.controlctacte=''1'' -- Dctos previamente provisionados
			AND Ca.ClienteCodigo = C.ClienteCodigo -- codigo del proveedor
			AND Ca.documentoCargo = D.detrec_tipodoc_concepto -- Tpo. de documento
			AND Ca.CargoNumDoc = D.detrec_numdocumento			
			and Ca.cargoapeflgcan=''1''
			AND Ca.CargoApeFecEmi=TC.tipocambiofecha
			AND left(convert(char(10), cabrec_fechadocumento,112),6)='''+ @periodo + '''
			AND B.monedacodigo=D.detrec_monedacancela
			AND B.cbanco_codigo=D.detrec_cajabanco1
			and ltrim(rtrim(B.cbanco_numero)) = ltrim(rtrim(D.detrec_numctacte)) 
			AND ltrim(C.ClienteCodigo)<>'''' -- Codigo Proveedor obligatorio
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND TD.tdocumentocodigo=D.detrec_tipodoc_concepto
			AND C.ClienteCodigo=P.clientecodigo'
Execute (@strSQL)
--print (@strSQL)
--*------------------------------------------------------------------------------------------
--*		TRANSFERENCIAS????????
--*------------------------------------------------------------------------------------------
set @strSQL= '
INSERT INTO ##tblDocsCancel
select	''TRANSF'' KindOfType, C.cabrec_numrecibo,'' '' ClienteCodigo, '' '' clienteruc, '' '' clienterazonsocial, C.Operacioncodigo,C.monedacodigo, C.Cabrec_TipoCambio, 
		C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,C.cabrec_ingsal,C.CajaCodigo,
		cbanco_cuenta as CuentaContable,cabrec_descripcion,	C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',0.0 as TipoCambioCompra, ''20000101'' as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,D.detrec_item,
		D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, '' '' CtaCntble,
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, 
			 [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, 
			 [' + rtrim(@BaseName) + '].dbo.te_cuentabancos B
		where (C.operacioncodigo=''80'' OR C.operacioncodigo=''90'')--Cancelaciones de comprobantes de compra
			AND left(convert(char(10), cabrec_fechadocumento,112),6)=''' + @periodo + '''
			AND D.detrec_tipocajabanco=''B'' -- Solo bancos
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente
			AND D.Detrec_estadoreg<>''0'' -- Registro vigente
			AND ltrim(C.controlctacte)='''' -- x
			AND ltrim(C.ClienteCodigo)='''' -- Codigo Proveedor
			AND ltrim(C.cabrec_numreciboegreso)<>'''' --Numero de Transferencia
			AND cabrec_transferenciaautomatico=''1''
			AND B.monedacodigo=D.detrec_monedacancela
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND B.cbanco_codigo=D.detrec_cajabanco1'
Execute (@strSQL)
--print (@strSQL)
set @strSQL= '
INSERT INTO ##tblDocsCancel
select	''TRANSF'' KindOfType, C.cabrec_numrecibo,'' '' ClienteCodigo, '' '' clienteruc, '' '' clienterazonsocial, C.Operacioncodigo,C.monedacodigo, C.Cabrec_TipoCambio, 
		C.Cabrec_TotSoles, C.Cabrec_TotDolares,C.cabrec_fechadocumento,cabrec_ingsal,C.CajaCodigo,
		case
			When CCH.cajacuentasoles is not null and rtrim(ltrim(CCH.cajacuentasoles))<>''0'' then CCH.cajacuentasoles
			When CCH.cajacuentadolares is not null and rtrim(ltrim(CCH.cajacuentadolares))<>''0'' then CCH.cajacuentadolares
			else ''NO.CTA''
		end as CuentaContable,cabrec_descripcion,C.cabrec_numreciboegreso,
		''-----'' as ''sepa'',0.0 as TipoCambioCompra, ''20000101'' as Compra_FchEmision,
		D.detrec_tipodoc_concepto,D.Detrec_MonedaDocumento,LEFT(D.detrec_numdocumento,3) DctoSerie, RIGHT(D.detrec_numdocumento,8) DctoNumero,D.detrec_item,
		D.detrec_tipocajabanco, D.detrec_cajabanco1,D.detrec_numctacte,
		D.detrec_monedacancela, D.detrec_importesoles, D.detrec_importedolares,D.detrec_gastos, '' '' CtaCntble,
		D.detrec_observacion, D.centrocostocodigo, D.detrec_tdqc, D.detrec_ndqc,
		(select tipocambiocompra from ['+ rtrim(@BaseName) +'].dbo.ct_tipocambio where convert(char(10),tipocambiofecha,102) = convert(char(10),C.cabrec_fechadocumento,102)) ''CancelFchCntble''
		from [' + rtrim(@BaseName) + '].dbo.te_cabecerarecibos C, [' + rtrim(@BaseName) + '].dbo.te_detallerecibos D, [' + rtrim(@BaseName) + '].dbo.te_codigocaja CCH
		where (C.operacioncodigo=''80'' OR C.operacioncodigo=''90'')--Cancelaciones de comprobantes de compra
			AND left(convert(char(10), cabrec_fechadocumento,112),6)=''' + @periodo + '''
		    AND D.detrec_tipocajabanco=''C'' -- Solo bancos
			AND C.Cabrec_estadoreg<>''0'' -- Registro vigente
			AND D.Detrec_estadoreg<>''0'' -- Registro vigente
			AND ltrim(C.controlctacte)='''' -- x
			AND ltrim(C.ClienteCodigo)='''' -- Codigo Proveedor
			AND ltrim(C.cabrec_numreciboegreso)<>'''' --Numero de Transferencia
			AND cabrec_transferenciaautomatico=''1''
			AND C.cabrec_numrecibo=D.cabrec_numrecibo
			AND CCH.cajacodigo=D.detrec_cajabanco1'
Execute (@strSQL)
--print (@strSQL)
select * from ##tblDocsCancel
order by KindOfType,CabRec_numreciboegreso,cabrec_ingsal, cabrec_numrecibo, detrec_item
-- exec GN_spGetDocsCancel @PerAno='2006' , @PerMes='12' , @BaseName='AcuaPlayaCasma'
-- exec GN_spGetDocsCancel @PerAno='2006' , @PerMes='12' , @BaseName='acua_molina'
--drop table TMP_tblDocsCancelTot
--select distinct C.*
--	into TMP_tblDocsCancelTot
--	from AcuaPlayaCasma.dbo.te_cabecerarecibos C, AcuaPlayaCasma.dbo.te_detallerecibos D 
--	where C.cabrec_numrecibo=D.cabrec_numrecibo AND left(convert(char(10), cabrec_fechadocumento,112),6)='200612' AND C.Cabrec_estadoreg<>'0' AND D.Detrec_estadoreg<>'0' 
--	Order by CabRec_numreciboegreso,cabrec_ingsal, C.cabrec_numrecibo
-- select * from AcuaPlayaCasma.dbo.te_cabecerarecibos C, AcuaPlayaCasma.dbo.te_detallerecibos D where C.cabrec_numrecibo=D.cabrec_numrecibo AND left(convert(char(10), cabrec_fechadocumento,112),6)='200612' AND C.Cabrec_estadoreg<>'0' AND D.Detrec_estadoreg<>'0' Order by CabRec_numreciboegreso,cabrec_ingsal, C.cabrec_numrecibo, detrec_item
-- select convert(char(10),tipocambiofecha,102), tipocambiocompra from demo.dbo.ct_tipocambio 
--select * 
--	from acua_molina.dbo.te_cabecerarecibos C, 
--		 acua_molina.dbo.te_detallerecibos D ,
--		 acua_molina.dbo.te_cuentabancos B
--	where C.cabrec_numrecibo=D.cabrec_numrecibo 
--		AND left(convert(char(10), cabrec_fechadocumento,112),6)='200612' 
--		AND C.Cabrec_estadoreg<>'0' AND D.Detrec_estadoreg<>'0' 
--		AND B.monedacodigo=D.detrec_monedacancela
--		AND B.cbanco_codigo=D.detrec_cajabanco1
--		and ltrim(rtrim(b.cbanco_numero)) = ltrim(rtrim(d.detrec_numctacte))
--
--	Order by CabRec_numreciboegreso,cabrec_ingsal, C.cabrec_numrecibo, detrec_item
GO
