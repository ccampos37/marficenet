SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_repobonificaciondiaria_pro]
@base varchar(50),
@orden varchar(20),
@fechaini varchar(10),
@fechafin varchar(10)
as
declare @ncade as nvarchar(3000)
declare @npara as nvarchar(3000)
declare @estado as varchar(1)
set @estado='2'
set @ncade=N'Select a.personalcodigo,
								ltrim(b.personalapellidopaterno)+'' ''+ltrim(b.personalapellidomaterno)+'' ''+ltrim(b.personalnombres) as personal,
								a.ordennumero,a.cortenumero,
								c.operacioncodigo,d.operaciondescripcion,
							  aprecio=1,sum(d.operaciontiempo) as tiempo
						from ['+@base+'].dbo.cf_secuenciaxpaqte a
								inner join ['+@base+'].dbo.cf_personal b
								on b.personalcodigo=a.personalcodigo
								inner join ['+@base+'].dbo.cf_secuenciaoperaciones c
								on c.secuenciacorrelativo=a.secuenciacorrelativo and c.ordennumero=a.ordennumero
								inner join ['+@base+'].dbo.cf_operaciones d
								on d.operacioncodigo=c.operacioncodigo
   					where a.ordennumero like @orden and a.secuenciaxpqtefecha>=@fechaini and 
					      a.secuenciaxpqtefecha<=@fechafin and secuenciaxpqteestado=@estado
		  			group by a.personalcodigo,b.personalapellidopaterno,
								 b.personalapellidomaterno,b.personalnombres,
							   a.ordennumero,a.cortenumero,c.operacioncodigo,
								 d.operaciondescripcion'
set @npara=N'@orden varchar(20),
						 @fechaini varchar(10),
						 @fechafin varchar(10),
						 @estado varchar(1)'
execute sp_executesql @ncade,@npara,@orden,
																		 @fechaini,
																		 @fechafin,
																		 @estado
GO
