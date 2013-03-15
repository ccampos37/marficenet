SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute vt_RankingArticulos 756630,0,100,0,'01/07/2009','31/12/2009','%%','ziyaz','%%'


SELECT PRODUCTOCODIGO ,PRODUCTOPRECVTA FROM ZIYAZ.DBO.LISTAPRE1 WHERE ISNULL(PRODUCTOPRECVTA,0) > 0
GROUP BY PRODUCTOCODIGO, PRODUCTOPRECVTA HAVING COUNT(*)=1

SELECT * FROM ZIYAZ.DBO.LISTAPRE1 WHERE PRODUCTOCODIGO IN 
(SELECT PRODUCTOCODIGO FROM ZIYAZ.DBO.LISTAPRE1 GROUP BY PRODUCTOCODIGO HAVING COUNT(*)=2
)
 GROUP BY PRODUCTOCODIGO HAVING COUNT(*)=2
 

*/
CREATE  PROC [vt_RankingArticulos] 	 			/* EN  USO*/
@montoventas float,  
@cantidad float,  
@porcentaje float,
@monto float,
@fecdesde varchar(10),
@fechasta varchar(10),
@codpuntoventa varchar(2),
@base varchar (50),
@empresa varchar (2),
@tipo varchar(1)='1'

AS  
DECLARE @params nvarchar(4000)
DECLARE @sensql nvarchar(4000)
DECLARE @smallcad varchar(4000)
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
SET 	@smallcad = 'DELETE FROM ['+@base+'].dbo.TempoRanking '
EXEC	(@smallcad)
------------------------------------------------------------------- EN BASE A PORCENTAJE DE VENTAS
IF @porcentaje > 0
BEGIN  
SET	@cadena = 
'DECLARE RANKINGARTICULOS CURSOR FOR 
SELECT a.productocodigo as CODIGO_PRODUCTO,
SUM(isnull(dbo.tipodoc(d.documentotipo,a.detpedcantentreg),0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  (
(SELECT 
SUM (isnull(    dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta) ,0) ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z  
 inner JOIN ['+@base+'].dbo.vt_pedido y  ON z.empresacodigo+z.pedidonumero = y.empresacodigo+y.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento x  ON  y.pedidotipofac = x.documentocodigo
LEFT JOIN  ['+@base+'].dbo.vt_modoventa k ON  k.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND isnull(y.pedidocondicionfactura,''0'')<>''1'' /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and y.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
and isnull(k.modovtacanje,0)<>''1''
AND y.pedidomoneda = ''01'' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(   dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta) ,0) * isnull(s.tipocambioventa,0)) as IMPORTE_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN ['+@base+'].dbo.vt_pedido q  ON p.empresacodigo+p.pedidonumero = q.empresacodigo+q.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento r  ON q.pedidotipofac = r.documentocodigo
LEFT JOIN   ['+@base+'].dbo.ct_tipocambio s ON  q.pedidofechafact = s.tipocambiofecha
LEFT JOIN   ['+@base+'].dbo.vt_modoventa w ON w.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND isnull(q.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and q.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
and isnull(w.modovtacanje,0)<>''1''
AND q.pedidomoneda = ''02'' )
,0 )
, 0 )
,
PORCENTAJE_VENTAS = 
(
ISNULL  (
(SELECT 
SUM (isnull(   dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta)   ,0)  ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
inner JOIN ['+@base+'].dbo.vt_pedido y ON   z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento x ON    y.pedidotipofac = x.documentocodigo
LEFT JOIN  ['+@base+'].dbo.vt_modoventa a1 ON    a1.modovtacodigo = y.modovtacodigo
WHERE  a.productocodigo = z.productocodigo and z.productocodigo<>''000''
AND y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND isnull(y.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */' 
if @empresa<>'%%' set @cadena=@cadena+ ' and y.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(    dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta)  , 0) * isnull(s.tipocambioventa,0) ) as IMPORTE_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN ['+@base+'].dbo.vt_pedido q  ON   p.empresacodigo=q.empresacodigo and p.pedidonumero = q.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento r  ON    q.pedidotipofac = r.documentocodigo
LEFT JOIN  ['+@base+'].dbo.ct_tipocambio s ON    q.pedidofechafact = s.tipocambiofecha
LEFT JOIN ['+@base+'].dbo.vt_modoventa b1 ON    b1.modovtacodigo = q.modovtacodigo
WHERE  a.productocodigo = p.productocodigo and p.productocodigo<>''000''
AND q.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND isnull(q.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and q.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
and isnull(b1.modovtacanje,0)<>''1''
AND q.pedidomoneda = ''02'' )
,0 )
 )
/
(
isnull (
(SELECT 
SUM (isnull(   dbo.tipodoc(o.documentotipo,m.detpedmontoprecvta) ,0)  ) as IMP_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido m   
inner JOIN ['+@base+'].dbo.vt_pedido n  ON  m.empresacodigo=n.empresacodigo and m.pedidonumero = n.pedidonumero
JOIN   
['+@base+'].dbo.vt_documento o  
ON    
  n.pedidotipofac = o.documentocodigo
LEFT JOIN   
['+@base+'].dbo.vt_modoventa c1  
ON    
  c1.modovtacodigo = n.modovtacodigo
WHERE isnull(n.pedidocondicionfactura,''0'')<>''1''  and m.productocodigo<>''000''  and isnull(c1.modovtacanje,0)<>1 ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and n.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND n.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND n.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND n.pedidomoneda = ''01'' )  , 0 )
+
isnull (
(SELECT    
SUM (isnull(   dbo.tipodoc(l.documentotipo,j.detpedmontoprecvta)  ,0) * isnull(i.tipocambioventa,0) ) as IMP_DOLARES 
FROM  ['+@base+'].dbo.vt_detallepedido j
JOIN   
['+@base+'].dbo.vt_pedido k  
ON    j.empresacodigo=k.empresacodigo and j.pedidonumero = k.pedidonumero
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
WHERE isnull(k.pedidocondicionfactura,''0'')<>''1''  and j.productocodigo<>''000''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and k.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND k.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND k.pedidofechafact BETWEEN    '''+@fecdesde+'''  AND '''+@fechasta+'''
AND k.pedidomoneda = ''02'' )
, 0 )
 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 JOIN   
['+@base+'].dbo.vt_pedido c  
 ON  a.empresacodigo=c.empresacodigo and a.pedidonumero = c.pedidonumero
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
  AND isnull(c.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and c.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND c.puntovtacodigo LIKE ('''+@codpuntoventa+''')   
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
		    N'INSERT INTO ['+@base+'].dbo.TempoRanking 
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
'SELECT a.* , b.adescri ,saldo , precio=isnull(d.PRODUCTOPRECVTA,0) FROM ['+@base+'].dbo.TempoRanking a 
inner JOIN ['+@base+'].dbo.maeart b ON  a.codigo = b.acodigo 
left join ( select stcodigo , saldo=sum(stskdis) from ['+@base+'].dbo.stkart a
            inner join ['+@base+'].dbo.tabalm b on a.stalma=b.taalma
            where tipoalmacencodigo=''1'' group by stcodigo 
           ) c on a.codigo=c.stcodigo
LEFT join  ['+@base+'].dbo.listapre1 d on a.codigo=d.productocodigo
ORDER BY a.porcentaje DESC '

execute (@smallcad)

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
SUM(isnull(dbo.tipodoc(d.documentotipo,a.detpedcantentreg),0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  (
(SELECT 
SUM (isnull(  dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta)  , 0) ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
JOIN   
['+@base+'].dbo.vt_pedido y  
ON    z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
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
AND isnull(y.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and y.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' )
,0 )
+
ISNULL (
(SELECT 
SUM (isnull(  dbo.tipodoc(r.documentotipo,p.detpedmontoprecvta)  ,0)* isnull(s.tipocambioventa,0) ) as IMPORTE_DOLARES 
 FROM  ['+@base+'].dbo.vt_detallepedido p
inner JOIN   
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
AND isnull(q.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and q.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' )
,0 )
, 0 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 JOIN   
 ['+@base+'].dbo.vt_pedido c  
 ON  a.empresacodigo=c.empresacodigo and a.pedidonumero = c.pedidonumero
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
  AND isnull(c.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and c.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND c.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
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
                N'INSERT INTO ['+@base+'].dbo.TempoRanking 
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
'SELECT a.* , b.adescri ,saldo, precio=isnull(d.PRODUCTOPRECVTA,0)  FROM ['+@base+'].dbo.TempoRanking a 
inner JOIN ['+@base+'].dbo.maeart b ON  a.codigo = b.acodigo 
left join ( select stcodigo , saldo=sum(stskdis) from ['+@base+'].dbo.stkart a
            inner join ['+@base+'].dbo.tabalm b on a.stalma=b.taalma
             where tipoalmacencodigo=''1'' group by stcodigo
           ) c on a.codigo=c.stcodigo
LEFT join  ['+@base+'].dbo.listapre1 d on a.codigo=d.productocodigo
ORDER BY a.cant_totsinigv DESC '
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
SUM(isnull(dbo.tipodoc(d.documentotipo,a.detpedcantentreg),0)) as CANTIDAD,  
TOTAL_SOLES = 
isnull (
ISNULL  ( (SELECT 
SUM (isnull(  dbo.tipodoc(x.documentotipo,z.detpedmontoprecvta) ,0) ) as IMPORTE_SOLES 
FROM  ['+@base+'].dbo.vt_detallepedido z   
JOIN   
['+@base+'].dbo.vt_pedido y  
ON    z.empresacodigo=y.empresacodigo and z.pedidonumero = y.pedidonumero
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
AND isnull(y.pedidocondicionfactura,''0'')<>''1'' /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and y.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND y.pedidomoneda = ''01'' )
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
AND isnull(q.pedidocondicionfactura,''0'')<>''1''   /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and q.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND q.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
AND q.pedidomoneda = ''02'' )
,0 )
, 0 )
 FROM  ['+@base+'].dbo.vt_detallepedido a   
 JOIN   
 ['+@base+'].dbo.vt_pedido c  
 ON    a.empresacodigo=c.empresacodigo and a.pedidonumero = c.pedidonumero
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
  AND  isnull(c.pedidocondicionfactura,''0'')<>''1''  /* and isnull(a1.modovtacanje,0)<>1 */ ' 
if @empresa<>'%%' set @cadena=@cadena+ ' and c.empresacodigo='''+@empresa+''' ' 
set @cadena=@cadena+' AND  c.puntovtacodigo LIKE ('''+@codpuntoventa+''')   
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
                N'INSERT INTO ['+@base+'].dbo.TempoRanking 
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
'SELECT a.* , b.adescri,saldo, precio=isnull(d.PRODUCTOPRECVTA,0)  FROM ['+@base+'].dbo.TempoRanking a 
inner JOIN ['+@base+'].dbo.maeart B ON  a.codigo = b.acodigo 
left join ( select stcodigo , saldo=sum(stskdis) from ['+@base+'].dbo.stkart a
            inner join ['+@base+'].dbo.tabalm b on a.stalma=b.taalma
            where tipoalmacencodigo=''1'' group by stcodigo 
          ) c on a.codigo=c.stcodigo
LEFT join  ['+@base+'].dbo.listapre1 d on a.codigo=d.productocodigo
ORDER BY a.neto DESC '
exec(@smallcad)
CLOSE RANKINGARTICULOS 
DEALLOCATE RANKINGARTICULOS
END
RETURN
GO
