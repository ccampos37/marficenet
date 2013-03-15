SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_ingresapllanillapersonal_pro]
@base varchar(50),
@tipo varchar(1),
@orden varchar(20),
@corte varchar(10),
@secuencia integer,
@paquete integer,
@personal varchar(10),
@fecha datetime,
@numelectu integer
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
			set @ncade=N'UPDATE ['+@base+'].dbo.cf_secuenciaxpaqte
									 SET secuenciafechalectura=@fecha,
											personalcodigo=@personal,
											secuencialectura=@numelectu
									 WHERE ordennumero=@orden and cortenumero=@corte and 
												 secuenciacorrelativo=@secuencia and 
												 habilitadonumerodepqte=@paquete'
  End
Set  @npara=N'@orden varchar(20),
							@corte varchar(10),
							@secuencia integer,
							@paquete integer,
							@personal varchar(10),
							@fecha datetime,
							@numelectu integer'
execute sp_executesql @ncade,@npara,@orden,
																		@corte,
																		@secuencia,
																		@paquete,
																		@personal,
																		@fecha,
																		@numelectu
GO
