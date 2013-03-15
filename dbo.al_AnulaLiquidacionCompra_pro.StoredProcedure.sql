SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [al_AnulaLiquidacionCompra_pro]
@base varchar(50),
@docu char(11),
@tipo char(2),
@proveedor nvarchar(11),
@nume char(11),
@fanula datetime
as
Declare @cadena nvarchar(1000)
Declare @param nvarchar(100)
Declare @valor2 char(1)
    
   set @valor2='1'
   Set @cadena='Update ['+@base+'].dbo.al_liquidacioncompra
                Set pedidocondicionfactura='+@valor2+',
                    pedidofechaanu=@fanula
                Where pedidonumero=@docu'
   Set @param=N'@docu char(11),
		@tipo char(2),
		@nume char(11),
		@proveedor nvarchar(11),
		@fanula datetime'
    --Anular el Vt_pedido   Para Anular se usa el Valor : 1
   BEGIN TRAN T1
   EXEC sp_executesql  @cadena,@param,@docu,
					@tipo,
					@nume,
					@proveedor,
   					@fanula
   Set @cadena='Update ['+@base+'].dbo.al_detalleLiquidacionCompra Set detpedestado='+@valor2+' Where pedidonumero=@docu'
   Set @param=N'@docu char(11),
		@tipo char(2),
		@proveedor nvarchar(11),
		@nume char(11)'
   EXEC sp_executesql  @cadena,@param,@docu,
					@tipo,
					@proveedor,
					@nume
   set @cadena='Update ['+@base+'].dbo.cp_cargo Set cargoapeflgreg='+@valor2+' where documentocargo=@tipo and cargonumdoc=@nume'
   Set @param=N'@docu char(11),
		@tipo char(2),
		@proveedor nvarchar(11),
		@nume char(11)'
   EXEC sp_executesql  @cadena,@param,@docu,
					@tipo,
					@proveedor,
					@nume
   COMMIT TRAN T1
GO
