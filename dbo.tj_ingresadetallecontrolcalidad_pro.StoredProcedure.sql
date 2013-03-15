SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [tj_ingresadetallecontrolcalidad_pro]
@base varchar(50),
@numero varchar(10),
@item integer,
@parte integer,
@pedido integer,
@maquina varchar(13),
@produ varchar(20),
@detalle varchar(50),
@operario varchar(3)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_detallecontrolcalidad
									(ControlCalidad,
									 DeControlItem,
									 ParteNume,
									 tjordenum,
									 cod_mq,
									 acodigo,
									 des_produ,
									 CodOpe)
						  VALUES
									(
										@numero,
										@item,
										@parte,
										@pedido,
										@maquina,
										@produ,
										@detalle,
										@operario
									)'
set @npara=N'@numero varchar(10),
							@item integer,
							@parte integer,
							@pedido integer,
							@maquina varchar(13),
							@produ varchar(20),
							@detalle varchar(50),
							@operario varchar(3)'
execute sp_executesql @ncade,@npara,@numero,
																		@item,
																		@parte,
																		@pedido,
																		@maquina,
																		@produ,
																		@detalle,
																		@operario
GO
