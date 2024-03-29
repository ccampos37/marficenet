SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER             PROC [vt_ingresoalma_pro]
@base varchar(50),
@tipo char(1),
@tabla varchar(50),
@puntovta char(2),
@numero char(11),
@factura varchar(15),
@boleta char(2),
@guia varchar(15),
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
@notaped varchar(15),
@ordencompra varchar(60),
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
@TDPromo float,
@casitgui char(1)='V',
@cacodmov char(2)='50',
@empresa char(2)='01'
As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
Declare @GS as varchar(2)
Declare @ntipo as varchar(1)
--Declare @Codmov varchar(2)
--Exec('Declare CuentaReg Cursor for 
--Select Codigo=codigotransaccionventas From ['+@base +'].dbo.vt_parametroventa')
--Open CuentaReg
--Fetch Next from codigo into @Codmov
---Close CuentaReg
--Deallocate CuentaReg
set @ntipo='S'
if @tipo='1' 
   begin  
     SET @GS='GS'
   end
if @tipo='2'	
   begin  
     SET @GS='NS'
   end
if @tipo='3'
   begin  
     SET @GS='NI'
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
				CARFNDOC,casitgui,cacodmov,empresacodigo
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
				@fechaactual,
				@entregapedido,
				@razon,
				@ruc,
				@boleta,
				@factura,@casitgui,@cacodmov, @empresa )'
SET @Parame = N'@tipo char(2),@puntovta char(2),@numero char(11),@factura varchar(15),@boleta char(2),
	@guia varchar(11),@dsctoglobal float,@dsctoppago float,@dsctovtaofi float,	@moneda char(2),
	@tipocambio float,@listaprecio char(2),@mensaje varchar(45),@modoventa char(2),
	@fecha datetime,@formapago char(2),@cliente char(11),@vendedor char(3),	@porcomision float,
	@almacen char(2),@totalotros float,@notaped varchar(15),@ordencompra varchar(60),
	@autoriza char(1),@diaspago float,@totalitem float,@totalbruto float,@totalflete float,
	@totalimpuesto float,@totalneto float,@usuario char(8),@fechaactual datetime,
	@totaldsctoxlinea float,@montodsctoppago float,@entregapedido char(70),@razon char(60),
	@direccion char(80),@ruc char(11),@fechafactura datetime,@TDGlobal float,@TDCliente float,
	@TDOficina float,@TDItem float,@TDPromo float,
	@GS varchar(2),@ntipo varchar(1),@casitgui char(1),@cacodmov char(2), @empresa char(2) '
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
					@casitgui,
					@cacodmov,
					@empresa

