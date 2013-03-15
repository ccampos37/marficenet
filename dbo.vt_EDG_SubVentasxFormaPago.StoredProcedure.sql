SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_SubVentasxFormaPago]   /*EN USO*/  
@base varchar(50),
@codpuntoventa varchar(2),
@codformapago varchar(2),  
@fecdesde varchar(10),  
@fechasta varchar(10) 
AS  
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	b.formapagocodigo,c.formapagodescripcion,
	IMPORTES_DOLARES = CASE 
	WHEN b.pedidomoneda = 02 THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	end,
	IMPORTES_SOLES = CASE 
	WHEN b.pedidomoneda = 01 THEN SUM(isnull(b.pedidototneto,0))
	ELSE 0
	end  
FROM  
['+@base+'].dbo.vt_cargo a   
JOIN   
['+@base+'].dbo.vt_pedido b  
ON    
 (a.cargonumdoc = b.pedidonrofact   
 OR a.cargonumdoc = b.pedidonroboleta
 OR a.cargonumdoc = b.pedidonrogiarem)  
JOIN 
['+@base+'].dbo.vt_formapago c
ON
c.formapagocodigo = b.formapagocodigo
WHERE
b.formapagocodigo like 
('''+@codformapago+''')
AND b.puntovtacodigo like 
('''+@codpuntoventa+''')
AND b.pedidofechaanu IS NULL
and a.cargoapefecemi
BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
GROUP BY   b.formapagocodigo,c.formapagodescripcion,b.pedidomoneda '
exec (@sensql)
RETURN
GO
