SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create      procedure [xx_abonadocumento_pro]
@base varchar(50),
@tipo char(1),
@numrecibo varchar(6),
@estadoreg varchar(1),
@controlctacte char(1)=0,
@vendedorcodigo char(3)='000',
@cajacodigo char(2)='00',
@clientecodigo varchar(11)='00',
@descripcion varchar(50)='',
@operacion varchar(2)='',
@monedacodigo varchar(2)='',
@ingsal varchar(1)='',
@tipocambio float=0,
@totsoles float=0,
@totdolares float=0,
@fechadocumento datetime='01/01/2000',
@observa varchar(80)='',
@transferauto varchar(3)='',
@numreciboegreso varchar(7)='',
@usuario char(8)='',
@fechaact datetime='01/01/2000',
@empresa varchar(2)='',
@cabprovinumero int=0 ,
@nrotransferencia varchar(7)='',
@saldodocxrendir float=0,
@EstadoDocXRendir varchar(1)='0',
@NumeroDocXRendir varchar(6)=''
As
Declare @ncadena as nvarchar(4000)
Declare @parame  as nvarchar(4000)
if @tipo=1
  Begin 
	
   set @ncadena=N'INSERT INTO ['+@base+'].[dbo].[te_cabecerarecibos]
		( cabrec_numrecibo,cabrec_estadoreg,controlctacte,vendedorcodigo,
		  cajacodigo,clientecodigo,cabrec_descripcion,operacioncodigo,
		  monedacodigo,cabrec_ingsal,cabrec_tipocambio,cabrec_totsoles,
		  cabrec_totdolares,cabrec_fechadocumento,cabrec_observacion1,
		  cabrec_transferenciaautomatico,cabrec_numreciboegreso,usuariocodigo,
		  fechaact,empresacodigo,cabcomprobnumero,SaldoDocxRendir,
                           EstadoDocXRendir,NumeroDocXRendir)
		VALUES(
			@numrecibo,@estadoreg,
			@controlctacte,	@vendedorcodigo,
			@cajacodigo,@clientecodigo,
			@descripcion,@operacion,
			@monedacodigo,@ingsal,
			@tipocambio,@totsoles,
			@totdolares,@fechadocumento,
			@observa,@transferauto,
			@numreciboegreso,@usuario,
			@fechaact,@empresa ,
                        @cabprovinumero,@saldodocxrendir,@EstadoDocXRendir,@NumeroDocXRendir  )'
	set @parame=N'@numrecibo varchar(6),@estadoreg varchar(1),
			@controlctacte char(1),	@vendedorcodigo char(3),
			@cajacodigo char(2),@clientecodigo varchar(11),
			@descripcion varchar(50),@operacion varchar(2),
			@monedacodigo varchar(2),@ingsal varchar(1),
			@tipocambio float,@totsoles float,
			@totdolares float,@fechadocumento datetime,
			@observa varchar(80),@transferauto varchar(3),
			@numreciboegreso varchar(7),@usuario char(8),
			@fechaact datetime,@empresa char(2),
			@cabprovinumero int,@saldodocxrendir float,
                                          @EstadoDocXRendir varchar(1) ,
                                       @NumeroDocXRendir varchar(6)  '
	Exec sp_executesql @ncadena,@parame,@numrecibo,	@estadoreg,
					@controlctacte,	@vendedorcodigo,
					@cajacodigo,@clientecodigo,
					@descripcion,@operacion,
					@monedacodigo,@ingsal,
					@tipocambio,@totsoles,
					@totdolares,@fechadocumento,
					@observa,@transferauto,
					@numreciboegreso,@usuario,
					@fechaact,@empresa,
					@cabprovinumero,@saldodocxrendir ,
					@EstadoDocXRendir ,@NumeroDocXRendir
   end	
if @tipo=2
  Begin 
	
   set @ncadena=N'DELETE  ['+@base+'].[dbo].[te_cabecerarecibos]
       WHERE  cabrec_numrecibo='''+@numrecibo+''''
   execute(@ncadena) 
  End
--execute te_abonadocumento_pro 'invbrisa','2',207137,''
GO
