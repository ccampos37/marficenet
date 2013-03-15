SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Objeto:  StoredProcedure [dbo].[vt_RankingArticulos]    Fecha de la secuencia de comandos: 06/13/2009 20:30:19 
execute vt_RankingArticulos 49000,30,0,0,'01/06/2009','15/07/2009','%%','ziyaz','03'

*/


create     PROC [vt_RankingArticulos_dolares]  	 			/* EN  USO*/
@montoventas float,  
@cantidad float,  
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
DECLARE @smallcad varchar(400)
DECLARE @cadena varchar(8000)
DECLARE @vcodprod varchar(20)	-- Cod.Producto
DECLARE @vcoddesc varchar(80)	-- Descripcion
DECLARE @vcantidad float	-- Cantidad
DECLARE @vtotalsoles float	-- Total Neto
DECLARE @vporcventas float	-- Porcentaje
DECLARE @vcodalmacen varchar(4)	-- Cod.Almacen
DECLARE @totporcentaje decimal	-- Acumulador porcentaje
DECLARE @totmonto float		-- Acumulador total neto
DECLARE @totcantidad float	-- Acumulador cantidad
SET	@totporcentaje = cast(0.0000 as float)
SET	@totmonto = 0.0000
SET	@totcantidad = 0.0000
SET 	@smallcad = 'DELETE FROM ['+@base+'].dbo.temporanking '
EXEC	(@smallcad)
------------------------------------------------------------------- EN BASE A PORCENTAJE DE VENTAS
IF @porcentaje > 0
BEGIN  
SET	@cadena = 
'DECLARE RANKINGARTICULOS CURSOR FOR 
SELECT
a.productocodigo as CODIGO_PRODUCTO,
SUM(isnull(a.detpedcantentreg,0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  (
(SELECT 
SUM (isnull(    dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta) ,0) --/ isnull(s.tipocambioventa,1)) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
inner JOIN ['+@base+'].dbo.vt_pedido y  
ON z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
LEFT JOIN   ['+@base+'].dbo.ct_tipocambio s ON Y.pedidofechafact = s.tipocambiofecha
inner JOIN ['+@base+'].dbo.vt_documento x  ON  y.pedidotipofac = x.documentocodigo
LEFT JOIN  ['+@base+'].dbo.vt_modoventa k ON k.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND y.pedidofechaanu IS NULL 
AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01''  and z.empresacodigo='''+@empresa+''' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(   dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta) ,0) ) as IMPORTE_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN ['+@base+'].dbo.vt_pedido q  ON p.empresacodigo=q.empresacodigo and p.pedidonumero = q.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento r ON q.pedidotipofac = r.documentocodigo
LEFT JOIN   ['+@base+'].dbo.ct_tipocambio s ON q.pedidofechafact = s.tipocambiofecha
LEFT JOIN   ['+@base+'].dbo.vt_modoventa w ON w.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND q.pedidofechaanu IS NULL 
AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' and p.empresacodigo='''+@empresa+''' )
,0 )
, 0 )
,
PORCENTAJE_VENTAS = 
(
ISNULL  (
(SELECT 
SUM (isnull(   dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta)   ,0)/ isnull(s.tipocambioventa,1)  ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
inner join ['+@base+'].dbo.vt_pedido y  ON z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
LEFT JOIN   ['+@base+'].dbo.ct_tipocambio s ON y.pedidofechafact = s.tipocambiofecha
JOIN   
['+@base+'].dbo.vt_documento x  
ON    
  y.pedidotipofac = x.documentocodigo
LEFT JOIN   
['+@base+'].dbo.vt_modoventa a1  
ON    
  a1.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND y.pedidofechaanu IS NULL 
AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' and z.empresacodigo='''+@empresa+''' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(    dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta)  , 0)  ) as IMPORTE_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN ['+@base+'].dbo.vt_pedido q ON p.empresacodigo=q.empresacodigo and p.pedidonumero = q.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento r  
ON    
  q.pedidotipofac = r.documentocodigo
LEFT JOIN   
['+@base+'].dbo.ct_tipocambio s  
ON    
  q.pedidofechafact = s.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa b1
ON    
  b1.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND q.pedidofechaanu IS NULL 
AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' and p.empresacodigo='''+@empresa+''' )
,0 )
 )
/
(
isnull (
(SELECT 
SUM (isnull(   dbo.tipodoc(o.documentotipo,m.detpedmontoprecvta) ,0) / isnull(i.tipocambioventa,1) ) as IMP_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido m  
inner JOIN ['+@base+'].dbo.vt_pedido n  ON m.empresacodigo=n.empresacodigo and m.pedidonumero = n.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento o  
ON    
  n.pedidotipofac = o.documentocodigo
LEFT JOIN   
['+@base+'].dbo.vt_modoventa c1  
ON    
  c1.modovtacodigo = n.modovtacodigo
LEFT JOIN   
['+@base+'].dbo.ct_tipocambio i
ON    
 n.pedidofechafact = i.tipocambiofecha
WHERE
n.pedidofechaanu IS NULL  and m.productocodigo<>''000''
AND n.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND n.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND n.pedidomoneda = ''01'' and m.empresacodigo='''+@empresa+''' )  , 0 )
+
isnull (
(SELECT    
SUM (isnull(   dbo.tipodoc(l.documentotipo,j.detpedmontoprecvta)  ,0)  ) as IMP_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido j
inner JOIN ['+@base+'].dbo.vt_pedido k ON j.empresacodigo=k.empresacodigo and j.pedidonumero = k.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento l  
ON    
  k.pedidotipofac = l.documentocodigo
LEFT JOIN   
['+@base+'].dbo.ct_tipocambio i
ON    
 k.pedidofechafact = i.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa d1  
ON    
  d1.modovtacodigo = k.modovtacodigo
WHERE 
k.pedidofechaanu IS NULL  and j.productocodigo<>''000''
AND k.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND k.pedidofechafact BETWEEN    '''+@fecdesde+'''  AND '''+@fechasta+'''
AND k.pedidomoneda = ''02'' and j.empresacodigo='''+@empresa+''' )
, 0 )
 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 inner JOIN ['+@base+'].dbo.vt_pedido c  ON a.empresacodigo=c.empresacodigo and a.pedidonumero = c.pedidonumero
 JOIN   
 ['+@base+'].dbo.vt_documento d  
 ON    
  c.pedidotipofac = d.documentocodigo
 LEFT JOIN   
 ['+@base+'].dbo.ct_tipocambio e  
 ON    
  c.pedidofechafact = e.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa e1  
ON    
  e1.modovtacodigo = c.modovtacodigo
WHERE   
  c.pedidofechafact BETWEEN '''+@fecdesde+'''  AND '''+@fechasta+'''   and a.productocodigo<>''000''
  AND c.pedidofechaanu IS NULL 
  AND c.puntovtacodigo LIKE ('''+@codpuntoventa+''') and a.empresacodigo='''+@empresa+'''   
GROUP BY  
  a.productocodigo 
ORDER BY  PORCENTAJE_VENTAS  DESC  '
execute (@cadena)
OPEN RANKINGARTICULOS
FETCH NEXT FROM RANKINGARTICULOS
INTO 
@vcodprod,
@vcantidad,
@vtotalsoles,
@vporcventas
set @totporcentaje=cast(0.000 as float)
WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @totporcentaje = cast(@totporcentaje as float) +  cast(@vporcventas * 100.000 as float)  
	IF  @totporcentaje <= @porcentaje+1
	BEGIN	
		    SET @sensql = 
		    N'INSERT INTO ['+@base+'].dbo.temporanking 
		    VALUES (@vcodprod,null,@vcantidad,@vtotalsoles,@vporcventas * 100.000,NULL)'
		    SET @params=N'@vcodprod varchar(20),@vcantidad float,@vtotalsoles float,@vporcventas float'
		    EXEC sp_executesql @sensql,@params,@vcodprod,@vcantidad,@vtotalsoles,@vporcventas
	END
	ELSE			
	BEGIN
 		BREAK
	END
	FETCH NEXT FROM RANKINGARTICULOS
	INTO 
	@vcodprod,
	@vcantidad,
	@vtotalsoles,
	@vporcventas
	END
SET	@smallcad =
'SELECT a.* , b.adescri  FROM ['+@base+'].dbo.temporanking a JOIN ['+@base+'].dbo.maeart b
ON  a.codigo = b.acodigo where isnull(afstock,1)=1 ORDER BY a.porcentaje DESC '
EXEC	(@smallcad)
CLOSE RANKINGARTICULOS
DEALLOCATE RANKINGARTICULOS
END
   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @cantidad > 0 					-- EN BASE A CANTIDAD DE ARTICULOS
BEGIN
SET	@cadena = 
'DECLARE RANKINGARTICULOS CURSOR FOR
SELECT
a.productocodigo as CODIGO_PRODUCTO,
SUM(isnull(a.detpedcantentreg,0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  (
(SELECT 
SUM (isnull(  dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta)  , 0) ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
inner JOIN ['+@base+'].dbo.vt_pedido y ON z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento x  
ON    
  y.pedidotipofac = x.documentocodigo
LEFT JOIN   
['+@base+'].dbo.vt_modoventa a1  
ON    
  a1.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND y.pedidofechaanu IS NULL 
AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' and z.empresacodigo='''+@empresa+''' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(  dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta)  ,0)* isnull(s.tipocambioventa,0) ) as IMPORTE_DOLARES  
FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN   
['+@base+'].dbo.vt_pedido q  ON p.empresacodigo=q.empresacodigo and p.pedidonumero = q.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento r  
ON    
  q.pedidotipofac = r.documentocodigo
LEFT JOIN   
['+@base+'].dbo.ct_tipocambio s  
ON    
  q.pedidofechafact = s.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa b1  
ON    
  b1.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND q.pedidofechaanu IS NULL 
AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' and p.empresacodigo='''+@empresa+''' )
,0 )
, 0 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 JOIN   
 ['+@base+'].dbo.vt_pedido c  
 ON    a.empresacodigo=c.empresacodigo and  a.pedidonumero = c.pedidonumero
 JOIN   
 ['+@base+'].dbo.vt_documento d  
 ON    
  c.pedidotipofac = d.documentocodigo
 LEFT JOIN   
 ['+@base+'].dbo.ct_tipocambio e  
 ON    
  c.pedidofechafact = e.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa c1  
ON    
  c1.modovtacodigo = c.modovtacodigo
WHERE   
  c.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''   and a.productocodigo<>''000''
  AND c.pedidofechaanu IS NULL  
  AND c.puntovtacodigo LIKE ('''+@codpuntoventa+''') and a.empresacodigo='''+@empresa+''' 
GROUP BY  
 a.productocodigo
ORDER BY  CANTIDAD  DESC '
EXEC (@cadena)
OPEN RANKINGARTICULOS
FETCH NEXT FROM RANKINGARTICULOS
INTO 
@vcodprod,
@vcantidad,
@vtotalsoles
WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @totcantidad = @totcantidad + 1
	IF  @totcantidad <= @cantidad
	BEGIN
		SET @vporcventas = @vtotalsoles/@montoventas
		SET @sensql = 
                N'INSERT INTO ['+@base+'].dbo.temporanking 
		VALUES (@vcodprod,null,@vcantidad,@vtotalsoles,@vporcventas*100,NULL)'
		SET @params=N'@vcodprod varchar(20),@vcantidad float,@vtotalsoles float,@vporcventas float'
		EXEC sp_executesql @sensql,@params,@vcodprod,@vcantidad,@vtotalsoles,@vporcventas
	END
	ELSE
	BEGIN
 		BREAK
	END 
	FETCH NEXT FROM RANKINGARTICULOS 
	INTO 
	@vcodprod,
	@vcantidad,
	@vtotalsoles
	END
SET	@smallcad =
'SELECT a.* , b.adescri  FROM ['+@base+'].dbo.temporanking a JOIN ['+@base+'].dbo.maeart b
ON  a.codigo = b.acodigo where isnull(afstock,1)=1 ORDER BY a.cant_totsinigv DESC '
EXEC	(@smallcad)
CLOSE RANKINGARTICULOS 
DEALLOCATE RANKINGARTICULOS
END
------------------------------------------------------------------------------------------------------------------------------------------------------
IF @monto > 0 					-- EN BASE A MONTO DE VENTAS 
BEGIN
SET	@cadena = 
'DECLARE RANKINGARTICULOS CURSOR FOR
SELECT
a.productocodigo as CODIGO_PRODUCTO,
SUM(isnull(a.detpedcantentreg,0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  ( (SELECT 
SUM (isnull(  dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta) ,0) ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
JOIN   
['+@base+'].dbo.vt_pedido y  
ON   z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento x  
ON    
  y.pedidotipofac = x.documentocodigo
LEFT JOIN   
['+@base+'].dbo.vt_modoventa a1  
ON    
  a1.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND y.pedidofechaanu IS NULL 
AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' and z.empresacodigo='''+@empresa+''' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(  dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta) ,0) * isnull(s.tipocambioventa,0) ) as IMPORTE_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido p
JOIN   
['+@base+'].dbo.vt_pedido q  
ON    p.empresacodigo=q.empresacodigo and p.pedidonumero = q.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento r  
ON    
  q.pedidotipofac = r.documentocodigo
LEFT JOIN   
['+@base+'].dbo.ct_tipocambio s  
ON    
  q.pedidofechafact = s.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa b1
ON    
  b1.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND q.pedidofechaanu IS NULL  
AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' and p.empresacodigo='''+@empresa+''' )
,0 )
, 0 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 JOIN   
 ['+@base+'].dbo.vt_pedido c  
 ON a.empresacodigo=c.empresacodigo and  a.pedidonumero = c.pedidonumero
 JOIN   
 ['+@base+'].dbo.vt_documento d  
 ON    
  c.pedidotipofac = d.documentocodigo
 LEFT JOIN   
 ['+@base+'].dbo.ct_tipocambio e  
 ON    
  c.pedidofechafact = e.tipocambiofecha
LEFT JOIN   
['+@base+'].dbo.vt_modoventa c1
ON    
  c1.modovtacodigo = c.modovtacodigo
WHERE   
  c.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''  and a.productocodigo<>''000''
  AND  c.pedidofechaanu IS NULL 
  AND  c.puntovtacodigo LIKE ('''+@codpuntoventa+''') and a.empresacodigo='''+@empresa+'''   
GROUP BY  
  a.productocodigo 
ORDER BY  TOTAL_SOLES  ASC '
execute (@cadena)
OPEN RANKINGARTICULOS
FETCH NEXT FROM RANKINGARTICULOS
INTO 
@vcodprod,
@vcantidad,
@vtotalsoles
WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @totmonto = @totmonto + @vtotalsoles
	IF  @totmonto <= @monto+1
	BEGIN
		SET @vporcventas = @vtotalsoles/@montoventas
		SET @sensql = 
                N'INSERT INTO ['+@base+'].dbo.temporanking 
		VALUES (@vcodprod,null,@vcantidad,@vtotalsoles,@vporcventas*100,NULL)'
		SET @params=N'@vcodprod varchar(20),@vcantidad float,@vtotalsoles float,@vporcventas float'
		EXEC sp_executesql @sensql,@params,@vcodprod,@vcantidad,@vtotalsoles,@vporcventas
	
	END
	ELSE
	BEGIN
 		BREAK
	END
	FETCH NEXT FROM RANKINGARTICULOS
	INTO 
	@vcodprod,
	@vcantidad,
	@vtotalsoles
	END
SET	@smallcad =
'SELECT a.* , b.adescri  FROM ['+@base+'].dbo.temporanking 
a JOIN ['+@base+'].dbo.maeart B
 ON  a.codigo = b.acodigo where isnull(afstock,1)=1 ORDER BY a.neto DESC '
exec(@smallcad)
CLOSE RANKINGARTICULOS 
DEALLOCATE RANKINGARTICULOS
END
RETURN
GO
