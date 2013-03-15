SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROC [cc_PlanillaCobranza_rpt] 		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20)
AS
---execute cc_planillacobranza 'gremco','01/01/2007','31/07/2007','%%','%%','CO','%%','1'
DECLARE @sensql nvarchar (4000)
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_PlanillaCob')
  exec('DROP TABLE ##tmp_PlanillaCob')
SET @sensql =' SELECT h.tplanillacodigo, tplanilladescripcion,e.abonocancli as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	e.vendedorcodigo as Cod_Vendedor,e.documentoabono as Cod_Doc_Cargo,
	b.tdocumentodesccorta as Desc_Doc_Cargo,e.abononumdoc as Num_Doc_Cargo,
	a.cargoapefecemi as Fec_Emision_Cargo,
	e.abonocanforcan as Forma_Pago,d.monedasimbolo, 
	ISNULL(e.abonocanimpcan,0) as Importe_Abono,
   e.abonocanmoncan as MonedaAbono,
   simbolo_mon_abo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=e.abonocanmoncan),
	e.abonocantdqc as Cod_Doc_Abono,g.tdocumentodesccorta as Desc_Doc_Abono,
	e.abonocanndqc as Num_Doc_Abono,e.abonocanfecan as Fec_Cancela_Abono,
	e.abononumplanilla as Num_Planilla, e.abonotipoplanilla as Tipo_Planilla,
	tipopago=
		case when a.cargoapefecemi=e.abonocanfecan and e.abonocanforcan=''T''
			then ''CO'' else ''CR''
		end,
   j.bancodescrcorta
FROM ['+@base+'].dbo.vt_cargo a 
	inner JOIN 	['+@base+'].dbo.cc_tipodocumento b ON  a.documentocargo = b.tdocumentocodigo 
	inner JOIN ['+@base+'].dbo.vt_cliente c ON a.clientecodigo = c.clientecodigo
	inner JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo
	inner JOIN ['+@base+'].dbo.vt_abono e ON a.documentocargo = e.documentoabono AND a.cargonumdoc = e.abononumdoc
	inner JOIN ['+@base+'].dbo.cc_tipodocumento g ON g.tdocumentocodigo = e.abonocantdqc
	inner JOIN ['+@base+'].dbo.cc_tipoplanilla h ON h.tplanillacodigo = e.abonotipoplanilla
	left JOIN ['+@base+'].dbo.gr_banco j ON j.bancocodigo=e.abonocanbco
WHERE	a.empresacodigo='''+@empresa +'''and e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND e.vendedorcodigo LIKE '''+@codvendedor+''' AND ltrim(rtrim(a.clientecodigo)) LIKE ''' +@codcliente+ '''
	AND h.tplanillacobranza = ''1'' AND isnull(e.abonocanflreg,0) <>1   '

execute(@sensql)
GO
