SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [vt_EDG_RepSerieCorr] 		/*EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	c.puntovtacodigo as Cod_PtoVta,d.puntovtadescripcion as Desc_PtoVta,
	a.documentocargo as Cod_Documento,b.documentodescripcion as Desc_Doc,
	SUBSTRING(a.cargonumdoc,1,3) as Serie, 
	MIN ( SUBSTRING(a.cargonumdoc,4,8) ) as Correlativo_Del,
	MAX ( SUBSTRING(a.cargonumdoc,4,8) )as Correlativo_Al 
FROM 	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.vt_documento b
	ON  
	a.documentocargo = b.documentocodigo
	JOIN 
	['+@base+'].dbo.vt_pedido c
	ON  
	(a.cargonumdoc = c.pedidonrofact 
	OR a.cargonumdoc = c.pedidonroboleta)
	JOIN 
	['+@base+'].dbo.vt_puntoventa d
	ON  
	c.puntovtacodigo = d.puntovtacodigo
WHERE	
	a.cargoapefecemi 
	BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND c.puntovtacodigo like ('''+@codpuntoventa+''')
GROUP BY 
	c.puntovtacodigo,d.puntovtadescripcion,
	a.documentocargo,b.documentodescripcion,SUBSTRING(a.cargonumdoc,1,3)
ORDER BY 
	c.puntovtacodigo,d.puntovtadescripcion,
	a.documentocargo, SUBSTRING(a.cargonumdoc,1,3) '
exec (@sensql)
RETURN
GO
