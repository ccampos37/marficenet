SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [cf_XX_ingreso_hoja_habilitado_aconfeccion_pro]
@base varchar(50),
@canti float,
@fecha smalldatetime,
@linea varchar(10),
@estado varchar(1),
@fechareg smalldatetime,
@usuario varchar(10),
@corte integer,
@orden varchar(20),
@color varchar(10),
@talla varchar(10),
@nro_paquete int
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
--Grabamos en hoja de habilitado
Set @ncade='UPDATE ['+@base+'].dbo.cf_hojadehabilitado 
							SET habilitadocantidaddeprendasxpqte=@canti,
								  lineadeconfeccioncodigo=@linea,
								  habilitadoestadodelpqte=@estado,
									habilitadofechaaconfeccion=@fecha,
								  fechaact=@fechareg,
								  usuariocodigo=@usuario
							WHERE cortenumero=@corte 
									AND ordennumero=@orden 
									AND habilitadonumerodepqte=@nro_paquete  '
SET @npara=N'@canti float,
						 @fecha smalldatetime,
						 @linea varchar(10),
						 @estado varchar(1),
						 @fechareg smalldatetime,
						 @usuario varchar(10),
						 @corte integer,
						 @orden varchar(20),
						 @color varchar(10),
						 @talla varchar(10),
						 @nro_paquete int '
execute sp_executesql  @ncade,@npara,@canti,
																		 @fecha,
																		 @linea,
																		 @estado,
																		 @fechareg,
																		 @usuario,
																		 @corte,
																		 @orden,
                 								 @color,
																		 @talla,
																		 @nro_paquete
--Grabamos en detalleordendefabricacion
Set @ncade='UPDATE ['+@base+'].dbo.cf_detalleordendefabricacion 
							SET ordencanthabilitado=ordencanthabilitado+@canti,
									ordentothabilitado=ordentothabilitado+@canti,
							WHERE ordennumero=@orden 
									AND colorcodigo=@color
									AND tallascodigo=@talla '
SET @npara=N'@canti float,
						 @orden varchar(20),
						 @color varchar(10),
						 @talla varchar(10)'
execute sp_executesql  @ncade,@npara,@canti,
																		 @orden,
																		 @color,
																		 @talla
GO
