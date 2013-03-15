SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [tj_ingresaordenpedido_pro]
@base varchar(50),
@tipo varchar(1),
@pedido integer,
@fechadoc varchar(10),
@fechaentrega varchar(10),
@fechacomprometida varchar(10),
@fecharecepcion varchar(10),
@numedocrec varchar(2),
@numerec varchar(10),
@compra varchar(10),
@cliente varchar(10),
@correpedido varchar(10),
@empresa varchar(2),
@servicio varchar(10),
@referencia varchar(10),
@observa varchar(100)
as 
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
if @tipo='0' 
	Begin
  	set @ncade=N'UPDATE ['+@base+'].dbo.tj_parametros
								SET ParametroPedido=@pedido'
  		set @npara=N'@pedido integer'
      EXECUTE sp_executesql @ncade,@npara,@pedido
			Set @ncade=N'Insert into ['+@base+'].dbo.tj_cabeceraorden
    							 (tjordenum,
										cabordfecdoc,
										cabordfecentrega,
										cabordfeccomprometida,
										cabordfecrecepcion,		
										caborddocrecep,
										cabordnrorecep,
										cabord_oc_ref,
										clientecodigo,
										cabpedcorrel,
										tipoempre,
										cabordservicio,
										cabordreferencia,
										observacion)
									 VALUES (
										@pedido,
										@fechadoc,
										@fechaentrega,
										@fechacomprometida,
										@fecharecepcion,
										@numedocrec,
										@numerec,
										@compra,
										@cliente,
										@correpedido,
										@empresa,
										@servicio,
										@referencia,
										@observa)'
  End
if @tipo='1'
 		Begin
			Set @ncade=N'UPDATE ['+@base+'].dbo.tj_cabeceraorden
										SET 
										cabordfecdoc=@fechadoc,
										cabordfecentrega=@fechaentrega,
										cabordfeccomprometida=@fechacomprometida,
										cabordfecrecepcion=@fecharecepcion,
										caborddocrecep=@numedocrec,
										cabordnrorecep=@numerec,
										cabord_oc_ref=@compra,
										clientecodigo=@cliente,
										cabpedcorrel=@correpedido,
										tipoempre=@empresa,
										cabordservicio=@servicio,
										cabordreferencia=@referencia,
										observacion=@observa
							WHERE tjordenum=@pedido'
  End
set @npara=N'@pedido integer,
						@fechadoc varchar(10),
						@fechaentrega varchar(10),
						@fechacomprometida varchar(10),
						@fecharecepcion varchar(10),
						@numedocrec varchar(2),
						@numerec varchar(10),
						@compra varchar(10),
						@cliente varchar(10),
						@correpedido varchar(10),
						@empresa varchar(2),
						@servicio varchar(10),
						@referencia varchar(10),
						@observa varchar(100)'
execute sp_executesql @ncade,@npara,@pedido,
																		@fechadoc,
																		@fechaentrega,
																		@fechacomprometida,
																		@fecharecepcion,
																		@numedocrec,	
																		@numerec,
																		@compra,
																		@cliente,
																		@correpedido,
																		@empresa,
																		@servicio,
																		@referencia,
																		@observa
GO
