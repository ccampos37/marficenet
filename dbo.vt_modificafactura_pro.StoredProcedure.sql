SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       proc [vt_modificafactura_pro]
@base varchar(50),
@tipo char(1),
@tabla varchar(50),
@pedido varchar(15),
@tipodocu char(2),
@numero  varchar(15),
@cliente  char(11),
@ruc char(11),
@vendedor char(3),
@puntovta char(2),
@fecha datetime,
@condicion char(1),
@forma char(2),
@modo char(2),
@entrega datetime,
@hora as varchar(5),
@empresa as char(2),
@direntrega varchar(70),
@contacto varchar(200),
@almacen char(2)

As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
if @tipo='1'
  Begin
	        SET @cadena=N'UPDATE ['+@base +'].dbo.'+@tabla+'
                     SET pedidonrofact=@numero,
                         pedidofechafact=@fecha,
						 pedidofechasunat=@fecha,
						 pedidotipofac=@tipodocu,	
                         clientecodigo=@cliente,
                         clienteruc=@ruc,
                         vendedorcodigo=@vendedor,
                         puntovtacodigo=@puntovta,
                         pedidocondicionfactura=@condicion,
                         formapagocodigo=@forma,
                         modovtacodigo=@modo,
			 pedidofecha=@entrega,
			 horaentrega=@hora,
			 pedidoentrega=@direntrega,
             pedidomensaje=@contacto,
			 pedidoobserva=@contacto,
             almacencodigo=@almacen
                     WHERE pedidonumero=@pedido and empresacodigo=@empresa and puntovtacodigo=@puntovta'
		
		SET @Parame = N'@pedido char(15),
				@tipodocu char(2),
				@numero  varchar(15),
				@cliente  char(11),
				@ruc char(11),
				@vendedor char(3),
				@puntovta char(3),
				@fecha datetime,
				@condicion char(1),
				@forma char(2),
				@modo char(2),
				@entrega datetime,
				@hora varchar(5),
				@empresa char(2),
				@direntrega varchar(70),
                @contacto varchar(200),
                @almacen char(2)'
		
		EXEC sp_executesql @cadena,@parame,@pedido,
						@tipodocu,
						@numero,
						@cliente,
						@ruc,
						@vendedor,
						@puntovta,
						@fecha,
						@condicion,
						@forma,
						@modo,
						@entrega,
						@hora,
						@empresa,
						@direntrega,
						@contacto,
						@almacen
						
						
   end
if @tipo='2' 
   Begin
	SET @cadena=N'UPDATE ['+@base +'].dbo.'+@tabla+'
                     SET pedidonrofact=@numero,
                         pedidofechafact=@fecha,
			 pedidotipofac=@tipodocu,
                         clientecodigo=@cliente,
                         clienteruc=@ruc,
                         vendedorcodigo=@vendedor,
                         puntovtacodigo=@puntovta,
                         pedidocondicionfactura=@condicion
                         formapagocodigo=@forma,
                         modovtacodigo=@modo,
			 pedidofecha=@entrega,
			 pedidomensaje=@contacto,
			 pedidoobserva=@contacto,
			 almacencodigo=@almacen
                     WHERE pedidonumero=@pedido and empresacodigo=@empresa and puntovtacodigo=@puntovta'
		
	SET @Parame = N'@pedido varchar(15),
			@tipodocu char(2),
			@numero  varchar(15),
			@cliente  char(11),
			@ruc char(11),
			@vendedor char(3),
			@puntovta char(3),
			@fecha datetime,
			@condicion char(1),
			@forma char(2),
			@modo char(2),
			@entrega datetime,
			@empresa char(2),
			@contacto varchar(200),
			@almacen char(2) '
	
	
	EXEC sp_executesql @cadena,@parame,@pedido,
					@tipodocu,
					@numero,
					@cliente,
					@ruc,
					@vendedor,
					@puntovta,
					@fecha,
					@condicion,
					@forma,
					@modo,
					@entrega,
					@empresa,
					@contacto,
					@almacen
					
  End
if @tipo='3' 
   Begin
         if @tipodocu='PE'
               Begin
                    set @cadena=N'UPDATE ['+@base +'].dbo.'+@tabla+'
		                     SET pedidofecha=@fecha,
		                         clientecodigo=@cliente,
		                         clienteruc=@ruc,
			                 vendedorcodigo=@vendedor,
		                         pedidocondicionfactura=@condicion,
		                         formapagocodigo=@forma,
		                         modovtacodigo=@modo,
					 pedidofecha=@entrega,
					 horaentrega=@hora ,
					 pedidomensaje=@contacto,
					 pedidoobserva=@contacto,
                     almacencodigo=@almacen	
		                     WHERE pedidonumero=@pedido and empresacodigo=@empresa and puntovtacodigo=@puntovta'
		 END 
	SET @Parame = N'@pedido varchar(15),
			@tipodocu char(2),
			@numero  char(11),
			@cliente  varchar(15),
			@ruc char(11),
			@vendedor char(3),
			@puntovta char(3),
			@fecha datetime,
			@condicion char(1),
			@forma char(2),
			@modo char(2),
			@entrega datetime,			@hora varchar(5),
			@empresa char(2),
			@contacto varchar(200),
			@almacen char(2) '
	
	EXEC sp_executesql @cadena,@parame,@pedido,
					@tipodocu,
					@numero,
					@cliente,
					@ruc,
					@vendedor,
					@puntovta,
					@fecha,
					@condicion,
					@forma,
					@modo,
					@entrega,
					@hora,
					@empresa,
					@contacto,
					@almacen
	
End
GO
