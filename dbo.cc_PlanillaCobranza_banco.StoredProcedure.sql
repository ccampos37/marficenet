SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [cc_PlanillaCobranza_banco] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20),
@tipocobranza varchar(2),
@coddocumento varchar(2)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	
	a.abonocancli as Cod_Cliente,
        c.clienterazonsocial as Razon_Social,
	a.vendedorcodigo as Cod_Vendedor,
        a.documentoabono as Cod_Doc_Abono,	
	b.tdocumentodesccorta as Tipo_Doc_Abono,
        a.abononumdoc as Num_Doc_Abono,
	a.abonocantdqc as Cod_Doc_Abono2,
        g.tdocumentodesccorta as Desc_Doc_Abono2,
	a.abonocanndqc as Num_Doc_Abono2,
	ISNULL(a.abonocanimpcan,0) as Importe_Abono,
	a.abonocanforcan as Forma_Pago,
        a.abonocanmoncan as MonedaAbono,
        simbolo_mon_abo = (select M.monedasimbolo from ['+@base+'].dbo.gr_moneda as M where M.monedacodigo=a.abonocanmoncan),
	a.abonocanfecpla as Fec_Emision_Abono,
        a.abonocanfecan as Fec_Cancela_Abono,
        a.abonotipoplanilla as Tipo_Planilla,
	a.abononumplanilla as Num_Planilla, 
        a.abonocanbco as Cod_Banco,
        j.bancodescripcion as Banco,
	a.abonocancuenta as cuenta_abono,
        a.abonocantipcam as t_cambio
FROM 	
	['+@base+'].dbo.vt_abono a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON  
	a.documentoabono = b.tdocumentocodigo 
	JOIN
	['+@base+'].dbo.vt_cliente c
	ON
	a.abonocancli = c.clientecodigo
	JOIN
	['+@base+'].dbo.gr_moneda d
	ON
	a.abonocanmoneda = d.monedacodigo
	JOIN
	['+@base+'].dbo.cc_tipodocumento g
	ON
	g.tdocumentocodigo = a.abonocantdqc
	JOIN
	['+@base+'].dbo.cc_tipoplanilla h
	ON
	h.tplanillacodigo = a.abonotipoplanilla
	left JOIN
	['+@base+'].dbo.gr_banco j
	ON
	j.bancocodigo=a.abonocanbco
WHERE	
	a.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND a.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND ltrim(rtrim(a.abonocancli)) LIKE ''' +@codcliente+ '''
	AND a.documentoabono like ''' +@coddocumento+ '''
	AND h.tplanillacobranza = ''1''
	AND a.abonocanflreg IS NULL 
	AND a.abonocantdqc=''15''
'
exec (@sensql)
RETURN
--ORDER BY 
--	 e.abonotipoplanilla,e.abononumplanilla,e.abononumdoc,e.abonocanforcan 
--exec cc_EMLB_PlanillaCobranza 'ventas_prueba','01/11/2002','30/11/2002','%','%','%','01'
--exec cc_EMLB_SubPlanillaCobranza 'ventas_prueba','01/11/2002','30/11/2002','%','%','%'
GO
