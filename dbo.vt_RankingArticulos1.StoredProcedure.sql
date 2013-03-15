SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [vt_RankingArticulos1] 0,0,0,0,'01/07/2009','31/12/2009','%%','ziyaz','02'

*/

CREATE PROC [vt_RankingArticulos1] 	 			/* EN  USO*/
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
DECLARE @sql nvarchar(4000)

set @sql=' select productocodigo, 
TOTAL_SOLES =sum(case when pedidomoneda=''01'' then isnull(dbo.tipodoc(c.documentotipo,b.detpedmontoprecvta),0)
                      else  isnull(dbo.tipodoc(c.documentotipo,b.detpedmontoprecvta),0) * isnull(d.tipocambioventa,0) end )
from ['+@base+'].dbo.vt_pedido a  
inner JOIN ['+@base+'].dbo.vt_detallepedido b  ON   a.empresacodigo+a.pedidonumero=b.empresacodigo +b.pedidonumero
inner JOIN ['+@base+'].dbo.vt_documento c  ON    a.pedidotipofac = c.documentocodigo
LEFT JOIN  ['+@base+'].dbo.ct_tipocambio d ON    a.pedidofechafact = d.tipocambiofecha
LEFT JOIN ['+@base+'].dbo.vt_modoventa e ON    a.modovtacodigo = e.modovtacodigo
WHERE  a.puntovtacodigo LIKE ('''+@codpuntoventa+''')  
AND isnull(a.pedidocondicionfactura,''0'')<>''1'' and isnull(e.modovtacanje,0)<>1' 
if @empresa<>'%%' set @sql=@sql + ' and a.empresacodigo='''+@empresa+''' ' 
set @sql=@sql +' AND a.pedidofechafact BETWEEN  '''+@fecdesde+'''  AND '''+@fechasta+'''
and isnull(e.modovtacanje,0)<>''1''
group by productocodigo '

print (@sql)
GO
