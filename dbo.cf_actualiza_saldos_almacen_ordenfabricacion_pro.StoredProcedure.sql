SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SP_HELPTEXT cf_actualizasaldosordenfabricacion_pro
CREATE   procedure [cf_actualiza_saldos_almacen_ordenfabricacion_pro]
@base varchar(50),
@tipo varchar(1),
@orden varchar(20),
@color varchar(20),
@talla varchar(10),
@cantidad1 float,
@cantidad2 float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
If @tipo='1' 
	Begin
		Set @ncade=N'Update ['+@base+'].dbo.cf_detalleordendefabricacion
					Set ordencantacabado=ordencantacabado+@cantidad1,
					      ordencantacabadosegunda=ordencantacabadosegunda+@cantidad2,
							ordencantdiaacabado=ordencantdiaacabado+(@cantidad1),
							ordencantmesacabado=ordencantmesacabado+(@cantidad1),
							ordencantdiaacabadosegunda=ordencantdiaacabadosegunda+(@cantidad2),
							ordencantmesacabadosegunda=ordencantmesacabadosegunda+(@cantidad2)
					 Where ordennumero=@orden and colorcodigo=@color and 
						   tallascodigo=@talla'
	End
If @tipo='0'
	Begin
		Set @ncade=N'Update ['+@base+'].dbo.cf_detalleordendefabricacion
					Set ordencantacabado=ordencantacabado-@cantidad1,
					      ordencantacabadosegunda=ordencantacabadosegunda-@cantidad2,
							ordencantdiaacabado=ordencantdiaacabado-(@cantidad1),
							ordencantmesacabado=ordencantmesacabado-(@cantidad1),
							ordencantdiaacabadosegunda=ordencantdiaacabadosegunda-(@cantidad2),
							ordencantmesacabadosegunda=ordencantmesacabadosegunda-(@cantidad2)
					 Where ordennumero=@orden and colorcodigo=@color and 
						   tallascodigo=@talla'
	End
Set @npara=N'@orden varchar(20),
							@color varchar(20),
							@talla varchar(10),
							@cantidad1 float,
							@cantidad2 float'
	
execute sp_executesql @ncade,@npara,@orden,@color,@talla,@cantidad1,@cantidad2
GO
