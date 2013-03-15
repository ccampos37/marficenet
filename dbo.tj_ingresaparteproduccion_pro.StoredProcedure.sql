SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [tj_ingresaparteproduccion_pro]
@base varchar(50),
@tipo varchar(1),
@numeparte varchar(10),
@fecha varchar(10),
@pedido int,
@orden float,
@produ varchar(20),
@maquina varchar(20),
@rpm float
as
declare @ncade as nvarchar(3000)
declare @npara as nvarchar(3000)
IF @tipo='0'
	BEGIN
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_parametros
								 Set parametroparte=@numeparte'
		set @npara=N'@numeparte varchar(10)'
		
		execute sp_executesql @ncade,@npara,@numeparte
		set @ncade=N'INSERT INTO ['+@base+'].dbo.tj_parteproduccion
											(partenume,
											partefecha,
											tjordenum,
											detorditem,
											acodigo,
 									  	cod_mq,
											parterpm)
							  VALUES (
											@numeparte,
											@fecha,
											@pedido,
											@orden,
											@produ,
											@maquina,
											@rpm)'
		
	END
if @tipo='1'
	BEGIN
		set @ncade=N'UPDATE ['+@base+'].dbo.tj_parteproduccion
									set cod_mq=@maquina,
											parterpm=@rpm
								 WHERE 	partenume=@numeparte' 
	END
set @npara=N'@numeparte varchar(10),
							@fecha varchar(10),
							@pedido int,
							@orden float,
							@produ varchar(20),
							@maquina varchar(20),
							@rpm float'
execute sp_executesql @ncade,@npara,@numeparte,
				@fecha,
				@pedido,
				@orden,
				@produ,
				@maquina,
				@rpm
GO
