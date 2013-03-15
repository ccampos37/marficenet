SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[empresacodigo]=id_empresa 
	[pedidonumero]=id_comprobante
	[modovtacodigo]='01'
	[formapagocodigo] ='01'
	[vendedorcodigo] ='001'
	[pedidomoneda] ='01' 
	[pedidofecha] =fecha_emision
	[puntovtacodigo]='001'
	[pedidoestado] = ' '
	[pedidolistaprec] ='1'
	[pedidoautorizacion]=' ' [nvarchar] (1) COLLATE Modern_Spanish_CI_AS NULL ,
	[clienteruc] [nvarchar]=ruc_cliente
	[clientecodigo] =ruc_cliente
	[clienterazonsocial] nombre_cliente
	[clientedireccion]direccion_cliente
	[pedidomensaje] =''
	[clientedistrito]
	[pedidotipcambio]=funcion del tipo de cambio
	[pedidotarjetacred]
	[pedidoemisionfact]=1
	[pedidonrofact]=serie_comprobante+numero_comprobante
	[pedidonroboleta] 
	[pedidonrogiarem] =serie_guia+numero_guia
	[pedidoordencompra] 
	[pedidocondicionfactura] 
	[pedidodiaspago] =0
	[pedidototbruto]= valor_venta
	[pedidototalotros]=0
	[pedidototalflete]=0
	[pedidomontodsctoglobal]=0 [float] NULL ,
	[pedidomontodsctocliente]=0
	[pedidomontodsctoppago] 
	[pedidomontodsctovtaoficina]
	[pedidototaldsctoxitem] 
	[pedidototaldsctoxlinea] 
	[pedidodsctoglobal]
	[pedidototaldsctoxprom]
	[pedidodsctocliente] 
	[pedidodsctoppago] 
	[pedidodsctovtaoficina] 
	[pedidototimpuesto]=importe_igv
	[pedidototinafecto]=
	[pedidototneto] =total_pagar
	[pedidototitem] =pedidototitem
	[pedidofechafact] =fecha_emision
	[almacencodigo] 
	[pedidofechapag] fecha_emision
	[pedidonotaped] 
	[pedidoporccomision] =0
	[pedidoentrega] 
	[pedidofechaanu] 
	[estadoreg] =0 
	[usuariocodigo]=emisor
	[fechaact] =getdate()
	[pedidotipofac] ='01' 
	[pedidotiporefe] 
	[pedidonrorefe] 
	[pedidofechasunat]=fecha_emision
	[pedidoobserva] 
	[transportecodigo] 

execute vt_ingresapedido_pro_triggers 'planta_casma','1','vt_pedido',id_empresa,id_empresa,fecha_emision,ruc_cliente,
        ruc_cliente,nombre_cliente,direccion_cliente,serie_comprobante+numero_comprobante,
        serie_guia+numero_guia,valor_venta, valor_venta,importe_igv,total_pagar,pedidototitem,emisor,getdate()

*/
CREATE PROC [vt_ingresapedido_pro_triggers]

@empresa varchar(2),
@fecha datetime,
@fechafactura datetime,
@cliente varchar(11),
@ruc varchar(11),
@razon char(60),
@direccion char(80),
@factura char(11),
@guia char(11),
@totalbruto float,
@totalimpuesto float,
@totalneto float,
@totalitem float,
@usuario char(8),
@fechaactual datetime,
@base varchar(50)='planta_casma',
@tipo char(1)='1',
@tabla varchar(50)='vt_pedido',
@puntovta char(2)='001',
@numero char(11)='',
@boleta char(2)='',
@dsctoglobal float=0,
@dsctoppago float=0,
@dsctovtaofi float=0,
@moneda char(2)='01',
@tipocambio float=1,
@listaprecio char(2)='01',
@mensaje varchar(45)='',
@modoventa char(2)='01',
@formapago char(2)='01',
@vendedor char(3)='001',
@porcomision float=0,
@almacen char(2)='',
@totalotros float=0,
@notaped char(11)='',
@ordencompra char(11)='',
@autoriza char(1)=0,
@diaspago float=0,
@totalflete float=0,
@totaldsctoxlinea float=0,
@montodsctoppago float=0,
@entregapedido char(70)='',
@TDGlobal float=0,
@TDCliente float=0,
@TDOficina float=0,
@TDItem float=0,
@TDPromo float=0,
@observa varchar(100)='',
@tiporefe varchar(2)='',
@nrorefe varchar(11)='',
@nrotransporte varchar(11)='00'

