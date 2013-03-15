SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*

execute co_TRIGGERS_ingresacargo_pro 'planta_casma','cp_cargo','3','cp_cargo',' ','001351',
*/


---drop  PROC co_TRIGGERS_ingresacargo_pro
CREATE    PROC [co_TRIGGERS_ingresacargo_pro]
@base varchar(50),
@tipo char(1),
@tipodocu char(2),
@numero  char(11),
@cliente  char(11),
@apefecemi datetime,
@moneda	char(2),
@apeimpape float,
@tipocambio float,
@glosa varchar(80),
@cargoapefecvct datetime,
@empresacodigo varchar(2),
@abononumplanilla varchar(6),
@usuario char(8),
@fechaact datetime,

@concepto char(2)=Null, 
@flagcancel bit=0,
@apeimppag float=0,
@cargoabono char(1)=Null,
@tabla varchar(50)='cp_cargo',
@vendedor char(3)='003',
@zona 	char(3)=Null,
@abonotipoplanilla varchar(2)='CO',
@cargoapetiporefe varchar(2)=Null,
@cargoapenrorefe varchar(11)=Null,
@oldtipodocu char(2)=Null,
@oldnumero  char(11)=Null,
@oldcliente  char(11)=Null,
@cargoemiteretencion varchar(1)='0',
@cargoemitedetraccion varchar(1)='0'

As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
SET @Parame = N'@tipodocu char(2),
			@numero  char(11),
			@cliente  char(11),
			@vendedor char(3),
			@zona 	char(3),
			@apefecemi datetime,
			@moneda	char(2),
			@apeimpape float,
			@usuario	char(8),
			@tipocambio	float,
			@fechaact	datetime,
			@flagcancel   bit,
			@cargoabono char(1),
			@concepto char(2),
 	                       @abonotipoplanilla varchar(2),
             		           @abononumplanilla varchar(6),
			@glosa varchar(80),
			@cargoapetiporefe varchar(2),
			@cargoapenrorefe varchar(11),
			@cargoapefecvct datetime,
			@oldtipodocu char(2),
			@oldnumero  char(11),
			@oldcliente  char(11),
			@cargoemiteretencion char(1),
			@cargoemitedetraccion char(1), 
			@empresacodigo varchar(2) '
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
				conceptocodigo,
				abonotipoplanilla,
				abononumplanilla,
				cargoaperefere,
				cargoapetiporefe,
				cargoapenrorefe,
				cargoapefecvct,
				cargoemiteretencion,
				cargoemitedetraccion,
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
				@apeimpape,
				@cargoabono,
           				@concepto,
				@abonotipoplanilla,
				@abononumplanilla,@glosa,
				@cargoapetiporefe,@cargoapenrorefe,
				@cargoapefecvct,
				@cargoemiteretencion,
				@cargoemitedetraccion, 
				@empresacodigo )'	
	end 
if @tipo='2' 
  Begin
	SET @cadena =N'UPDATE ['+@base +'].dbo.'+@tabla +
           		 ' SET 
			   clientecodigo=@cliente,
				documentocargo=@tipodocu,
				cargonumdoc=@numero,
			   vendedorcodigo=@vendedor,
			   zonacodigo=@zona,
			   cargoapefecemi=@apefecemi,
			   monedacodigo=@moneda,
			   cargoapeimpape=@apeimpape,
			   usuariocodigo=@usuario,
			   cargoapetipcam=@tipocambio,
			   fechaact=@fechaact,
		           cargoapeflgcan=@flagcancel,
			   cargoapecarabo=@cargoabono,
			   conceptocodigo=@concepto,  
       			   abonotipoplanilla=@abonotipoplanilla, 
        		   abononumplanilla=@abononumplanilla,
			   cargoaperefere=@glosa,
			   cargoapetiporefe=@cargoapetiporefe,
			   cargoapenrorefe=@cargoapenrorefe,
			   cargoapefecvct=@cargoapefecvct,
			   cargoemiteretencion = @cargoemiteretencion,
			   cargoemitedetraccion = @cargoemitedetraccion,
                           empresacodigo= @empresacodigo
            Where 	clientecodigo=@oldcliente and  
                  	documentocargo=@oldtipodocu and 
			cargonumdoc=@oldnumero'
				
end     
if @tipo='3' 
Begin
	SET @cadena =N'DELETE FROM  ['+@base +'].dbo.'+@tabla +
           		 ' Where  abonotipoplanilla='''+@abonotipoplanilla+''' and
                           abononumplanilla='''+@abononumplanilla+''' '		
end     
EXEC sp_executesql @cadena,@parame,
				@tipodocu, 
				@numero,
				@cliente,
				@vendedor,
				@zona,
				@apefecemi,
				@moneda,
				@apeimpape,
				@usuario,
				@tipocambio,
				@fechaact,
				@flagcancel,
				@cargoabono,
				@concepto,
				@abonotipoplanilla,
				@abononumplanilla,
				@glosa,
				@cargoapetiporefe,
				@cargoapenrorefe,
				@cargoapefecvct,
				@oldtipodocu,
				@oldnumero,
				@oldcliente,
				@cargoemiteretencion,
				@cargoemitedetraccion,
				@empresacodigo
GO
