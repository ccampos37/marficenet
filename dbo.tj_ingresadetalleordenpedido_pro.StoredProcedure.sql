SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [tj_ingresadetalleordenpedido_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@producto varchar(20),
@titulo varchar(20),
@ancho varchar(20),
@densidad varchar(20),
@ordenkilo float,
@ordencolor varchar(20),
@color varchar(10),
@rendi float,
@hilo varchar(20),
@unimedida varchar(20),
@rollos float
as 
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
 		Begin
		  Set @ncade=N'DELETE FROM ['+@base+'].dbo.tj_detalleorden
									 WHERE tjordenum=@pedido and acodigo=@producto'
 		  Set @npara=N'@pedido integer,
									@producto varchar(20)'
		
 		  execute sp_executesql @ncade,@npara,@pedido,
																				 @producto
			Set @ncade=N'Insert into ['+@base+'].dbo.tj_detalleorden
    							 (tjordenum,
										acodigo,
										detordtitulo,
										detordancho,
										detorddensidad,
										detordkgs,
										detordcolor,
										detordcolorcodigo,
										detordrendim,
										detordhilocodigo,
										detsaldo,
										detunimedida,
										detrollos)
									 VALUES (
										@pedido,
										@producto,
										@titulo,
										@ancho,
										@densidad,
										@ordenkilo,
										@ordencolor,
										@color,
										@rendi,
										@hilo,
										@ordenkilo,
										@unimedida,
										@rollos)'
  End
 set @npara=N'@pedido integer,
							@producto varchar(20),
							@titulo varchar(20),
							@ancho varchar(20),
							@densidad varchar(20),
							@ordenkilo float,
							@ordencolor varchar(20),
							@color varchar(10),
							@rendi float,
							@hilo varchar(20),
							@unimedida varchar(20),
							@rollos float '
execute sp_executesql @ncade,@npara,@pedido,
																		@producto,
																		@titulo,
																		@ancho,
																		@densidad,
																		@ordenkilo,
																		@ordencolor,
																		@color,
																		@rendi,
																		@hilo,
																		@unimedida,
																		@rollos
GO
