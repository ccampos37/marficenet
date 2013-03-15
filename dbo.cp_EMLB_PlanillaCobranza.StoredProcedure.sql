SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE        PROC [cp_EMLB_PlanillaCobranza] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	e.abonocancli as Cod_Cliente,c.clienterazonsocial as Razon_Social,
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
	e.abonocanbco,
	ctactble=case when e.abonocanmoncan=''01'' 
			then b.tdocumentocuentasoles
			else b.tdocumentocuentadolares
			end,
	ctabanco=e.abonocanctabco
FROM 	
	['+@base+'].dbo.cp_cargo a 
	JOIN 
	['+@base+'].dbo.cp_tipodocumento b 
	ON  
	a.documentocargo = b.tdocumentocodigo 
	JOIN
	['+@base+'].dbo.cp_proveedor c
	ON
	a.clientecodigo = c.clientecodigo
	JOIN
	['+@base+'].dbo.gr_moneda d
	ON
	a.monedacodigo = d.monedacodigo
	JOIN
	['+@base+'].dbo.cp_abono e
	ON
	a.documentocargo = e.documentoabono
	AND a.cargonumdoc = e.abononumdoc
	JOIN
	['+@base+'].dbo.cp_tipodocumento g
	ON
	g.tdocumentocodigo = e.abonocantdqc
	JOIN
	['+@base+'].dbo.cp_tipoplanilla h
	ON
	h.tplanillacodigo = e.abonotipoplanilla
WHERE	
	e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND e.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND ltrim(rtrim(a.clientecodigo)) LIKE ''' +@codcliente + '''
	AND h.tplanillacobranza = ''1''
	AND e.abonocanflreg IS NULL
ORDER BY 
	 e.abonotipoplanilla,e.abononumplanilla,e.abononumdoc,e.abonocanforcan '
exec (@sensql)
RETURN
--exec cp_EMLB_PlanillaCobranza 'GREMCO','03/01/2008','03/01/2008','%','15160280538'
--select * from ventas_prueba.dbo.cp_abono
--select * from ventas_prueba.dbo.cp_tipodocumento
GO
