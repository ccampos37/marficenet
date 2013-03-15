SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [cf_ingresadetalleordenfabrica_pro]
@base varchar(50),
@tipo varchar(1),
@orden varchar(20),
@color varchar(10),
@talla varchar(10),
@canti float,
@fecha smalldatetime,
@usuario varchar(10),
@totalconfe float,
@totalacaba float,
@totalcorte float,
@distribucion float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
		Set @ncade=N'Insert Into ['+@base+'].dbo.cf_detalleordendefabricacion
						(ordennumero,
						 colorcodigo,
						 tallascodigo,
						 ordencanpedida,
						 fechaact,
						 usuario,
						 ordentotconfeccion,
						 ordentotacabado,
						 ordentotcorte,
						 ordendistribucionprendas)
					Values(
  						@orden,
						@color,
						@talla,
						@canti,
						@fecha,
						@usuario,
						@totalconfe,
						@totalacaba,
						@totalcorte,
						@distribucion)'
	End
if @tipo='1'
	Begin
		Set @ncade=N'Update ['+@base+'].dbo.cf_detalleordendefabricacion
					 Set ordencanpedida=@canti,
						 fechaact=@fecha,
						 usuario=@usuario,
						 ordentotconfeccion=@totalconfe,
						 ordentothabilitado=@totalacaba,
						 ordentotcorte=@totalcorte,
						 ordendistribucionprendas=@distribucion 
					 Where ordennumero=@orden and  colorcodigo=@color and tallascodigo=@talla'
	End
set @npara=N'@orden varchar(20),
			@color varchar(10),
			@talla varchar(10),
			@canti float,
			@fecha smalldatetime,
			@usuario varchar(10),
			@totalconfe float,
			@totalacaba float,
			@totalcorte float,
			@distribucion float'
execute sp_executesql @ncade,@npara,@orden,
									@color,
									@talla,
									@canti,
									@fecha,
									@usuario,
									@totalconfe,
									@totalacaba,
									@totalcorte,
									@distribucion
GO
