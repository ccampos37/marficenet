SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [tj_ingresadetparteproduccion_pro]
@base varchar(50),
@tipo varchar(1),
@numeparte varchar(10),
@item int,
@turno int,
@rollo varchar(10),
@horaini varchar(10),
@horafin varchar(10),
@peso float,
@revorolloini float,
@revorollofin float,
@tejedor varchar(3),
@paraliza varchar(10),
@paraini varchar(10),
@parafin varchar(10),
@observa varchar(254),
@horamin float,
@revomin float
as 
Declare @ncade as nvarchar(4000)
Declare @npara as nvarchar(4000)
if @tipo='0'
	Begin
		set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_detparteproduccion
							(partenume,
							 detalleitem,
							 detalleturno,
							 detallerollo,
							 detallehoraini,
							 detallehorafin,
							 detallepeso,
							 detallerevorolloini,
							 detallerevorollofin,
							 codope,
							 paraid,
							 paraini,
							 parafin,
							 observacion,
							 detallehoraminuto,
							 detallerevominuto)
							VALUES (
								@numeparte,
								@item,
								@turno,
								@rollo,
								@horaini,
								@horafin,
								@peso,
								@revorolloini,
								@revorollofin,
								@tejedor,
								@paraliza,
								@paraini,
								@parafin,
								@observa,
								@horamin,
								@revomin)'
  End
if @tipo='1'
	Begin
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_detordendefabricacion
							 	SET detalleturno=@turno,
									 detallerollo=@rollo,
									 detallehoraini=@horaini,
									 detallehorafin=@horafin,
									 detallepeso=@peso,
									 detallerevorolloini=@revorolloini,
									 detallerevorollofin=@revorollofin,
									 codope=@tejedor,
									 paraid=@paraliza,
									 paraini=@paraini,
									 parafin=@parafin,
									 observacion=@observa,
									 detallehoraminuto=@horamin,
									 detallerevominuto=@revomin
								WHERE partenume=@numeparte and detalleitem=@item'
							
	End
set @npara=N'@numeparte varchar(10),
						@item int,
						@turno int,
						@rollo varchar(10),
						@horaini varchar(10),
						@horafin varchar(10),
						@peso float,
						@revorolloini float,
						@revorollofin float,
						@tejedor varchar(3),
						@paraliza varchar(10),
						@paraini varchar(10),
						@parafin varchar(10),
						@observa varchar(254),
						@horamin float,
						@revomin float'
execute sp_executesql @ncade,@npara,@numeparte,
																		@item,
																		@turno,
																		@rollo,
																		@horaini,
																		@horafin,
																		@peso,
																		@revorolloini,
																		@revorollofin,
																		@tejedor,
																		@paraliza,
																		@paraini,
																		@parafin,
																		@observa,
																		@horamin,
																		@revomin
GO