As

Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
if @tipo='1' 
   Begin
	SET @cadena =N'Insert Into ['+@base +'].dbo.'+@tabla +
           		   '(puntovtacodigo,
		            pedidonumero,
		            pedidonrofact,
		            pedidotipofac,
		            pedidonrogiarem,
		            pedidodsctoglobal,
		            pedidodsctoppago,
		            pedidodsctovtaoficina,
		            pedidomoneda,
		            pedidotipcambio,
		            pedidolistaprec,
		            pedidomensaje,
		            modovtacodigo,
		            pedidofecha,
		            formapagocodigo,
		            clientecodigo,
		            vendedorcodigo,
		            pedidoporccomision,
		            almacencodigo,
		            pedidototalotros,
		            pedidonotaped,
		            pedidoordencompra,
		            pedidoautorizacion,
		            pedidodiaspago,
		            pedidototitem,
		            pedidototbruto,
		            pedidototalflete,
		            pedidototimpuesto,
		            pedidototneto,
		            usuariocodigo,
		            fechaact,
		            pedidototaldsctoxlinea,
		            pedidomontodsctoppago,
			    pedidoentrega,
			    clienterazonsocial,
			    clientedireccion,
			    clienteruc,
		            pedidofechafact,
			    pedidofechasunat,
			    pedidomontodsctoglobal,
			    pedidomontodsctocliente,
			    pedidomontodsctovtaoficina,			
   			    pedidototaldsctoxitem,				
			    pedidototaldsctoxprom,
			    pedidocondicionfactura,
			    pedidoobserva,
			    pedidotiporefe,
			    pedidonrorefe,
			    transportecodigo,
			    empresacodigo)
                          VALUES (
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
				@fechafactura,
				@TDGlobal,
				@TDCliente,
				@TDOficina,
				@TDItem,
				@TDPromo,
				0,
				@observa,
				@tiporefe,
				@nrorefe,
				@nrotransporte,
				@empresa )'
	SET @Parame = N'@tipo char(2),@puntovta char(2),@numero char(11),@factura char(11),@boleta char(2),
			@guia char(11),@dsctoglobal float,@dsctoppago float,@dsctovtaofi float,	@moneda char(2),
			@tipocambio float,@listaprecio char(2),@mensaje varchar(45),@modoventa char(2),
			@fecha datetime,@formapago char(2),@cliente varchar(11),@vendedor char(3),	@porcomision float,
			@almacen char(2),@totalotros float,@notaped char(11),@ordencompra char(11),
			@autoriza char(1),@diaspago float,@totalitem float,@totalbruto float,@totalflete float,
			@totalimpuesto float,@totalneto float,@usuario char(8),@fechaactual datetime,
			@totaldsctoxlinea float,@montodsctoppago float,@entregapedido char(70),@razon char(60),
			@direccion char(80),@ruc varchar(11),@fechafactura datetime,@TDGlobal float,@TDCliente float,
			@TDOficina float,@TDItem float,@TDPromo float,@observa varchar(100),@tiporefe varchar(2),
			@nrorefe varchar(11),@nrotransporte varchar(11),@empresa varchar(2)'
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
					@observa,
					@tiporefe,
					@nrorefe,
					@nrotransporte,
					@empresa
					
	end 
if @tipo=2 
  Begin
	SET @cadena =N'UPDATE ['+@base +'].dbo.'+@tabla +
           		 ' SET puntovtacodigo=@puntovta,
		            pedidonrofact=@factura,
		            pedidotipofac=@boleta,
		            pedidonrogiarem=@guia,
		            pedidodsctoglobal=@dsctoglobal,
		            pedidodsctoppago=@dsctoppago,
		            pedidodsctovtaoficina=@dsctovtaofi,
		            pedidomoneda=@moneda,
		            pedidotipcambio=@tipocambio,
		            pedidolistaprec=@listaprecio,
		            pedidomensaje=@mensaje,
		            modovtacodigo=@modoventa,
		            pedidofecha=@fecha,
		            formapagocodigo=@formapago,
		            clientecodigo=@cliente,
		            vendedorcodigo=@vendedor,
		            pedidoporccomision=@porcomision,
		            almacencodigo=@almacen,
		            pedidototalotros=@totalotros,
		            pedidonotaped=@notaped,
		            pedidoordencompra=@ordencompra,
		            pedidoautorizacion=@autoriza,
		            pedidodiaspago=@diaspago,
		            pedidototitem=@totalitem,
		            pedidototbruto=@totalbruto,
		            pedidototalflete=@totalflete,
		            pedidototimpuesto=@totalimpuesto,
		            pedidototneto=@totalneto,
		            usuariocodigo=@usuario,
		            fechaact=@fechaactual,
		            pedidototaldsctoxlinea=@totaldsctoxlinea,
		            pedidomontodsctoppago=@montodsctoppago,
   			    pedidoentrega=@entregapedido,
			    clienterazonsocial=@razon,
			    clientedireccion=@direccion,
			    clienteruc=@ruc, 
                            pedidofechafact=@fechafactura,
			    pedidomontodsctoglobal=@TDGlobal,
			    pedidomontodsctocliente=@TDCliente,
			    pedidomontodsctovtaoficina=@TDOficina,		
   			    pedidototaldsctoxitem=@TDItem,
			    pedidototaldsctoxprom=@TDPromo,
			    pedidocondicionfactura=0,
				pedidoobserva=@observa,
				pedidotiporefe=@tiporefe,
				pedidonrorefe=@nrorefe,
			    transportecodigo=@nrotransporte,
			    empresacodigo=@empresa
         Where  pedidonumero=@numero'
				
	SET @Parame = N'@tipo char(2),@puntovta char(2),@numero char(11),@factura char(11),@boleta char(2),
			@guia char(11),@dsctoglobal float,@dsctoppago float,@dsctovtaofi float,	@moneda char(2),
			@tipocambio float,@listaprecio char(2),@mensaje varchar(45),@modoventa char(2),
			@fecha datetime,@formapago char(2),@cliente varchar(11),@vendedor char(3),	@porcomision float,
			@almacen char(2),@totalotros float,@notaped char(11),@ordencompra char(11),
			@autoriza char(1),@diaspago float,@totalitem float,@totalbruto float,@totalflete float,
			@totalimpuesto float,@totalneto float,@usuario char(8),@fechaactual datetime,
			@totaldsctoxlinea float,@montodsctoppago float,@entregapedido char(70),@razon char(60),
			@direccion char(80),@ruc varchar(11),@fechafactura datetime,@TDGlobal float,@TDCliente float,
			@TDOficina float,@TDItem float,@TDPromo float,@observa varchar(100),@tiporefe varchar(2),
			@nrorefe varchar(11),@nrotransporte varchar(11),@empresa varchar(2)'
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
					@observa,
					@tiporefe,
					@nrorefe,
					@nrotransporte,
					@empresa
 end
GO
