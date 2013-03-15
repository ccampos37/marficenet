SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [cc_ImprimePlanillaCobranza_rpt] 		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@tipoplanilla varchar(2),
@numeroplanilla varchar(6)
AS
DECLARE @sensql nvarchar (4000)

SET @sensql =' SELECT h.tplanillacodigo, tplanilladescripcion,e.abonocanfecpla,  e.abonocancli ,c.clienterazonsocial,e.vendedorcodigo,
    e.documentoabono ,b.tdocumentodesccorta ,e.abononumdoc,a.cargoapefecemi,FormaPago=e.abonocanforcan ,d.monedasimbolo, 
	Importe_Abono=ISNULL(e.abonocanimpcan,0) ,e.abonocanmoncan as MonedaAbono,
   simbolo_mon_abo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=e.abonocanmoncan),
	e.abonocantdqc as Cod_Doc_Abono,g.tdocumentodesccorta as Desc_Doc_Abono,
	e.abonocanndqc as Num_Doc_Abono,e.abonocanfecan as Fec_Cancela_Abono,
	e.abononumplanilla as Num_Planilla, e.abonotipoplanilla as Tipo_Planilla,
	tipopago=case when a.cargoapefecemi=e.abonocanfecan and e.abonocanforcan=''T'' then ''CO'' else ''CR'' end,
   j.bancodescrcorta
FROM ['+@base+'].dbo.vt_cargo a inner JOIN 	['+@base+'].dbo.cc_tipodocumento b ON  a.documentocargo = b.tdocumentocodigo 
	inner JOIN ['+@base+'].dbo.vt_cliente c ON a.clientecodigo = c.clientecodigo
	inner JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo
	inner JOIN ['+@base+'].dbo.vt_abono e ON  a.clientecodigo+ a.documentocargo + a.cargonumdoc =e.abonocancli+ e.documentoabono+ e.abononumdoc
	inner JOIN ['+@base+'].dbo.cc_tipodocumento g ON g.tdocumentocodigo = e.abonocantdqc
	inner JOIN ['+@base+'].dbo.cc_tipoplanilla h ON h.tplanillacodigo = e.abonotipoplanilla
	left JOIN ['+@base+'].dbo.gr_banco j ON j.bancocodigo=e.abonocanbco
WHERE	a.empresacodigo='''+@empresa +'''  and e.abonotipoplanilla='''+@tipoplanilla +''' and e.abononumplanilla='''+@numeroplanilla +'''
	    AND h.tplanillacobranza = ''1'' AND isnull(e.abonocanflreg,0) <>1  and b.tdocumentotipo=''C''  '

execute(@sensql)
GO
