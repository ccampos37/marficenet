SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_ingresadetalleordentela_pro]
@base varchar(50),
@tipo varchar(1),
@orden varchar(20),
@color varchar(10),
@tela varchar(20),
@telapedida float
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
		Set @ncade=N'Insert Into ['+@base+'].dbo.cf_detalleordentela
					 (codigotela,
					  ordennumero,
					  colorcodigo,
					  ordentelakgspedido)
					VALUES(
					  @tela,
					  @orden,
					  @color,
					  @telapedida)'			
	End
if @tipo='1' 
	Begin
		Set @ncade=N'Update ['+@base+'].dbo.cf_detalleordentela
					 Set ordentelakgspedido=@telapedida
					 Where codigotela=@tela and  ordennumero=@orden and
						   colorcodigo=@color'
	End
Set @npara=N'@orden varchar(20),
			 @color varchar(10),
			 @tela varchar(20),
			 @telapedida float'
execute sp_executesql @ncade,@npara,@orden,
									@color,
									@tela,
									@telapedida
GO
