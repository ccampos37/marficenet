SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [vt_actualizocarteractacte_pro]
@base varchar(50),
@tipo char(1),
@cliente varchar(8),
@codcia varchar(2),
@serie char(3),
@numerofac char(8),
@tipofac char(2),
@fecha datetime,
@fechavence datetime,
@rendi integer,
@importe  numeric(11,2),
@guia char(11),
@moneda char(2),
@opera integer
as
Declare @cadena nvarchar(4000)
Declare @parame nvarchar(4000)
Declare @ftipofac char(2)
Declare @fmoneda char(1)
Declare @fguia char(9)
Declare @fcliente numeric(8)
Declare @fserie numeric(3)
Declare @fnumerofac numeric(9)
Declare @ftipocli char(1)
Declare @debe varchar(12)
Declare @deta varchar(50)
declare @f char(1)
declare @x char(1)
declare @ib varchar(50)
declare @ich varchar(50)
declare @icuenta varchar(4)
declare @space char(1)
set @icuenta='2704'
set @ib='i_nombre_banco'
set @ich='i_num_cheque'
set @f='F'
set @x='F'
set @space=''
set @debe='CLS_DEB'+Right('00'+LTRIM(STR(MONTH(@FECHA))),2)
set @ftipocli='C'
set @fserie=cast(@serie as numeric(3))
set @fnumerofac=cast(@numerofac as numeric(9))
set @fcliente=cast(@cliente as numeric(8))
set @fguia=right(@guia,8)
If @tipofac='01' 
   begin
     set  @ftipofac='FA'
     set @deta='SALDO INICIAL DE '+@fTIPOFAC+' POR COBRAR'
   end
else
    begin
      if @tipofac='03'
         begin
           set @ftipofac='BO'
	   set @deta='SALDO INICIAL DE '+@fTIPOFAC+' POR COBRAR'
         end
       else
          begin
		if @tipofac='80'
		   begin	
		    set @ftipofac='80'
		    set @deta='SALDO INICIAL DE '+@fTIPOFAC+' POR COBRAR'	
   		   end
		else
		   begin	
		    set @ftipofac=@tipofac
		    set @deta='SALDO INICIAL DE '+@fTIPOFAC+' POR COBRAR'
		   end	
	   end
    end		
if @moneda='01'
   set @fmoneda='S'
if @moneda='02'
   set @fmoneda='D'
If @tipo='1'
   Begin
	Set @cadena=N'INSERT INTO ['+@base+'].dbo.CARTERA 
		     (CAR_CP,CAR_CODCLIE,CAR_CODCIA,CAR_SERDOC,CAR_NUMDOC,CAR_TIPDOC,CAR_IMPORTE,
		      CAR_FECHA_INGR,CAR_FECHA_VCTO,CAR_NUM_REN,CAR_CODART,CAR_IMP_INI,CAR_SITUACION,CAR_NUMSER,
		      CAR_NUMFAC,CAR_PRECIO,CAR_CONCEPTO,CAR_CODTRA,CAR_SIGNO_CAR,CAR_CODVEN,CAR_NUMGUIA,
                      CAR_FBG,CAR_NOMBRE_BANCO,CAR_NUM_CHEQUE,CAR_SIGNO_CAJA,CAR_TIPMOV,CAR_NUMSER_C,
		      CAR_NUMFAC_C,CAR_FECHA_VCTO_ORIG,CAR_COMISION,CAR_CODBAN,CAR_COBRADOR,CAR_MONEDA,CAR_FECHA_SUNAT,
                      CAR_PLACA,CAR_VOUCHER,CAR_SERGUIA,CAR_FLAG_SO,CAR_NUMOPER)
                     VALUES
                     (@ftipocli,@fcliente,@codcia,@fserie,@fnumerofac,@ftipofac,0,@fecha,@fechavence,@rendi,null,
		       @importe,0,0,0,0,@deta,@icuenta,
		       1,0,@fguia,@f,@ib,@ich,0,0,0,0,@fecha,
		       0,0,0,@fmoneda,@fecha,null,@space,0,@x,@opera)'
       set @parame=N'@fcliente numeric(8),@codcia char(2),@fserie numeric(3),@fnumerofac numeric(9),@ftipofac char(2),
		     @fecha datetime,@fechavence datetime,@rendi integer,@importe numeric(11,2),@fguia char(9),@fmoneda char(1),@opera integer,@ftipocli char(1),@deta varchar(50),
                     @f char(1),@x char(1),@ib varchar(50),@ich varchar(50),@icuenta varchar(4),@space char(1)'
       execute sp_executesql @cadena,@parame,@fcliente,@codcia,@fserie,@fnumerofac,@ftipofac,@fecha,@fechavence,@rendi,
                                             @importe,@fguia,@fmoneda,@opera,@ftipocli,@deta,@f,@x,@ib,@ich,@icuenta,@space
      -- Actualizamos saldos en clientes
      set @cadena=N'UPDATE ['+@base+'].dbo.clientes 
                   Set cli_saldo=cli_saldo+@importe,
                       cli_fecha_fac=@fecha
                   Where cli_codcia=@codcia and cli_codclie=@fcliente'
    
      set @parame=N'@fcliente numeric(8),@codcia char(2),@fecha datetime,@importe numeric(11,2)'
      execute sp_executesql @cadena,@parame,@fcliente,@codcia,@fecha,@importe
      -- Actualizamos Saldos de Clientes en Clisal
      set @cadena=N'UPDATE ['+@base+'].dbo.clisal
                   Set '+@debe+'='+@debe+'+@importe
                   Where cls_codcia=@codcia and cls_codclie=@fcliente'
    
      set @parame=N'@fcliente numeric(8),@codcia char(2),@importe numeric(11,2)'
      execute sp_executesql @cadena,@parame,@fcliente,@codcia,@importe
   
   End 
