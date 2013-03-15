SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXECUTE cp_SubPlanillaPagos 'ACUALIMA08','01/01/2008','31/12/2008','%%','%%'


CREATE    proc [cp_PlanillaPagos_sub] (

@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor varchar(3),
@codcliente varchar(20), /*Codigo Prveedor*/
@empresa varchar(2)='01' 
)
as
/*
set @base='ventas_prueba'
set @fecdesde='01/11/2002'
set @fechasta='25/11/2002'
set @codvendedor='%'
*/
DECLARE @sensql1 nvarchar (4000)
DECLARE @sensql2 nvarchar (4000)
SET @sensql1= '
SELECT Cod_Doc_Abono,Desc_Doc_Abono,Cod_Doc_Cargo,Desc_Doc_Cargo,
	ContadoDolar=IMPORTES_DOLARES_CONTADO,
    CreditoDolar=(IMPORTES_DOLARES_TOTAL-IMPORTES_DOLARES_CONTADO),
	ContadoSol=IMPORTES_SOLES_CONTADO,
	CreditoSol=(IMPORTES_SOLES_TOTAL-IMPORTES_SOLES_CONTADO)
 FROM
(SELECT e.abonocantdqc as Cod_Doc_Abono,g.tdocumentodescripcion as Desc_Doc_Abono,
	e.documentoabono as Cod_Doc_Cargo,i.tdocumentodescripcion as Desc_Doc_Cargo,
	IMPORTES_DOLARES_CONTADO = 
	isnull ( (
	SELECT SUM (isnull(z.abonocanimpcan,0)) 
	FROM [' +@base+ '].dbo.cp_abono z
	JOIN
	[' +@base+ '].dbo.cp_tipoplanilla y
	ON
	y.tplanillacodigo = z.abonotipoplanilla
	JOIN
		[' +@base+ '].dbo.cp_cargo c
    ON
		c.documentocargo=z.documentoabono and  c.cargonumdoc=z.abononumdoc and c.clientecodigo=z.abonocancli 
	WHERE 	z.abonocanforcan=''T'' AND c.cargoapefecemi=z.abonocanfecan
	AND	z.abonocanmoncan = ''02'' 
	AND z.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND z.abonocancli LIKE ''' +@codcliente+ '''
	AND z.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND c.empresacodigo LIKE '''+@empresa+''' 
	AND z.abonocanflreg IS NULL
	AND y.tplanillacobranza = ''1'' 
	AND e.abonocantdqc = z.abonocantdqc AND e.documentoabono = z.documentoabono
	) , 0 ) ,
	IMPORTES_DOLARES_TOTAL = 
	isnull ( (
	SELECT SUM (isnull(z.abonocanimpcan,0)) 
	FROM [' +@base+ '].dbo.cp_abono z
	JOIN
		[' +@base+ '].dbo.cp_tipoplanilla y
	ON
		y.tplanillacodigo = z.abonotipoplanilla
	WHERE
	z.abonocanmoncan = ''02'' 
	AND z.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND z.abonocancli LIKE ''' +@codcliente+ '''
	AND z.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND z.abonocanflreg IS NULL
	AND y.tplanillacobranza = ''1'' 
	AND e.abonocantdqc = z.abonocantdqc AND e.documentoabono = z.documentoabono
	) , 0 ) , '
set @sensql2='
	IMPORTES_SOLES_CONTADO = 
	isnull ( (
	SELECT SUM (isnull(z.abonocanimpcan,0)) 
	FROM [' +@base+ '].dbo.cp_abono z
	JOIN
		[' +@base+ '].dbo.cp_tipoplanilla y
	ON
		y.tplanillacodigo = z.abonotipoplanilla
	JOIN
		[' +@base+ '].dbo.cp_cargo c
    ON
		c.documentocargo=z.documentoabono and  c.cargonumdoc=z.abononumdoc and c.clientecodigo=z.abonocancli 
	WHERE 	z.abonocanforcan=''T'' AND c.cargoapefecemi=z.abonocanfecan
	AND	z.abonocanmoncan = ''01'' 
	AND z.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND z.abonocancli LIKE ''' +@codcliente+ '''
	AND z.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND c.empresacodigo LIKE '''+@empresa+''' 
	AND z.abonocanflreg IS NULL
	AND y.tplanillacobranza = ''1'' 
	AND e.abonocantdqc = z.abonocantdqc AND e.documentoabono = z.documentoabono
	) , 0 ),
	IMPORTES_SOLES_TOTAL = 
	isnull ( (
	SELECT SUM (isnull(z.abonocanimpcan,0)) 
	FROM [' +@base+ '].dbo.cp_abono z
	JOIN
		[' +@base+ '].dbo.cp_tipoplanilla y
	ON
		y.tplanillacodigo = z.abonotipoplanilla
	WHERE
	z.abonocanmoncan = ''01'' 
	AND z.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND z.abonocancli LIKE ''' +@codcliente+ '''
	AND z.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND z.abonocanflreg IS NULL
	AND y.tplanillacobranza = ''1'' 
	AND e.abonocantdqc = z.abonocantdqc AND e.documentoabono = z.documentoabono
	) , 0 )
FROM 	
		[' +@base+ '].dbo.cp_abono e
	JOIN [' +@base+ '].dbo.cp_tipodocumento g
	ON g.tdocumentocodigo = e.abonocantdqc
	JOIN
		[' +@base+ '].dbo.cp_tipoplanilla h
	ON
		h.tplanillacodigo = e.abonotipoplanilla
	JOIN
		[' +@base+ '].dbo.cp_tipodocumento i
	ON
		i.tdocumentocodigo = e.documentoabono
WHERE	
	e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND h.tplanillacobranza = ''1''
	AND e.abonocanflreg IS NULL
GROUP BY 
	e.abonocantdqc,g.tdocumentodescripcion,
	e.documentoabono,i.tdocumentodescripcion ) AS ZZ'
exec (@sensql1+@sensql2)
GO
