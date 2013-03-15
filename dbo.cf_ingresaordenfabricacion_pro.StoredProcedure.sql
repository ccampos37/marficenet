SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_ingresaordenfabricacion_pro]
@base varchar(50),
@tipo varchar(1),
@orden varchar(20),
@tipotalla varchar(10),
@cantidadpqtes integer,
@servicio varchar(10),
@fentrega  smalldatetime,
@fingreso smalldatetime,
@modelo varchar(20),
@factorcorte varchar(20),
@factorconfe varchar(20),
@factoracaba varchar(20),
@pedido varchar(20),
@vendedor varchar(50),
@cliente varchar(50),
@detaprenda varchar(50),
@detatela varchar(50),
@detapeso varchar(20),
@temporada varchar(50)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0'
	Begin
		Set @ncade=N'INSERT INTO ['+@base+'].dbo.cf_cabeceraordendefabricacion
					(ordennumero,
					 tipotallascodigo,
					 ordencantidadpqtes,
					 servicioconfeccioncodigo,
					 serviciofechaentrega,
					 fechaingreso,
					 modelocodigo,
					 factorcorte,
					 factorconfeccion,
					 factoracabado,
					 ordenpedido,
					 vendedorcodigo,
					 clientecodigo,
					 ordendetalleprenda,
					 ordendetalletela,
					 ordendetallepeso,
					 ordendetalletemporada)
					VALUES(
					@orden,
					@tipotalla,
					@cantidadpqtes,
					@servicio,
					@fentrega,
					@fingreso,
					@modelo,
					@factorcorte,
					@factorconfe,
					@factoracaba,
					@pedido,
					@vendedor,
					@cliente,
					@detaprenda,
					@detatela,
					@detapeso,
					@temporada)'
	End
if @tipo='1'
	Begin
		Set @ncade=N'UPDATE ['+@base+'].dbo.cf_cabeceraordendefabricacion
					Set  tipotallascodigo=@tipotalla,
	  					 ordencantidadpqtes=@cantidadpqtes,
						 servicioconfeccioncodigo=@servicio,
						 serviciofechaentrega=@fentrega,
						 fechaingreso=@fingreso,
						 modelocodigo=@modelo,
						 factorcorte=@factorcorte,
						 factorconfeccion=@factorconfe,
						 factoracabado=@factoracaba,
						 ordenpedido=@pedido,
						 vendedorcodigo=@vendedor,
						 clientecodigo=@cliente,
						 ordendetalleprenda=@detaprenda,
						 ordendetalletela=@detatela,
						 ordendetallepeso=@detapeso,
						 ordendetalletemporada=@temporada
					WHERE ordennumero=@orden'
	End
set @npara=N'@orden varchar(20),
			@tipotalla varchar(10),
			@cantidadpqtes integer,
			@servicio varchar(10),
			@fentrega  smalldatetime,
			@fingreso smalldatetime,
			@modelo varchar(20),
			@factorcorte varchar(20),
			@factorconfe varchar(20),
			@factoracaba varchar(20),
			@pedido varchar(20),
			@vendedor varchar(50),
			@cliente varchar(50),
			@detaprenda varchar(50),
			@detatela varchar(50),
			@detapeso varchar(20),
			@temporada varchar(50)'
execute sp_executesql @ncade,@npara,@orden,
									@tipotalla,
									@cantidadpqtes,
									@servicio,
									@fentrega,
									@fingreso,
									@modelo,
									@factorcorte,
									@factorconfe,
									@factoracaba,
									@pedido,
									@vendedor,
									@cliente,
									@detaprenda,
									@detatela,
									@detapeso,
									@temporada
GO
