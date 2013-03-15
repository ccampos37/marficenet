SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [fn_PrecioUnitario]
(@producto_id as varchar(5),@fecha as smalldatetime)      
RETURNS float
BEGIN 	

Declare @PrecioUnitario as float
Declare @TipoCambio as float

	Set @TipoCambio=(Select TipoCambioVenta From Planta_Casma.dbo.ct_tipocambio Where tipocambiofecha =@fecha)

	Set @PrecioUnitario =(Select Case c.moneda_id When '001' Then sum(c.preciounitario) When '002' Then sum(c.preciounitario)*@TipoCambio End as PrecioUnitario
			From(Select a.producto_id,Case unidadmedida_id 	When '4'then b.precio_unitario 
				When '24' Then b.precio_unitario/1000 When '1' Then b.precio_unitario/5.5*144 end as preciounitario,
				b.moneda_id
				From Planta10.dbo.productoconcepto_pago a
				Inner Join Planta10.dbo.concepto_pago b On a.id_concepto = b.id_concepto And 
					b.id_concepto not in ('00033','00034','00035','00036','00037','00039','00040','00041','00042','00043')) c
			Where c.producto_id=@producto_id Group By producto_id, moneda_id )

	Return @PrecioUnitario
    	
END
GO
