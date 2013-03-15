SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [tj_ingresacabeceraordendefabricacion_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@producto varchar(20),
@orden integer,
@titulo varchar(20),
@mezcla varchar(20),
@ancho varchar(20),
@densidad varchar(20),
@diametro varchar(20),
@galga float,
@acabado varchar(20),
@acabatela varchar(20),
@kilos float,
@fecha varchar(10),
@fecharec varchar(10),
@fechaentre varchar(10),
@ordtipo varchar(1),
@corre integer
as
Declare @ncade as nvarchar(3000)
Declare @npara as nvarchar(3000)
if @tipo='0' 
	Begin
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_parametros
								SET ParametroHojaFabri=@orden'
		set @npara=N'@orden integer'
    EXECUTE sp_executesql @ncade,@npara,@orden
		set @ncade=N'INSERT INTO ['+@base+'].dbo. tj_cabeceraordendefabricacion
								 (tjordenum,
									acodigo,
									detorditem,
									cabordtitulo,
									cabordmezcla,
									cabordancho,
									caborddensidad,
									caborddiametro,
									cabordgalga,
									cabordacabado,
									cabordacabadotela,
								  cabordkgs,fecha,fecharec,fechaentre,cabordtipo,detorditem2)
								VALUES (
									@pedido,
									@producto,
									@orden,
									@titulo,
									@mezcla,
									@ancho,
									@densidad,
									@diametro,
									@galga,
									@acabado,
									@acabatela,
									@kilos,
									@fecha,
									@fecharec,
									@fechaentre,
									@ordtipo,
									@corre)'
	End									
if @tipo='1'
	 Begin
		set @ncade=N'UPDATE ['+@base+'].dbo. tj_cabeceraordendefabricacion
								 SET cabordtitulo=@titulo,
									cabordmezcla=@mezcla,
									cabordancho=@ancho,
									caborddensidad=@densidad,
									caborddiametro=@diametro,
									cabordgalga=@galga,
									cabordacabado=@acabado,
									cabordacabadotela=@acabatela,
								  cabordkgs=@kilos,
									fecha=@fecha,
									fecharec=@fecharec,
									fechaentre=@fechaentre,
									cabordtipo=@ordtipo,
									detorditem2=@corre
								WHERE  tjordenum=@pedido and acodigo=@producto and detorditem=@orden'
	End									
Set @npara=N'@pedido integer,
							@producto varchar(20),
							@orden integer,
							@titulo varchar(20),
							@mezcla varchar(20),
							@ancho varchar(20),
							@densidad varchar(20),
							@diametro varchar(20),
							@galga float,
							@acabado varchar(20),
							@acabatela varchar(20),
							@kilos float,
							@fecha varchar(10),
							@fecharec varchar(10),
							@fechaentre varchar(10),
							@ordtipo varchar(1),
							@corre integer'
execute sp_executesql @ncade,@npara,@pedido,
																		@producto,
																		@orden,
																		@titulo,
																		@mezcla,
																		@ancho,
																		@densidad,
																		@diametro,
																		@galga,
																		@acabado,
																		@acabatela,
																		@kilos,
																		@fecha,
																		@fecharec,
																		@fechaentre,
																		@ordtipo,
																		@corre
GO
