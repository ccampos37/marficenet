SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_ingresadetallecortetalla_pro]
@base varchar(50),
@tipo varchar(1),
@corte integer,
@orden varchar(20),
@color varchar(20),
@talla varchar(10),
@molde integer,
@prenda integer
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	begin
		set @ncade='DELETE FROM ['+@base+'].dbo.cf_detallehojacortetallas
		 			WHERE cortenumero=@corte and 
						  ordennumero=@orden and
						  colorcodigo=@color and
						  tallascodigo=@talla'
		SET @npara=N'@corte integer,
					@orden varchar(20),
					@color varchar(20),
					@talla varchar(10),
					@molde integer,
					@prenda integer'
		execute sp_executesql  @ncade,@npara,@corte,
											@orden,
											@color,
											@talla,
											@molde,
											@prenda
		set @ncade='INSERT INTO ['+@base+'].dbo.cf_detallehojacortetallas
					(cortenumero,
					 ordennumero,
					 colorcodigo,
					 tallascodigo,
					 tallanumeromoldes,
					 tallasnumeroprendas)
					 VALUES (
						@corte,
						@orden,
						@color,
						@talla,
						@molde,
						@prenda)'
	end
if @tipo='1'
	begin
		set @ncade='UPDATE ['+@base+'].dbo.cf_detallehojacortetallas
					SET  tallanumeromoldes=@molde,
						 tallasnumeroprendas=@prenda
		 			WHERE cortenumero=@corte and 
						  ordennumero=@orden and
						  colorcodigo=@color and
						  tallascodigo=@talla'
	end
SET @npara=N'@corte integer,
			@orden varchar(20),
			@color varchar(20),
			@talla varchar(10),
			@molde integer,
			@prenda integer'
execute sp_executesql  @ncade,@npara,@corte,
									@orden,
									@color,
									@talla,
									@molde,
									@prenda
GO
