SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROC [cp_ingresacargo_pro]
@base varchar(50),
@tipo char(1),
@empresa varchar(2),
@tabla varchar(50)=Null,
@tipodocu char(2)=Null,
@numero  varchar(14)=Null,
@cliente  varchar(11)=Null,
@vendedor char(3)=Null,
@zona 	char(3)=Null,
@apefecemi datetime=Null,
@moneda	char(2)=Null,
@apeimppag float=0,
@usuario char(8)=Null,
@tipocambio float=0,
@fechaact datetime=Null,
@flagcancel bit=0,
@cargoabono char(1)=Null,
@concepto char(2)=Null, 
@abonotipoplanilla varchar(2)=Null,
@abononumplanilla varchar(6)=Null,
@glosa varchar(80)=null
As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
SET @Parame = N'@empresa varchar(2),
			@tipodocu char(2),
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
			@concepto char(2),
         @abonotipoplanilla varchar(2),
         @abononumplanilla varchar(6),
			@glosa varchar(80)'
if @tipo='1' 
   Begin
	SET @cadena =N'Insert Into ['+@base +'].dbo.'+@tabla +
        		  '(empresacodigo,
				documentocargo,
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
				conceptocodigo,abonotipoplanilla,abononumplanilla,cargoaperefere)
            VALUES (		@empresa,
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
           	@concepto,@abonotipoplanilla,@abononumplanilla,@glosa)'	
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
			   conceptocodigo=@concepto,  
            abonotipoplanilla=@abonotipoplanilla, 
            abononumplanilla=@abononumplanilla,
				cargoaperefere=@glosa
            Where empresacodigo=@empresa and clientecodigo=@cliente and  
                  documentocargo=@tipodocu and cargonumdoc=@numero'
				
end     
if @tipo='3' 
Begin
	SET @cadena =N'DELETE FROM  ['+@base +'].dbo.'+@tabla +
           		 ' Where  
                      empresacodigo=@empresa and clientecodigo=@cliente and 
                      documentocargo=@tipodocu and cargonumdoc=@numero'			
end     
	EXEC sp_executesql @cadena,@parame,@empresa,
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
				@concepto,@abonotipoplanilla,@abononumplanilla,@glosa
GO
