SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [vt_RepGFB] 'ZIYAZ','01','01/08/2008','31/10/2008','01'
CREATE  PROC [vt_RepGFB_sub]
@base varchar(50),
@coddocumento varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codmoneda varchar(2)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	c.documentocodigo, c.documentodescripcion,
	IMPORTES_DOLARES = 
	CASE 
	WHEN b.pedidomoneda = ''02'' THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	END,
	IMPORTES_SOLES = 
	CASE 
	WHEN b.pedidomoneda = ''01'' THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	END
FROM 	['+@base+'].dbo.vt_pedido b
	JOIN
	['+@base+'].dbo.vt_documento c
	ON 
	c.documentocodigo = b.pedidotipofac
WHERE	
	 b.pedidotipofac LIKE ('''+@coddocumento+''')
	 AND b.pedidofechafact BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	 AND b.pedidomoneda LIKE ('''+@codmoneda+''')
  	 AND b.pedidofechaanu IS NULL 
	 AND c.documentocodigo IN (''01'',''03'',''80'')	  		 
GROUP BY
	c.documentocodigo, c.documentodescripcion, b.pedidomoneda '
exec (@sensql)
RETURN
GO
