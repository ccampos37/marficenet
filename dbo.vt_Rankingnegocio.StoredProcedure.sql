SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute vt_Rankingnegocio 'tabor','01','01/07/2007','31/12/2007'
---drop proc vt_Rankingnegocio
CREATE   PROC [vt_Rankingnegocio]  	 	
@base varchar (50),
@codpuntoventa varchar(2),
@fecdesde varchar(10),
@fechasta varchar(10)
AS  
declare @smallcad varchar(1000)
DECLARE @cadena varchar(8000)
SET 	@smallcad = 'DELETE FROM ['+@base+'].dbo.TempoRanking '
EXEC	(@smallcad)
------------------------------------------------------------------- EN BASE A PORCENTAJE DE VENTAS
SET	@cadena = 
 
' SELECT m.negociodescripcion,
 SUM(isnull(Z.detpedcantentreg,0)) as CANTIDAD,sum(z.detpedimpbruto) as total
FROM  ['+@base+'].dbo.vt_detallepedido z   
left JOIN ['+@base+'].dbo.vt_pedido y ON z.pedidonumero = y.pedidonumero
left join ['+@base+'].dbo.vt_cliente l ON y.clientecodigo = l.clientecodigo
left join ['+@base+'].dbo.vt_negocio m ON l.negociocodigo = m.negociocodigo
WHERE y.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND y.pedidofechaanu IS NULL 
---AND y.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
group by m.negociodescripcion '
exec(@CADENA)
---EXECUTE VT_RANKINGNEGOCIO 'tabor','%%','01/01/2007','05/12/2007'
GO
