SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute cc_PlanillaDocVarios 'aliterm','01/01/2008','31/01/2008'
--select * from aliterm.dbo.vt_cargo
CREATE    PROC [cc_PlanillaDocVarios] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.abononumplanilla as Num_Planilla,
	a.cargoapefecpla as Fec_Planilla, a.cargoapetipcam as Tipo_Cambio,
	a.clientecodigo as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	a.documentocargo as Cod_Documento, b.tdocumentodesccorta as Desc_Documento,
	a.cargonumdoc as Num_Documento,a.cargoapefecemi as Fec_Emision,
	a.cargoapefecvct as Fec_Vencimiento,d.monedasimbolo,
	ISNULL(a.cargoapeimpape,0) as Importe_Apertura
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON 
	a.documentocargo = b.tdocumentocodigo 
	JOIN 
	['+@base+'].dbo.vt_cliente c 
	ON 
	a.clientecodigo = c.clientecodigo 
	JOIN 
	['+@base+'].dbo.gr_moneda d 
	ON 
	a.monedacodigo = d.monedacodigo 
	JOIN 
	['+@base+'].dbo.cc_tipoplanilla f 
	ON 
	f.tplanillacodigo = a.abonotipoplanilla 
WHERE	
	f.tplanilladocvarios = ''1''
        and a.cargoapefecpla BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' 
	AND a.cargoapeflgcan <> 1 
	AND a.cargoapeflgreg IS NULL
ORDER BY 
	a.abononumplanilla,d.monedasimbolo,a.cargoapefecpla,a.clientecodigo,a.cargonumdoc '
execute (@sensql)
RETURN
GO
