SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [tj_ingresahiloxordendefabricacion_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@producto varchar(20),
@orden integer,
@correla integer,
@hilo varchar(20),
@proveedor varchar(20),
@lote varchar(20),
@kilos float,
@porce float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
		Set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_hiloxordendefabricacion
									 (tjordenum,
										acodigo,
										detorditem,
										detordcorrel,
										dethilocodigo,
										dethiloproveedor,
										dethilolote,
										dethilokgs,
										detporcen)
								VALUES (
										@pedido,
										@producto,
										@orden,
										@correla,
										@hilo,
										@proveedor,
										@lote,
										@kilos,
										@porce)'
	End
if @tipo='1'
	Begin
		Set @ncade=N'UPDATE ['+@base+'].dbo.tj_hiloxordendefabricacion
								 SET dethiloproveedor=@proveedor,
										 dethilolote=@lote,
										 dethilokgs=@kilos,
 										 detporcen=@porce	
								 WHERE tjordenum=@pedido and acodigo=@producto and
 										   detorditem=@orden and detordcorrel=@correla and
   										 dethilocodigo=@hilo'
	End
								
set @npara=N'@pedido integer,
							@producto varchar(20),
							@orden integer,
							@correla integer,
							@hilo varchar(20),
							@proveedor varchar(20),
							@lote varchar(20),
							@kilos float,
							@porce float'
execute sp_executesql @ncade,@npara,@pedido,
																		@producto,
																		@orden,
																		@correla,
																		@hilo,
																		@proveedor,
																		@lote,
																		@kilos,
																		@porce
GO
