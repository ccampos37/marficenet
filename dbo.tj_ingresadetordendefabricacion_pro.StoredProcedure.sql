SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [tj_ingresadetordendefabricacion_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@producto varchar(20),
@orden integer,
@correla integer,
@kilos float,
@kilorollos float,
@rollos float,
@lm float
as 
Declare @ncade as nvarchar(4000)
Declare @npara as nvarchar(4000)
if @tipo='0'
	Begin
		set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_detordendefabricacion
							(tjordenum,
							detordcorrel,
							acodigo,
							detorditem,
							detordkgs,
							detordkgsxrollo,
							detordrollo,
							detordlm)
							VALUES (
								@pedido,
								@correla,
								@producto,
								@orden,
								@kilos,
								@kilorollos,
								@rollos,
								@lm)'
  End
if @tipo='1'
	Begin
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_detordendefabricacion
							 	SET detordkgs=@kilos,
										detordrollo=@rollos,
		 							  detordkgsxrollo=@kilorollos,
										detordlm=@lm
								WHERE tjordenum=@pedido and acodigo=@producto and 
											detorditem=@orden and detordcorrel=@correla'
							
	End
set @npara=N'@pedido integer,
						@correla integer,
						@producto varchar(20),
						@orden integer,
						@kilos float,
						@kilorollos float,
						@rollos float,
						@lm float'
execute sp_executesql @ncade,@npara,@pedido,
																		@correla,
																		@producto,
																		@orden,
																		@kilos,
																		@kilorollos,																		@rollos,
																		@rollos,
																		@lm
GO
