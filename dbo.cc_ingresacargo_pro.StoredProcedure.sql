SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [cc_ingresacargo_pro]
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
@cargoabono char(1),
@concepto char(2)
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
				cargoapecarabo,
				conceptocodigo)
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
				@cargoabono,
				@concepto)'
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
			@cargoabono char(1),
			@concepto char(2)'
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
				@cargoabono,
				@concepto
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
			   cargoapecarabo=@cargoabono,
			   conceptocodigo=@concepto
                         Where  documentocargo=@tipodocu and cargonumdoc=@numero'
				
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
			@cargoabono char(1),
			@concepto char(2)'
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
						@cargoabono,
						@concepto
 end
GO
