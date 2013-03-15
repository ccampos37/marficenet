SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [cf_consistenciadelecturadeoperaciones_rep]
@base varchar(50),
@fini varchar(10),
@ffin varchar(10),
@lectura varchar(1),
@personal varchar(20),
@operacion varchar(20)
as 
Declare @ncade as nvarchar(3000)
Declare @npara as nvarchar(3000)
set @ncade=N'Select 
							corte=cortenumero,
							paquete=habilitadonumerodepqte,
						  orden=a.ordennumero,
						  correlativo=a.secuenciacorrelativo,
						  fecha=secuenciafechalectura,
							personal=a.personalcodigo,
							detalle=ltrim(personalapellidopaterno)+'' ''+ltrim(personalapellidomaterno)+'' ''+ltrim(personalnombres),
						  operacion=c.operacioncodigo,
							descripcion=operaciondescripcion,
							bloques=e.bloquescodigo,
							Detallebloque=bloquesdescripcion,
							Proceso=f.procesoscodigo,
						  DetaProceso=procesosconfeccion 
						from ['+@base+'].dbo.cf_secuenciaxpaqte a
						inner join ['+@base+'].dbo.cf_personal b
						on a.personalcodigo=b.personalcodigo
						inner join ['+@base+'].dbo.cf_secuenciaoperaciones c
						on c.ordennumero=a.ordennumero and c.secuenciacorrelativo=a.secuenciacorrelativo
						inner join ['+@base+'].dbo.cf_operaciones d
						on c.operacioncodigo=d.operacioncodigo
						inner join ['+@base+'].dbo.cf_bloquesdeconfeccion e
						on d.bloquescodigo=e.bloquescodigo
						inner join ['+@base+'].dbo.cf_procesosdeconfeccion f
						on e.procesoscodigo=f.procesoscodigo
						where not a.personalcodigo is null
						and secuenciafechalectura>=@fini and secuenciafechalectura<=@ffin
						and secuencialectura like @lectura and c.operacioncodigo like @operacion
						and a.personalcodigo like @personal'
set @npara=N'@fini varchar(10),
						@ffin varchar(10),
						@lectura varchar(1),
						@personal varchar(20),
						@operacion varchar(20)'
execute sp_executesql @ncade,@npara,@fini,
																		@ffin,
																		@lectura,
																		@personal,
																		@operacion
GO
