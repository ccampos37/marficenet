SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROC [vt_RankingClienteProducto]
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente varchar(20),
@codpuntoventa varchar(2),
@base varchar (50)
AS  
DECLARE @smallcad varchar(200)
DECLARE @cadena varchar(8000)
SET 	@smallcad = 'DELETE FROM ['+@base+'].dbo.TempoRanking '
EXEC	(@smallcad)
------------------------------------------------------------------- EN BASE A PORCENTAJE DE VENTAS
SET	@cadena = 
'SELECT a.clientecodigo as CODIGO_CLIENTE,a.clienterazonsocial as RAZON_SOCIAL,
c.productocodigo,d.adescri,year(a.pedidofechafact) as anno,
month(a.pedidofechafact) as mes,
sum(c.detpedcantdespach) as cantidad,sum(c.detpedmontoprecvta) as monto
FROM  ['+@base+'].dbo.vt_pedido a  
JOIN  ['+@base+'].dbo.vt_documento b    
    ON a.pedidotipofac = b.documentocodigo 
inner join ['+@base+'].dbo.vt_detallepedido c
    ON a.pedidonumero = c.pedidonumero
left join ['+@base+'].dbo.maeart d
    on c.productocodigo = d.acodigo
where a.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND a.pedidofechaanu IS NULL 
AND a.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''  
AND a.pedidomoneda = ''01'' 
and a.clientecodigo like ('''+@codcliente+''')
group by a.clientecodigo,a.clienterazonsocial,c.productocodigo,
      d.adescri,year(a.pedidofechafact),month(a.pedidofechafact)
order by a.clientecodigo,c.productocodigo COLLATE Modern_Spanish_CI_AS'
execute (@cadena)
---execute vt_RankingClienteProducto '01/01/2004','31/12/2004','%','%','fox' 
--use fox
--select * from vt_pedido
GO
