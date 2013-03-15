SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [tj_ingresadet_detalleordenpedido_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@producto varchar(20),
@color varchar(20),
@cantidad float,
@acabado varchar(20),
@proceso varchar(20),
@estado varchar(1)
as 
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
 		Begin
		  Set @ncade=N'DELETE FROM ['+@base+'].dbo.tj_det_detalleorden
									 WHERE tjordenum=@pedido and acodigo=@producto and cod_color=@color'
 		  Set @npara=N'@pedido integer,
									@producto varchar(20),
									@color varchar(20)'
		
 		  execute sp_executesql @ncade,@npara,@pedido,
																				 @producto,
																					@color
			Set @ncade=N'Insert into ['+@base+'].dbo.tj_det_detalleorden
    							 (tjordenum,
										acodigo,
										cod_color,
										cantidad,
										acabado,
										proceso,
										estado)
									 VALUES (
										@pedido,
										@producto,
										@color,
										@cantidad,
										@acabado,
										@proceso,
										@estado)'
  End
 set @npara=N'@pedido integer,
							@producto varchar(20),
							@color varchar(20),
							@cantidad float,
							@acabado varchar(20),
							@proceso varchar(20),
							@estado varchar(1)'
execute sp_executesql @ncade,@npara,@pedido,
																		@producto,
																		@color,
																		@cantidad,
																		@acabado,
																		@proceso,
																		@estado
GO
