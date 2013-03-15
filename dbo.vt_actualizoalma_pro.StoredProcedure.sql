SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [vt_actualizoalma_pro]
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
	Set @cadena=N'Update ['+@basedes+'].dbo.STKART
                      Set STSKDIS=STSKDIS-@cantidad
	              Where STCODIGO=@articulo and STALMA=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
if @tipo='2'
     Begin
	Set @cadena=N'Update ['+@basedes+'].dbo.STKART
                      Set STSKDIS=STSKDIS+@cantidad
	              Where STCODIGO=@articulo and STALMA=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
-- stock comprometido
if @tipo='3'
     Begin
	Set @cadena=N'Update ['+@basedes+'].dbo.STKART
                      Set STSKcom=STSKcom+@cantidad
	              Where STCODIGO=@articulo and STALMA=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
---  disminuye stock fisico y comprometido
if @tipo='4'
     Begin
	Set @cadena=N'Update ['+@basedes+'].dbo.STKART
                      Set STSKDIS=STSKDIS - @cantidad ,
                             STSKcom=STSKcom - @cantidad
	              Where STCODIGO=@articulo and STALMA=@almacen'
	
	Set @parame=N'@cantidad float,@articulo varchar(20),@almacen varchar(2)'
	 
	execute sp_executesql @cadena,@parame,@cantidad,@articulo,@almacen
   End
GO
