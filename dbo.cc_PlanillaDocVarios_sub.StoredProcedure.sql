SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROC [cc_PlanillaDocVarios_sub] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.documentocargo as Cod_Documento, b.tdocumentodescripcion as Desc_Documento,
	TOTAL_SOLES = CASE 
	WHEN a.monedacodigo = ''01'' THEN SUM(isnull(a.cargoapeimpape,0)) 
	ELSE 0
	end,
	TOTAL_DOLARES = CASE 
	WHEN a.monedacodigo = ''02'' THEN SUM(isnull(a.cargoapeimpape,0)) 
	ELSE 0
	end
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON  
	a.documentocargo = b.tdocumentocodigo 
	JOIN 
	['+@base+'].dbo.cc_tipoplanilla f 
	ON 
	f.tplanillacodigo = a.abonotipoplanilla
WHERE	
	a.cargoapefecpla BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' 
	AND f.tplanilladocvarios = ''1'' 
	AND a.cargoapeflgcan <> 1 
	AND a.cargoapeflgreg IS NULL
GROUP BY
	a.documentocargo,b.tdocumentodescripcion,a.monedacodigo 
ORDER BY 
	b.tdocumentodescripcion '
exec (@sensql)
RETURN
GO
