SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute cp_PlanillaPagos 'ziyaz','01/08/2010','31/08/2010','%%','%%','02'

*/


CREATE      PROCedure  [cp_PlanillaPagos] 		/*EN USO*/
(
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@numero  varchar(8),
@codcliente varchar(20),
@empresa varchar(2)='01'
)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.empresacodigo,e.abonocancli as Cod_Cliente,c.clienterazonsocial as Razon_Social,
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
	tipopago=case when a.cargoapefecemi=e.abonocanfecan and e.abonocanforcan=''T'' then ''CO'' else ''CR'' end,
	e.abonocanbco,	ctabanco=e.abonocanctabco,tplanilladescripcion,
	ctactble=case when e.abonocanmoncan=''01'' then b.tdocumentocuentasoles else b.tdocumentocuentadolares end 
FROM ['+@base+'].dbo.cp_cargo a inner JOIN ['+@base+'].dbo.cp_tipodocumento b 
	ON  a.documentocargo = b.tdocumentocodigo 
	inner JOIN ['+@base+'].dbo.cp_proveedor c ON a.clientecodigo = c.clientecodigo
	inner JOIN ['+@base+'].dbo.gr_moneda d 	ON a.monedacodigo = d.monedacodigo
	inner JOIN ['+@base+'].dbo.cp_abono e
	ON a.clientecodigo=e.abonocancli and  a.documentocargo = e.documentoabono AND a.cargonumdoc = e.abononumdoc
	inner JOIN ['+@base+'].dbo.cp_tipodocumento g ON g.tdocumentocodigo = e.abonocantdqc
	inner JOIN ['+@base+'].dbo.cp_tipoplanilla h ON h.tplanillacodigo = e.abonotipoplanilla
WHERE e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+'''  and
	e.abonotipoplanilla+e.abononumplanilla  LIKE '''+@numero+'''  and a.empresacodigo LIKE '''+@empresa+'''  and 
	ltrim(rtrim(a.clientecodigo)) LIKE ''' +@codcliente + ''' and b.tdocumentotipo=''C'' and
        h.tplanillacobranza = ''1'' and  isnull(e.abonocanflreg,''0'')=0
ORDER BY  e.abonotipoplanilla,e.abononumplanilla,e.abononumdoc,e.abonocanforcan '
execute (@sensql)



/****** Objeto:  StoredProcedure [dbo].[cp_PlanillaCanjeRenovacion]    Fecha de la secuencia de comandos: 09/01/2010 14:12:39 ******/
SET ANSI_NULLS ON
GO