If @tipo='2'
  Begin
	Set @cadena=N'UPDATE ['+@base+'].dbo.CARTERA 
		    SET CAR_CP=@ftipocli,
			CAR_CODCLIE=@fcliente,
			CAR_CODCIA=@codcia,
			CAR_SERDOC=@fserie,
			CAR_NUMDOC=@fnumerofac,  
			CAR_TIPDOC=@ftipofac,    --FA/BO
			CAR_IMPORTE=0,
			CAR_FECHA_INGR=@fecha,
			CAR_FECHA_VCTO=@fechavence,
			CAR_NUM_REN=@rendi,
			CAR_CODART=null,
			CAR_IMP_INI=@importe,
			CAR_SITUACION=0,
			CAR_NUMSER=0,
			CAR_NUMFAC=0,
			CAR_PRECIO=0,
			CAR_CONCEPTO=@deta,
			CAR_CODTRA=@icuenta,
			CAR_SIGNO_CAR=1,
			CAR_CODVEN =0,
			CAR_NUMGUIA =0,
			CAR_FBG =@f,
			CAR_NOMBRE_BANCO=@ib,
			CAR_NUM_CHEQUE=@ich,
			CAR_SIGNO_CAJA=0, 
			CAR_TIPMOV =0,
			CAR_NUMSER_C=0,
			CAR_NUMFAC_C=0,
			CAR_FECHA_VCTO_ORIG=@fecha,
			CAR_COMISION=0,
			CAR_CODBAN=0, 
			CAR_COBRADOR=0,
			CAR_MONEDA=@fmoneda,
			CAR_FECHA_SUNAT=@fecha,
			CAR_PLACA=null,
			CAR_VOUCHER=@space,
			CAR_SERGUIA=0,
			CAR_FLAG_SO=@x,
			CAR_NUMOPER= @opera
	             WHERE  CAR_CP=@ftipocli AND  CAR_CODCLIE=@fcliente AND CAR_CODCIA=@codcia AND CAR_SERDOC=@fserie AND CAR_NUMDOC=@fnumerofac and  
			CAR_TIPDOC=@ftipofac'
       set @parame=N'@fcliente numeric(8),@codcia char(2),@fserie numeric(3),@fnumerofac numeric(9),@ftipofac char(2),
		     @fecha datetime,@fechavence datetime,@rendi integer,@importe numeric(11,2),@fguia char(9),@fmoneda char(1),@opera integer,@ftipocli char(1),@deta varchar(50),
                     @f char(1),@x char(1),@ib varchar(50),@ich varchar(50),@icuenta varchar(4),@space char(1)'
       execute sp_executesql @cadena,@parame,@fcliente,@codcia,@fserie,@fnumerofac,@ftipofac,@fecha,@fechavence,@rendi,
                                             @importe,@fguia,@fmoneda,@opera,@ftipocli,@deta,@f,@x,@ib,@ich,@icuenta,@space
      -- Actualizamos saldos en clientes
      set @cadena=N'UPDATE ['+@base+'].dbo.clientes 
                   Set cli_saldo=cli_saldo-@importe,
                       cli_fecha_fac=@fecha
                   Where cli_codcia=@codcia and cli_codclie=@fcliente'
    
      set @parame=N'@fcliente numeric(8),@codcia char(2),@fecha datetime,@importe numeric(11,2)'
      execute sp_executesql @cadena,@parame,@fcliente,@codcia,@fecha,@importe
      -- Actualizamos Saldos de Clientes en Clisal
      set @cadena=N'UPDATE ['+@base+'].dbo.clisal
                   Set '+@debe+'='+@debe+'-@importe
                   Where cls_codcia=@codcia and cls_codclie=@fcliente'
    
      set @parame=N'@fcliente numeric(8),@codcia char(2),@importe numeric(11,2)'
      execute sp_executesql @cadena,@parame,@fcliente,@codcia,@importe
	
  End
GO
