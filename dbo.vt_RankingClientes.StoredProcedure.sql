SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [vt_RankingClientes]
@TotalNeto float,
@TotalBruto float,  
@porcentaje float,
@monto float,
@fecdesde varchar(10),
@fechasta varchar(10),
@codpuntoventa varchar(2),
@base varchar (50),
@empresa varchar (2)

AS  
DECLARE @params nvarchar(4000)
DECLARE @sensql nvarchar(4000)
DECLARE @smallcad varchar(200)
DECLARE @cadena varchar(8000)
DECLARE @vcodprod varchar(20) 	-- Cod Cliente
DECLARE @vcoddesc varchar(80)	-- Descr. Cliente
DECLARE @vtotalsinigv float	-- Total Sin IGV
DECLARE @vtotalsoles float	-- Total Neto
DECLARE @vporcventas float	-- Porcentaje Vtas.
DECLARE @totporcentaje decimal	-- Acumulador de Porcentajes
DECLARE @totmonto float		-- Acumulador de Total Neto
SET	@totporcentaje = 0
SET	@totmonto = 0
SET 	@smallcad = 'DELETE FROM ['+@base+'].dbo.TempoRanking '
EXEC	(@smallcad)
------------------------------------------------------------------- EN BASE A PORCENTAJE DE VENTAS
IF @porcentaje > 0
BEGIN  
SET	@cadena = 
'DECLARE RANKINGCLIENTES CURSOR FOR  
SELECT  
c.clientecodigo as CODIGO_CLIENTE,h.clienterazonsocial as RAZON_SOCIAL,      
TOTAL_NETO =   
isnull (  
ISNULL  (  
(SELECT   
SUM (isnull(   dbo.tipodoc (x.documentotipo,z.pedidototneto)  ,0)  ) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_documento x    
ON      
  z.pedidotipofac = x.documentocodigo  
WHERE  c.clientecodigo = z.clientecodigo  
AND z.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND z.pedidofechaanu IS NULL and z.empresacodigo='''+@empresa+'''  
AND z.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''  
AND z.pedidomoneda = ''01'' )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (isnull(   dbo.tipodoc (r.documentotipo,p.pedidototneto)    ,0)* isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_documento r    
ON      
  p.pedidotipofac = r.documentocodigo 
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
  p.pedidofechafact = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND p.pedidofechaanu IS NULL and p.empresacodigo='''+@empresa+'''
AND p.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+''' 
AND p.pedidomoneda = ''02'' )  
,0 )  
, 0 )    
,    
TOTAL_SIN_IGV =   
isnull (  
ISNULL  (  
(SELECT   
SUM ( isnull(  dbo.tipodoc (x.documentotipo,z.pedidototneto)   ,0) - isnull(  dbo.tipodoc (x.documentotipo,z.pedidototimpuesto)  ,0)  ) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_documento x    
ON      
  z.pedidotipofac = x.documentocodigo
WHERE  c.clientecodigo = z.clientecodigo  
AND z.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND z.pedidofechaanu IS NULL and z.empresacodigo='''+@empresa+'''
AND z.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+'''
AND z.pedidomoneda = ''01'' )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (   (isnull(   dbo.tipodoc(r.documentotipo,p.pedidototneto)  ,0) - isnull(  dbo.tipodoc(r.documentotipo,p.pedidototimpuesto) ,0) )   * isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_documento r    
ON      
  p.pedidotipofac = r.documentocodigo
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
  p.pedidofechafact = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND p.pedidofechaanu IS NULL and p.empresacodigo='''+@empresa+'''
AND p.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+'''
AND p.pedidomoneda = ''02'' )  
,0 )  
, 0 )    
,  
PORCENTAJE_VENTAS =   
(  
ISNULL (  
(SELECT   
SUM (isnull(   dbo.tipodoc(x.documentotipo,z.pedidototneto) ,0) ) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_documento x    
ON      
  z.pedidotipofac = x.documentocodigo
WHERE  c.clientecodigo = z.clientecodigo  
AND z.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND z.pedidofechaanu IS NULL and z.empresacodigo='''+@empresa+'''AND z.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+'''
AND z.pedidomoneda = ''01'' )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (isnull(   dbo.tipodoc (r.documentotipo,p.pedidototneto) ,0)* isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_documento r    
ON      
  p.pedidotipofac = r.documentocodigo
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
  p.pedidofechafact = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.puntovtacodigo LIKE ('''+@codpuntoventa+''')
AND p.pedidofechaanu IS NULL and p.empresacodigo='''+@empresa+'''
AND p.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+'''
AND p.pedidomoneda = ''02'' )  
,0 )  
)    
/    
(  
isnull (  
(SELECT   
SUM (isnull(  dbo.tipodoc(o.documentotipo,m.pedidototneto) ,0)  ) as IMP_SOLES   
FROM  ['+@base+'].dbo.vt_pedido m     
JOIN     
['+@base+'].dbo.vt_documento o    
ON      
  m.pedidotipofac = o.documentocodigo
WHERE  
m.pedidofechaanu IS NULL and m.empresacodigo='''+@empresa+'''
AND m.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND m.pedidofechafact BETWEEN   '''+@fecdesde+'''  AND '''+@fechasta+'''
AND m.pedidomoneda = ''01'' )  ,  0  )  
+  
isnull (  
(SELECT      
SUM (isnull(   dbo.tipodoc(l.documentotipo,j.pedidototneto) ,0)* isnull(i.tipocambioventa,0)) as IMP_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido j  
JOIN     
['+@base+'].dbo.vt_documento l    
ON      
  j.pedidotipofac = l.documentocodigo
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio i  
ON      
  j.pedidofechafact = i.tipocambiofecha  
WHERE   
j.pedidofechaanu IS NULL and j.empresacodigo='''+@empresa+'''
AND j.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND j.pedidofechafact BETWEEN    '''+@fecdesde+'''  AND '''+@fechasta+'''
AND j.pedidomoneda = ''02'' )  
, 0 )    
)    
 FROM     
 ['+@base+'].dbo.vt_pedido c    
 JOIN     
 ['+@base+'].dbo.vt_documento d    
 ON      
  c.pedidotipofac = d.documentocodigo
 LEFT JOIN     
 ['+@base+'].dbo.ct_tipocambio e    
 ON      
  c.pedidofechafact = e.tipocambiofecha  
 JOIN  
 ['+@base+'].dbo.vt_cliente h  
 ON  
  c.clientecodigo = h.clientecodigo   
WHERE     
  c.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+''' 
  AND  c.pedidofechaanu IS NULL and c.empresacodigo='''+@empresa+''' 
  AND c.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
GROUP BY    
  c.clientecodigo , h.clienterazonsocial    
ORDER BY  PORCENTAJE_VENTAS  DESC  '
execute (@cadena)
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
	SET @totporcentaje = @totporcentaje +  ( @vporcventas * 100 )
	IF  @totporcentaje <= @porcentaje+1
	  BEGIN
	    SET @sensql = 
	    N'INSERT INTO ['+@base+'].dbo.TempoRanking 
	    VALUES (@vcodprod,@vcoddesc,@vtotalsinigv,@vtotalsoles,@vporcventas*100,null )'
	    SET @params=N'@vcodprod varchar(20),@vcoddesc varchar(80),@vtotalsinigv float,@vtotalsoles float, @vporcventas float'
	    EXEC sp_executesql @sensql,@params,@vcodprod,@vcoddesc,@vtotalsinigv,@vtotalsoles,@vporcventas
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
SET	@smallcad = 'SELECT * FROM ['+@base+'].dbo.TempoRanking ORDER BY porcentaje DESC'
EXEC	(@smallcad)
CLOSE RANKINGCLIENTES
DEALLOCATE RANKINGCLIENTES 
RETURN
END
----------------------------------------------------------------------EN BASE A MONTO DE VENTAS
IF @monto > 0						
BEGIN   
SET	@cadena = 
'DECLARE RANKINGCLIENTES CURSOR FOR  
SELECT  
c.clientecodigo as CODIGO_CLIENTE, h.clienterazonsocial as RAZON_SOCIAL,      
TOTAL_NETO =   
isnull (  
ISNULL  (  
(SELECT   
SUM (isnull(  dbo.tipodoc (x.documentotipo,z.pedidototneto) ,0)) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_documento x    
ON      
  z.pedidotipofac = x.documentocodigo
WHERE  c.clientecodigo = z.clientecodigo  
AND z.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND z.pedidofechaanu IS NULL  and z.empresacodigo='''+@empresa+'''
AND z.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND  '''+@fechasta+'''
AND z.pedidomoneda = ''01'' )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (isnull(  dbo.tipodoc (r.documentotipo,p.pedidototneto) ,0)* isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_documento r    
ON      
  p.pedidotipofac = r.documentocodigo
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
  p.pedidofechafact = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.puntovtacodigo LIKE ('''+@codpuntoventa+''')    
AND p.pedidofechaanu IS NULL and p.empresacodigo='''+@empresa+'''
AND p.pedidofechafact BETWEEN  '''+@fecdesde+'''   AND  '''+@fechasta+'''
AND p.pedidomoneda = ''02'' )  
,0 )  
, 0 )    
,    
TOTAL_SIN_IGV =   
isnull (  
ISNULL  (  
(SELECT   
SUM ( isnull(  dbo.tipodoc (x.documentotipo,z.pedidototneto) ,0) - isnull(  dbo.tipodoc(x.documentotipo,z.pedidototimpuesto) ,0)  ) as IMPORTE_SOLES   
FROM  ['+@base+'].dbo.vt_pedido z     
JOIN     
['+@base+'].dbo.vt_documento x    
ON      
  z.pedidotipofac = x.documentocodigo
WHERE  c.clientecodigo = z.clientecodigo  
AND z.puntovtacodigo LIKE ('''+@codpuntoventa+''')    
AND z.pedidofechaanu IS NULL and z.empresacodigo='''+@empresa+'''
AND z.pedidofechafact BETWEEN '''+@fecdesde+'''  AND  '''+@fechasta+''' 
AND z.pedidomoneda = ''01'' )  
,0 )  
+  
ISNULL (  
(SELECT   
SUM (   (isnull(  dbo.tipodoc (r.documentotipo,p.pedidototneto)  ,0) - isnull(  dbo.tipodoc(r.documentotipo,p.pedidototimpuesto) ,0) )   * isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES   
FROM  ['+@base+'].dbo.vt_pedido p  
JOIN     
['+@base+'].dbo.vt_documento r    
ON      
  p.pedidotipofac = r.documentocodigo
LEFT JOIN     
['+@base+'].dbo.ct_tipocambio s    
ON      
  p.pedidofechafact = s.tipocambiofecha  
WHERE  c.clientecodigo = p.clientecodigo  
AND p.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND p.pedidofechaanu IS NULL  and p.empresacodigo='''+@empresa+'''
AND p.pedidofechafact BETWEEN  '''+@fecdesde+'''   AND  '''+@fechasta+'''
AND p.pedidomoneda = ''02'' )  
,0 )  
, 0 )      
 FROM     
 ['+@base+'].dbo.vt_pedido c    
 JOIN     
 ['+@base+'].dbo.vt_documento d    
 ON      
   c.pedidotipofac = d.documentocodigo
 LEFT JOIN     
 ['+@base+'].dbo.ct_tipocambio e    
 ON      
   c.pedidofechafact = e.tipocambiofecha  
 JOIN  
 ['+@base+'].dbo.vt_cliente h  
 ON  
   c.clientecodigo = h.clientecodigo   
WHERE     
  c.pedidofechafact  BETWEEN  '''+@fecdesde+'''   AND  '''+@fechasta+'''  
  AND  c.pedidofechaanu IS NULL and c.empresacodigo='''+@empresa+'''
  AND  c.puntovtacodigo LIKE ('''+@codpuntoventa+''')    
GROUP BY    
  c.clientecodigo , h.clienterazonsocial  
ORDER BY  TOTAL_NETO  DESC  '
EXEC (@cadena)
OPEN RANKINGCLIENTES
FETCH NEXT FROM RANKINGCLIENTES
INTO 
@vcodprod,
@vcoddesc,
@vtotalsoles,
@vtotalsinigv
WHILE @@FETCH_STATUS = 0
BEGIN
		SET @totmonto = @totmonto + @vtotalsoles
		IF  @totmonto <= @monto+1
		  BEGIN
		    SET @vporcventas = 	@vtotalsoles / @TotalNeto
		    SET @sensql = 
		    N'INSERT INTO ['+@base+'].dbo.TempoRanking 
		    VALUES (@vcodprod,@vcoddesc,@vtotalsinigv,@vtotalsoles,@vporcventas*100,null )'
		    SET @params=N'@vcodprod varchar(20),@vcoddesc varchar(80),@vtotalsinigv float,@vtotalsoles float, @vporcventas float'
		    EXEC sp_executesql @sensql,@params,@vcodprod,@vcoddesc,@vtotalsinigv,@vtotalsoles,@vporcventas
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
		@vtotalsinigv
END
SET	@smallcad = 'SELECT * FROM ['+@base+'].dbo.TempoRanking ORDER BY neto DESC'
EXEC	(@smallcad)
CLOSE RANKINGCLIENTES
DEALLOCATE RANKINGCLIENTES 
RETURN
END
GO
