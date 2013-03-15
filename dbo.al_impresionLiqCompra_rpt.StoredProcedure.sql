SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [al_impresionLiqCompra_rpt]
@base varchar(50),
@numero varchar(11)
as
declare @ncadena varchar(3000)
Set @ncadena=N'Select a.pedidonumero,a.pedidofecha,a.clientecodigo,a.clienterazonsocial,a.pedidonrofact,
    a.pedidototbruto,a.pedidototneto,a.clientedireccion,
    b.detpedcantdespach,b.productocodigo,b.detpedmontoprecvta,
    detalletotneto=round(b.detpedcantdespach* b.detpedmontoprecvta,4),
    c.adescri,c.aunidad 
from ['+@base+'].dbo.al_liquidacioncompra a 
             LEFT  join ['+@base+'].dbo.al_detalleliquidacioncompra b 
                  on a.pedidonumero=b.pedidonumero
             LEFT  join ['+@base+'].dbo.maeart c
 		   On b.productocodigo=c.acodigo 
	  Where RTRIM(A.pedidonumero)='''+@numero+''''
execute (@ncadena)
--execute al_impresionLiqCompra_rpt 'pacific_TEMP','00000021'
--SELECT * FROM PACIFIC_TEMP.DBO.VT_detallePEDIDO
GO
