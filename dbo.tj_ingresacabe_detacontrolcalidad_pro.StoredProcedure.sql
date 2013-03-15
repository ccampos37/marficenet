SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Procedure [tj_ingresacabe_detacontrolcalidad_pro]
@base varchar(50),
@numero varchar(10),
@item integer,
@rollo varchar(10),
@peso float,
@falla float,
@observa varchar(80)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_cabecera_detallecontrolcalidad
						(ControlCalidad,
						  DeControlItem,
							detallerollo,
						  detallepeso,
							detallefallas,
							detalleobservacion)
						VALUES
						(	@numero,
							@item,
							@rollo,
							@peso,
							@falla,
							@observa)'
set @npara=N'@numero varchar(10),
							@item integer,
							@rollo varchar(10),
							@peso float,
							@falla float,
							@observa varchar(80)'
execute sp_executesql @ncade,@npara,@numero,
																		@item,
																		@rollo,
																		@peso,
																		@falla,
																		@observa
GO
