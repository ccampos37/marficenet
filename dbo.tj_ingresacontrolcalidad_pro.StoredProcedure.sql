SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [tj_ingresacontrolcalidad_pro]
@base varchar(50),
@tipo varchar(1),
@numero varchar(10),
@fecha varchar(10),
@turno integer,
@revisor varchar(20),
@estado varchar(1)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
			set @ncade=N'UPDATE ['+@base+'].dbo.tj_parametros
								SET Parametrocontrol=@numero'
  		set @npara=N'@numero varchar(10)'
      EXECUTE sp_executesql @ncade,@npara,@numero
		set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_controlcalidad
								(ControlCodigo,
								 ControlFecha,
								 ControlTurno,
								 ControlRevisado,
								 ControlEstado)
								VALUES
								(
									@numero,
									@fecha,
									@turno,
									@revisor,
									@estado
								)'
		End
if @tipo='1'
	Begin
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_controlcalidad
								 Set ControlFecha=@fecha,
	 									 ControlTurno=@turno,
										 ControlRevisado=@revisor,
										 ControlEstado=@estado
								 Where controlCodigo=@numero'
		End
set @npara=N'@numero varchar(10),
							@fecha varchar(10),
							@turno integer,
							@revisor varchar(20),
							@estado varchar(1)'
 
execute sp_executesql @ncade,@npara,@numero,
																		@fecha,
																		@turno,
																		@revisor,
																		@estado
GO
