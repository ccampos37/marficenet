SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_ingresadetallecortetela_pro]
@base varchar(50),
@tipo varchar(1),
@corte integer,
@orden varchar(20),
@tela varchar(20),
@color varchar(20),
@kilos float,
@fecha smalldatetime,
@usuario varchar(10)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
Declare @ndato as varchar(1)
set @ndato='1'
if @tipo='0'
	begin
		set @ncade='DELETE FROM ['+@base+'].[dbo].cf_detallehojacortetela
		 			WHERE cortenumero=@corte and 
						  ordennumero=@orden and
						  codigotela=@tela and
						  colorcodigo=@color'
		SET @npara=N'@corte integer,
					@orden varchar(20),
					@tela varchar(20),
					@color varchar(20),
					@kilos float,
					@fecha smalldatetime,
					@usuario varchar(10)'
		execute sp_executesql  @ncade,@npara,@corte,
											@orden,
											@tela,
											@color,
											@kilos,
											@fecha,
											@usuario
		set @ncade='INSERT INTO ['+@base+'].dbo.cf_detallehojacortetela
					(ordennumero,
					 codigotela,
					 cortenumero,
					 colorcodigo,
					 detallecortekgs,
					 fechaact,
					 usuario,
					 detallecortecodigotela)
					 VALUES (
						@orden,
						@tela,
						@corte,
						@color,
						@kilos,
						@fecha,
						@usuario,
						@ndato)'
	end
if @tipo='1'
	begin
		set @ncade='UPDATE ['+@base+'].[dbo].cf_detallehojacortetela
					SET   detallecortekgs=@kilos,
						 fechaact=@fecha,
						 usuario=@usuario
		 			WHERE cortenumero=@corte and 
						  ordennumero=@orden and
						  codigotela=@tela and
						  colorcodigo=@color'
	end
SET @npara=N'@corte integer,
			@orden varchar(20),
			@tela varchar(20),
			@color varchar(20),
			@kilos float,
			@fecha smalldatetime,
			@usuario varchar(10),@ndato varchar(1)'
execute sp_executesql  @ncade,@npara,@corte,
									@orden,
									@tela,
									@color,
									@kilos,
									@fecha,
									@usuario,
									@ndato
GO
