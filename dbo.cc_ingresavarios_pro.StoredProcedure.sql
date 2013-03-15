SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   PROC [cc_ingresavarios_pro]
@base varchar(50),
@tipo char(1),
@tabla varchar(50),
@tipodocu char(2),
@numero  varchar(14),
@cliente  varchar(11),
@vendedor char(3),
@zona 	char(3),
@apefecemi datetime,
@moneda	char(2),
@apeimppag float,
@usuario char(8),
@tipocambio float,
@fechaact datetime,
@flagcancel bit,
@tipoplanilla char(2),
@planilla char(6),
@vencimiento datetime,
@fechaplani datetime,
@banco char(2),
@cargoabono char(1),
@cargonumbco varchar(11)='' ,
@empresa char(2)='01'
As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
if @tipo='1' 
   Begin
	SET @cadena =N'Insert Into ['+@base +'].dbo.'+@tabla +
           		      '(documentocargo,
				cargonumdoc,
				clientecodigo,
				vendedorcodigo,
				zonacodigo,
				cargoapefecemi,
				monedacodigo,
				usuariocodigo,
				cargoapetipcam,
				fechaact,
				cargoapeflgcan,
	 		        cargoapeimpape,
				abonotipoplanilla,
				abononumplanilla,
				cargoapefecvct,
				cargoapefecpla,
				bancocodigo,
				cargoapecarabo,
				cargoapenrorefe,
				empresacodigo)
                          VALUES (
				@tipodocu, 
				@numero,
				@cliente,
				@vendedor,
				@zona,
				@apefecemi,
				@moneda,
				@usuario,
				@tipocambio,
				@fechaact,
				@flagcancel,
				@apeimppag,
				@tipoplanilla,
				@planilla,
				@vencimiento,
				@fechaplani,
				@banco,
				@cargoabono,
				@cargonumbco,
				@empresa)'
	SET @Parame = N'@tipodocu char(2),
			@numero  varchar(14),
			@cliente  varchar(11),
			@vendedor char(3),
			@zona 	char(3),
			@apefecemi datetime,
			@moneda	char(2),
			@apeimppag float,
			@usuario	char(8),
			@tipocambio	float,
			@fechaact	datetime,
			@flagcancel   bit,
			@tipoplanilla char(2),
			@planilla char(6),
			@vencimiento datetime,
			@fechaplani datetime,
			@banco char(2),
			@cargoabono char(1),
			@cargonumbco varchar(11),
			@empresa char(2) '
	EXEC sp_executesql @cadena,@parame,
				@tipodocu, 
				@numero,
				@cliente,
				@vendedor,
				@zona,
				@apefecemi,
				@moneda,
				@apeimppag,
				@usuario,
				@tipocambio,
				@fechaact,
				@flagcancel,
				@tipoplanilla,
				@planilla,
				@vencimiento,
				@fechaplani,
				@banco,
				@cargoabono,
				@cargonumbco,
				@empresa
	end 
if @tipo='2' 
  Begin
	SET @cadena =N'UPDATE ['+@base +'].dbo.'+@tabla +
           		 ' SET 
			   clientecodigo=@cliente,
			   vendedorcodigo=@vendedor,
			   zonacodigo=@zona,
			   cargoapefecemi=@apefecemi,
			   monedacodigo=@moneda,
			   cargoapeimpape=@apeimppag,
			   usuariocodigo=@usuario,
			   cargoapetipcam=@tipocambio,
			   fechaact=@fechaact,
		           cargoapeflgcan=@flagcancel,
			   abonotipoplanilla=@tipoplanilla,
			   abononumplanilla=@planilla,
			   cargoapefecvct=@vencimiento,
			   cargoapefecpla=@fechaplani,
			   bancocodigo=@banco,
			   cargoapecarabo=@cargoabono		
                         Where  empresacodigo=@empresa and documentocargo=@tipodocu and cargonumdoc=@numero'
				
	SET @Parame = N'@tipodocu char(2),
			@numero  varchar(14),
			@cliente  varchar(11),
			@vendedor char(3),
			@zona 	char(3),
			@apefecemi datetime,
			@moneda	char(2),
			@apeimppag float,
			@usuario char(8),
			@tipocambio float,
			@fechaact  datetime,
                        @flagcancel  bit,
			@tipoplanilla char(2),
			@planilla char(6),
			@vencimiento datetime,
			@fechaplani datetime,
			@banco char(2),
			@cargoabono char(1),
			@cargonumbco varchar(11),
			@empresa char(2)'
	EXEC sp_executesql @cadena,@parame,@tipodocu, 
						@numero,
						@cliente,
						@vendedor,
						@zona,
						@apefecemi,
						@moneda,
						@apeimppag,
						@usuario,
						@tipocambio,
						@fechaact,
						@flagcancel,
						@tipoplanilla,
						@planilla,
						@vencimiento,
						@fechaplani,
						@banco,
						@cargoabono,
						@cargonumbco,
						@empresa
 end
GO
