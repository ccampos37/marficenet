SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    proc [cp_EMLB_SubPlanillaCanjeRenovacion] (
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20),
@opcion varchar(1)
)
as
/*
set @base='ventas_prueba'
set @fecdesde='01/11/2002'
set @fechasta='25/11/2002'
set @codvendedor='%'
*/
DECLARE @sensql nvarchar (4000)
declare @cadsql nvarchar(300)
if @opcion='1'
	begin
		set @cadsql='tplanillacanjes=''1'''
	end
else
	begin
		set @cadsql='tplanillarenovar=''1'''
	end
SET @sensql = N'
SELECT 	e.abonocantdqc as Cod_Doc_Abono,g.tdocumentodescripcion as Desc_Doc_Abono,
	e.documentoabono as Cod_Doc_Cargo,i.tdocumentodescripcion as Desc_Doc_Cargo,
	IMPORTES_DOLARES = 
	isnull ( (
	SELECT SUM (isnull(z.abonocanimpcan,0)) 
	FROM ['+@base+'].dbo.cp_abono z
	JOIN
	['+@base+'].dbo.cp_tipoplanilla y
	ON
	y.tplanillacodigo = z.abonotipoplanilla
	WHERE z.abonocanmoneda = 02 
	AND z.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND z.abonocanflreg IS NULL
	AND z.abonocancli LIKE ''' +@codcliente+ '''
	AND z.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND y.' +@cadsql+ ' 
	AND e.abonocantdqc = z.abonocantdqc AND e.documentoabono = z.documentoabono
	) , 0 ) , 
	IMPORTES_SOLES = 
	isnull (  (
	SELECT SUM (isnull(x.abonocanimpcan,0)) 
	FROM ['+@base+'].dbo.cp_abono x
	JOIN
	['+@base+'].dbo.cp_tipoplanilla w
	ON
	w.tplanillacodigo = x.abonotipoplanilla
	WHERE x.abonocanmoneda = 01 
	AND x.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND x.abonocanflreg IS NULL
	AND x.abonocancli LIKE ''' +@codcliente+ '''
	AND x.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND w.' +@cadsql+ '
	AND e.abonocantdqc = x.abonocantdqc AND e.documentoabono = x.documentoabono
	) , 0 )
FROM 	
	['+@base+'].dbo.cp_abono e
	JOIN
	['+@base+'].dbo.cp_tipodocumento g
	ON
	g.tdocumentocodigo = e.abonocantdqc
	JOIN
	['+@base+'].dbo.cp_tipoplanilla h
	ON
	h.tplanillacodigo = e.abonotipoplanilla
	JOIN
	['+@base+'].dbo.cp_tipodocumento i
	ON
	i.tdocumentocodigo = e.documentoabono
WHERE	
	e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND e.vendedorcodigo LIKE '''+@codvendedor+''' AND h.' +@cadsql+ '
	AND e.abonocancli LIKE ''' +@codcliente+ '''
	AND e.abonocanflreg IS NULL
GROUP BY 
	e.abonocantdqc,g.tdocumentodescripcion,
	e.documentoabono,i.tdocumentodescripcion
ORDER BY 
	g.tdocumentodescripcion,e.abonocantdqc '	
exec (@sensql)
GO
