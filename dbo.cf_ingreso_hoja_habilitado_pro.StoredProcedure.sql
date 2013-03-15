SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_ingreso_hoja_habilitado_pro]
@base varchar(50),
@tipo varchar(1),
@hab_fecha_rec smalldatetime,
@prendas_pri int,
@prendas_seg int,
@estado_paquete_hab varchar(1),
@personal varchar(10),
@fecha_act smalldatetime,
@usuario varchar(10),
@sin_confeccion int,
@corte integer,
@orden varchar(20),
@nro_paquete int
as
Declare @ncade as nvarchar(4000)
Declare @npara as nvarchar(4000)
Declare @nestado as varchar(1)
set @nestado='1'
if @tipo='0'
	begin
		set @ncade='INSERT INTO ['+@base+'].dbo.cf_hojadehabilitado
						(@hab_fecha_rec ,
						@prendas_pri ,
						@prendas_seg ,
						@estado_paquete_hab ,
						@personal ,
						@fecha_act ,
						@usuario ,
						@sin_confeccion ,
						@corte ,
						@orden ,
						@nro_paquete )
					 VALUES (
						@hab_fecha_rec,
						@prendas_pri,
						@prendas_seg,
						@estado_paquete_hab,
						@personal,
						@fecha_act,
						@usuario,
						@sin_confeccion,
						@corte,
						@orden,
						@nro_paquete)'
	end
if @tipo='1'
	begin
		set @ncade='UPDATE ['+@base+'].dbo.cf_hojadehabilitado 
					SET habiltadofecharecepcionacabado=@hab_fecha_rec ,
							detalleconfeccionprendasprimera=@prendas_pri ,
							detalleconfeccionprendassegunda=@prendas_seg ,
							habilitadoestadodelpqte= @estado_paquete_hab ,
							personalcodigo=@personal ,
							fechaact=@fecha_act ,
							usuariocodigo=@usuario ,
							detalleconfeccionprendasinconfeccion=@sin_confeccion
							WHERE cortenumero=@corte 
							AND ordennumero=@orden 
							AND habilitadonumerodepqte=@nro_paquete 
							AND habilitadoestadodelpqte=@nestado'
		end
SET @npara=N'@hab_fecha_rec smalldatetime,
							@prendas_pri int,
							@prendas_seg int,
							@estado_paquete_hab varchar(1),
							@personal varchar(10),
							@fecha_act smalldatetime,
							@usuario varchar(10),
							@sin_confeccion int,
							@corte integer,
							@orden varchar(20),
							@nro_paquete int,
							@nestado varchar(1)
							'
execute sp_executesql  @ncade,@npara,@hab_fecha_rec,@prendas_pri,@prendas_seg,@estado_paquete_hab,@personal,@fecha_act,@usuario,@sin_confeccion,@corte,@orden,@nro_paquete,@nestado
GO
