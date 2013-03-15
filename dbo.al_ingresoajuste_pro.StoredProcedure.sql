SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  PROC [al_ingresoajuste_pro]
@base varchar(50),
@tipo char(1),
@tabla varchar(50),
@puntovta char(2),
@numero char(11),
@factura char(11),
@boleta char(2),
@guia char(11),
@dsctoglobal float,
@dsctoppago float,
@dsctovtaofi float,
@moneda char(2),
@tipocambio float,
@listaprecio char(2),
@mensaje varchar(45),
@modoventa char(2),
@fecha datetime,
@formapago char(2),
@cliente char(11),
@vendedor char(3),
@porcomision float,
@almacen char(2),
@totalotros float,
@notaped char(11),
@ordencompra char(11),
@autoriza char(1),
@diaspago float,
@totalitem float,
@totalbruto float,
@totalflete float,
@totalimpuesto float,
@totalneto float,
@usuario char(8),
@fechaactual datetime,
@totaldsctoxlinea float,
@montodsctoppago float,
@entregapedido char(70),
@razon char(60),
@direccion char(80),
@ruc char(11),
@fechafactura datetime,
@TDGlobal float,
@TDCliente float,
@TDOficina float,
@TDItem float,
@TDPromo float
As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
Declare @GS as varchar(2)
Declare @ntipo as varchar(1)
DECLARE @MOVI AS VARCHAR(2)
set @ntipo='S'
if @tipo='1' 
   begin  
     SET @GS='GS'
     
   end
if @tipo='2'	
   begin  
     SET @GS='NS'
     SET @MOVI='70'
   end
if @tipo='3'
   begin  
     SET @GS='NI'
     SET @MOVI='20'
     set @ntipo='I'
   end
	SET @cadena =N'Insert Into ['+@base +'].dbo.'+@tabla +
           		   '(CATD,
				CATIPMOV,
				CAFECDOC,
				CANUMDOC,
				CACODMON,
				CATIPCAM,
				CAFORVEN,
				CACODCLI,
				CAVENDE,
				CAALMA,
				CANROPED,
				CACOTIZA,
				CAIMPORTE,
				CAUSUARI,
				CAFECACT,
				CADIRENV,
				CANOMCLI,
				CARUC,
				CARFTDOC,
				CARFNDOC,
				CACODMOV
				)
                          VALUES (
				@GS,
				@ntipo,
				@fecha,
				@numero,
				@moneda,
				@tipocambio,
				@formapago,
				@cliente,
				@vendedor,
				@almacen,
				@notaped,
				@ordencompra,
				@totalneto,
				@usuario,
				@fecha,
				@entregapedido,
				@razon,
				@ruc,
				@boleta,
				@factura,
				@MOVI)'
	SET @Parame = N'@tipo char(2),@puntovta char(2),@numero char(11),@factura char(11),@boleta char(2),
			@guia char(11),@dsctoglobal float,@dsctoppago float,@dsctovtaofi float,	@moneda char(2),
			@tipocambio float,@listaprecio char(2),@mensaje varchar(45),@modoventa char(2),
			@fecha datetime,@formapago char(2),@cliente char(11),@vendedor char(3),	@porcomision float,
			@almacen char(2),@totalotros float,@notaped char(11),@ordencompra char(11),
			@autoriza char(1),@diaspago float,@totalitem float,@totalbruto float,@totalflete float,
			@totalimpuesto float,@totalneto float,@usuario char(8),@fechaactual datetime,
			@totaldsctoxlinea float,@montodsctoppago float,@entregapedido char(70),@razon char(60),
			@direccion char(80),@ruc char(11),@fechafactura datetime,@TDGlobal float,@TDCliente float,
			@TDOficina float,@TDItem float,@TDPromo float,@GS varchar(2),@ntipo varchar(1),@MOVI AS VARCHAR(2)'
	EXEC sp_executesql @cadena,@parame,@tipo,
					@puntovta,
					@numero,
					@factura,
					@boleta,
					@guia,
					@dsctoglobal,
					@dsctoppago,
					@dsctovtaofi,
					@moneda,
					@tipocambio,
					@listaprecio,
					@mensaje,
					@modoventa,
					@fecha,
					@formapago,
					@cliente,
					@vendedor,
					@porcomision,
					@almacen,
					@totalotros,
					@notaped,
					@ordencompra,
					@autoriza,
					@diaspago,
					@totalitem,
					@totalbruto,
					@totalflete,
					@totalimpuesto,
					@totalneto,
					@usuario,
					@fechaactual,
					@totaldsctoxlinea,
					@montodsctoppago,
					@entregapedido,
					@razon,
					@direccion,
					@ruc,
					@fechafactura,
					@TDGlobal,
					@TDCliente,
					@TDOficina,
					@TDItem,
					@TDPromo,
					@gs,
					@ntipo,
					@MOVI
GO
