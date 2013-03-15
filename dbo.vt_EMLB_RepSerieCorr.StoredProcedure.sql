SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EMLB_RepSerieCorr] 		/*EN USO*/
@base varchar(50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	c.puntovtacodigo as Cod_PtoVta,d.puntovtadescripcion as Desc_PtoVta,
	c.pedidotipofac as Cod_Documento,b.documentodescripcion as Descripcion_Doc,
	SUBSTRING(c.pedidonrofact,1,3) as Serie, 
	MIN ( SUBSTRING(c.pedidonrofact,4,8) ) as Correlativo_Del,
	MAX ( SUBSTRING(c.pedidonrofact,4,8) )as Correlativo_Al 
FROM  
	['+@base+'].dbo.vt_documento b
	JOIN 
	['+@base+'].dbo.vt_pedido c
	ON  
	b.documentocodigo = c.pedidotipofac
	JOIN 
	['+@base+'].dbo.vt_puntoventa d
	ON  
	c.puntovtacodigo = d.puntovtacodigo
WHERE	
	c.pedidofechafact
	BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	AND c.puntovtacodigo like ('''+@codpuntoventa+''')
GROUP BY 
	c.puntovtacodigo,d.puntovtadescripcion,
	c.pedidotipofac,b.documentodescripcion,SUBSTRING(c.pedidonrofact,1,3)
ORDER BY 
	c.puntovtacodigo,d.puntovtadescripcion,
	c.pedidotipofac, SUBSTRING(c.pedidonrofact,1,3) '
exec (@sensql)
RETURN
GO
