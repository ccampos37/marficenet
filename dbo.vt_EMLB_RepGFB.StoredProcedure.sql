SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EMLB_RepGFB]		/*EN USO*/
@base varchar(50),
@coddocumento varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@codmoneda varchar(2)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT	  	  b.pedidotipofac as Cod_Documento, b.pedidonrofact as Comprobante, b.pedidofechafact as Fec_Emision,	
	   	  b.clientecodigo as Cod_Cliente,b.clienterazonsocial,c.monedasimbolo ,
		  b.pedidototneto-isnull(b.pedidototimpuesto,0) as Monto_Sin_IGV,
		  isnull(b.pedidototimpuesto,0) as Impuesto, b.pedidototneto as Total_Neto
FROM 
		  ['+@base+'].dbo.vt_documento a
		  JOIN 
		  ['+@base+'].dbo.vt_pedido b
		  ON a.documentocodigo = b.pedidotipofac 
		  JOIN 
		  ['+@base+'].dbo.gr_moneda c
		  ON b.pedidomoneda = c.monedacodigo		 
WHERE 
		  b.pedidotipofac LIKE ('''+@coddocumento+''')
		  AND b.pedidofechafact BETWEEN '''+@fecdesde+''' AND '''+@fechasta+'''
		  AND b.pedidomoneda LIKE ('''+@codmoneda+''')
		  AND b.pedidofechaanu IS NULL 
		  AND a.documentocodigo IN (''01'',''03'',''80'')	  	
ORDER BY
		  b.pedidotipofac , b.pedidonrofact '
exec (@sensql)
RETURN
GO
