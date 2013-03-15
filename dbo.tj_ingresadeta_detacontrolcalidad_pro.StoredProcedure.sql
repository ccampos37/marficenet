SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [tj_ingresadeta_detacontrolcalidad_pro]
@base varchar(50),
@numero varchar(10),
@item integer,
@rollo varchar(10),
@defecto varchar(3),
@unidad varchar(3),
@canti float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_detalle_detallecontrolcalidad
							(	ControlCalidad,
								DeControlItem,
								detallerollo,
								defectocodigo,
								detalleunidad,
								detallecantidad)
							VALUES
								(	@numero,
									@item,
									@rollo,
									@defecto,
									@unidad,
									@canti)'
set @npara=N'@numero varchar(10),
							@item integer,
							@rollo varchar(10),
							@defecto varchar(3),
							@unidad varchar(3),
							@canti float'
execute sp_executesql @ncade,@npara,@numero,
																		@item,
																		@rollo,
																		@defecto,
																		@unidad,
																		@canti
GO
