SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [vt_EDG_RankingClientes]
@base varchar(50),
@montoventas float,
@porcentaje float,
@monto float,
@fecdesde varchar(10),
@fechasta varchar(10)
AS  
declare @vcodprod varchar(8) 	-- Cod Cliente
declare @vcoddesc varchar(80)	-- Descr. Cliente
declare @vtotalsinigv float	-- Total Sin IGV
declare @vtotalsoles float	-- Total Neto
declare @vporcventas float	-- Porcentaje
declare @totporcentaje float	-- Acumulador de Porcentajes
declare @totmonto float		-- Acumulador de Total Neto
select @totporcentaje = 0
select @totmonto = 0
DECLARE @sensql varchar (8000)
DECLARE @sql varchar (8000)
SET @sensql = 
'DELETE FROM ['+@base+'].dbo.TempoRanking'
exec (@sensql)
----------------------------------- PORCENTAJE
IF @porcentaje > 0  
BEGIN   
SET @sensql = '
DECLARE RANKINGCLIENTES CURSOR FOR 
SELECT  
c.clientecodigo as CODIGO_CLIENTE,h.clienterazonsocial as RAZON_SOCIAL,  
TOTAL_NETO =   
isnull (  
ISNULL  (  
(SELECT   
SUM (isnull(z.pedidototneto,0)) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_cargo x    
ON      
(z.pedidonrofact = x.cargonumdoc  OR z.pedidonroboleta = x.cargonumdoc OR  z.pedidonrogiarem = x.cargonumdoc)  
WHERE  c.clientecodigo = z.clientecodigo  
AND z.pedidofechaanu IS NULL 
AND x.cargoapefecemi BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''  
AND z.pedidomoneda = 01 )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (isnull(p.pedidototneto,0)* isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_cargo r    
ON      
(p.pedidonrofact = r.cargonumdoc  OR p.pedidonroboleta = r.cargonumdoc OR  p.pedidonrogiarem = r.cargonumdoc)  
JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
r.cargoapefecemi = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.pedidofechaanu IS NULL 
AND r.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+'''
AND p.pedidomoneda = 02 )  
,0 )  
, 0 )  
  
,  
  
TOTAL_SIN_IGV =   
isnull (  
ISNULL  (  
(SELECT   
SUM ( isnull(z.pedidototneto,0) - isnull(z.pedidototimpuesto,0)  ) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_cargo x    
ON      
(z.pedidonrofact = x.cargonumdoc  OR z.pedidonroboleta = x.cargonumdoc OR  z.pedidonrogiarem = x.cargonumdoc)  
WHERE  c.clientecodigo = z.clientecodigo  
AND z.pedidofechaanu IS NULL 
AND x.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+''' 
AND z.pedidomoneda = 01 )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (   (isnull(p.pedidototneto,0) - isnull(p.pedidototimpuesto,0))   * isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_cargo r    
ON      
(p.pedidonrofact = r.cargonumdoc  OR p.pedidonroboleta = r.cargonumdoc OR  p.pedidonrogiarem = r.cargonumdoc)  
JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
r.cargoapefecemi = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.pedidofechaanu IS NULL 
AND r.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+''' 
AND p.pedidomoneda = 02 )  
,0 )  
, 0 )  
  
,  
PORCENTAJE_VENTAS =   
(  
ISNULL (  
(SELECT   
SUM (isnull(z.pedidototneto,0)) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_cargo x    
ON      
(z.pedidonrofact = x.cargonumdoc  OR z.pedidonroboleta = x.cargonumdoc OR  z.pedidonrogiarem = x.cargonumdoc)  
WHERE  c.clientecodigo = z.clientecodigo  
AND z.pedidofechaanu IS NULL 
AND x.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+'''
AND z.pedidomoneda = 01 )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (isnull(p.pedidototneto,0)* isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_cargo r    
ON      
(p.pedidonrofact = r.cargonumdoc  OR p.pedidonroboleta = r.cargonumdoc OR  p.pedidonrogiarem = r.cargonumdoc)  
JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
r.cargoapefecemi = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.pedidofechaanu IS NULL 
AND r.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND  '''+@fechasta+'''
AND p.pedidomoneda = 02 )  
,0 )  
)  
  
/  
  
(  
isnull (  
(SELECT   
SUM (isnull(m.pedidototneto,0)) as IMP_SOLES   
FROM  ['+@base+'].dbo.vt_pedido m     
JOIN     
['+@base+'].dbo.vt_cargo o    
ON      
(m.pedidonrofact = o.cargonumdoc  OR m.pedidonroboleta = o.cargonumdoc OR  m.pedidonrogiarem = o.cargonumdoc)  
WHERE  
m.pedidofechaanu IS NULL  
AND o.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+'''
AND m.pedidomoneda = 01 )  ,  0  )  
+  
isnull (  
(SELECT      
SUM (isnull(j.pedidototneto,0)* isnull(i.tipocambioventa,0)) as IMP_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido j  
JOIN     
['+@base+'].dbo.vt_cargo l    
ON      
(j.pedidonrofact = l.cargonumdoc  OR j.pedidonroboleta = l.cargonumdoc OR  j.pedidonrogiarem = l.cargonumdoc)  
JOIN     
['+@base+'].dbo.ct_tipocambio i  
ON      
l.cargoapefecemi = i.tipocambiofecha  
WHERE   
j.pedidofechaanu IS NULL 
AND l.cargoapefecemi BETWEEN  '''+@fecdesde+''' AND '''+@fechasta+''' 
AND j.pedidomoneda = 02 )  
, 0 )  
  
  
)  
  
FROM     
['+@base+'].dbo.vt_pedido c    
 JOIN     
['+@base+'].dbo.vt_cargo d    
 ON      
 (c.pedidonrofact = d.cargonumdoc  OR c.pedidonroboleta = d.cargonumdoc OR  c.pedidonrogiarem = d.cargonumdoc)  
 JOIN     
['+@base+'].dbo.ct_tipocambio e    
 ON      
 d.cargoapefecemi = e.tipocambiofecha  
 JOIN  
['+@base+'].dbo.vt_cliente h  
 ON  
 c.clientecodigo = h.clientecodigo   
WHERE     
 d.cargoapefecemi BETWEEN  '''+@fecdesde+'''  AND  '''+@fechasta+''' 
 AND c.pedidofechaanu IS NULL 
GROUP BY    
 c.clientecodigo , h.clienterazonsocial  
  
ORDER BY  PORCENTAJE_VENTAS  DESC  
OPEN RANKINGCLIENTES
FETCH NEXT FROM RANKINGCLIENTES
INTO 
@vcodprod,
@vcoddesc,
@vtotalsoles,
@vtotalsinigv,
@vporcventas
WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @totporcentaje = @totporcentaje + @vporcventas
	IF  @totporcentaje <= @porcentaje
	BEGIN
		INSERT INTO ['+@base+'].dbo.TempoRanking 
		VALUES ('''+@vcodprod+''','''+@vcoddesc+''','+@vtotalsinigv+',
			'+@vtotalsoles+','+@vporcventas+','')
	END
	ELSE
	BEGIN
 		BREAK
	END
	FETCH NEXT FROM RANKINGCLIENTES
	INTO 
	@vcodprod,
	@vcoddesc,
	@vtotalsoles,
	@vtotalsinigv,
	@vporcventas
	END
SELECT * FROM ['+@base+'].dbo.TempoRanking ORDER BY porcentaje DESC
CLOSE RANKINGCLIENTES
DEALLOCATE RANKINGCLIENTES  '
exec (@sensql)
RETURN
END
GO
