SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_Sub_RepGFB]		/*EN USO*/
@base varchar(50),
@coddocumento varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codmoneda varchar(2),
@detalle char(1)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	c.documentocodigo, c.documentodescripcion,
	IMPORTES_DOLARES = CASE 
	WHEN b.pedidomoneda = 02 THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	end,
	IMPORTES_SOLES = CASE 
	WHEN b.pedidomoneda = 01 THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	end
FROM 	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.vt_pedido b
	ON  
	(a.cargonumdoc = b.pedidonrofact 
	OR a.cargonumdoc = b.pedidonroboleta
	OR a.cargonumdoc = b.pedidonrogiarem)
	JOIN
	['+@base+'].dbo.vt_documento c
	ON 
	a.documentocargo = c.documentocodigo
WHERE	
	 a.documentocargo LIKE ('''+@coddocumento+''')
	 AND a.cargoapefecemi
	 BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	 AND b.pedidomoneda LIKE ('''+@codmoneda+''')
  	 AND b.pedidofechaanu IS NULL 
	 AND ISNULL(a.cargoapeflgcan,0) LIKE ('''+@detalle+''')
	 
GROUP BY
	c.documentocodigo, c.documentodescripcion, b.pedidomoneda '
exec (@sensql)
RETURN
GO
