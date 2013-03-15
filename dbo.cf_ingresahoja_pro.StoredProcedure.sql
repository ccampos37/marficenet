SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_ingresahoja_pro]
@base varchar(50),
@tipo varchar(1),
@corte integer,
@fecha smalldatetime,
@mesa integer,
@turno integer,
@ancho integer,
@largo float,
@tizador varchar(10),
@cortador varchar(10),
@retazos float,
@merma float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	begin
		set @ncade=N'UPDATE ['+@base+'].dbo.cf_parametros
					SET parametronumerodecorte=parametronumerodecorte+1'
		execute sp_executesql @ncade
		set @ncade='INSERT INTO ['+@base+'].dbo.cf_cabecerahojacorte
						(cortenumero,
						 cortefecha,
						 cortenumeromesa,
						 corteturno,
						 corteanchotela,
						 cortelongitudtendido,
						 cortecodigotizador,
						 cortecodigocortador,
						 cortekgsretazos,
						 cortekgsmerma)
					 VALUES (
						@corte,
						@fecha,
						@mesa,
						@turno,
						@ancho,
						@largo,
						@tizador,
						@cortador,
						@retazos,
						@merma)'
		
	end
if @tipo='1'
	begin
		set @ncade='UPDATE ['+@base+'].dbo.cf_cabecerahojacorte
					SET  cortefecha=@fecha,
						 cortenumeromesa=@mesa,
						 corteturno=@turno,
						 corteanchotela=@ancho,
						 cortelongitudtendido=@largo,
						 cortecodigotizador=@tizador,
						 cortecodigocortador=@cortador,
						 cortekgsretazos=@retazos,
						 cortekgsmerma=@merma	
					WHERE cortenumero=@corte'
			end
SET @npara=N'@corte integer,
  			 @fecha smalldatetime,
 			@mesa integer,
			@turno integer,
			@ancho integer,
			@largo float,
			@tizador varchar(10),
			@cortador varchar(10),
			@retazos float,
			@merma float'
execute sp_executesql  @ncade,@npara,@corte,
																		 @fecha,
																		 @mesa,
																		 @turno,
																		 @ancho,
																		 @largo,
																		 @tizador,
																		 @cortador,
																	   @retazos,
																		 @merma
GO
