SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [vt_actualizoalmacen_pro]
@basedes  varchar(50),
@almacen varchar(2),
@tipo char(1),
@articulo varchar(20),
@cantidad float
as
Declare @cadena nvarchar(4000)
Declare @parame nvarchar(4000)
If @tipo='1'
    Begin
	Set @cadena=N'Update ['+@basedes+'].dbo.articulo  
                      Set arm_stock=arm_stock-@cantidad,
                          arm_salidas=arm_salidas+@cantidad
	              Where arm_codart=@articulo and arm_codcia=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
if @tipo='2'
     Begin
	Set @cadena=N'Update ['+@basedes+'].dbo.articulo  
                      Set arm_stock=arm_stock+@cantidad,
                          arm_salidas=arm_salidas-@cantidad
	              Where arm_codart=@articulo and arm_codcia=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
GO
