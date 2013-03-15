SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [vt_actualizofacart_pro]
@base VARCHAR(50),
@tipo VARCHAR(1),
@codcia VARCHAR(2),
@serie VARCHAR(3),
@factura VARCHAR(5),
@secuencia INTEGER,
@fecha DATETIME,
@numeope INTEGER,
@cliente VARCHAR(8),
@articulo VARCHAR(20),
@dias INTEGER,
@precio float,
@stock float,
@totaligv float,
@totalimporte float,
@totalneto float,
@cantidad float,
@serieped VARCHAR(3),
@pedido VARCHAR(5),
@usuario VARCHAR(8),
@moneda VARCHAR(2),
@serieguia VARCHAR(3),
@tipofac VARCHAR(2),
@nopera2 INTEGER
AS
DECLARE @cadena nVARCHAR(4000)
DECLARE @parame nVARCHAR(4000)
DECLARE @fmoneda VARCHAR(1)
DECLARE @ftipofac VARCHAR(1)
DECLARE @ftipodocu VARCHAR(2)
Declare @n VARCHAR(1)
Declare @f VARCHAR(1)
Declare @c VARCHAR(1)
Declare @x VARCHAR(1)
Declare @kilo VARCHAR(3)
Declare @space VARCHAR(1)
Declare @valor VARCHAR(2)
Declare @hora  VARCHAR(8)
set @kilo='Kg.'
set @space=''
set @valor='10'
set @x='X'
set @n='N'
set @f='F'
set @c='C'
set @hora=CONVERT(VARCHAR(8),GETDATE(),108)
if @moneda='01'
   set @fmoneda='S'
if @moneda='02'
   set @fmoneda='D'
if @tipofac='01'
   Begin   
     set @ftipodocu='FA'
     set @ftipofac='1'
   End
if @tipofac='03'
  Begin     
     set @ftipodocu='BO'
     set @ftipofac='3'
  End
If @tipo='1'
  Begin
    Set @cadena=N'INSERT INTO ['+@base+'].dbo.FACART
                  (FAR_TIPMOV,FAR_CODCIA,FAR_NUMSER,FAR_FBG,FAR_NUMFAC,FAR_NUMSEC,FAR_FECHA,
		   FAR_NUMOPER,FAR_CODCLIE,FAR_CODART,FAR_TRANSITO,FAR_ESTADO,FAR_NUMGUIA,FAR_DIAS,
		   FAR_SIGNO_ARM,FAR_PRECIO,FAR_STOCK,FAR_COSPRO,FAR_IMPTO,
		   FAR_TOT_DESCTO,FAR_DESCTO,FAR_GASTOS,FAR_BRUTO,FAR_EQUIV,FAR_PORDESCTO1,FAR_TIPO_CAMBIO,
		   FAR_OTRA_CIA,FAR_NUMSER_C,FAR_NUMFAC_C,FAR_NUMDOC,FAR_CP,FAR_SUBTOTAL,FAR_CONSIG,
  		   FAR_PRECIO_NETO,FAR_CODVEN,FAR_UNIDADES,FAR_ESTADO2,FAR_NUM_LOTE,FAR_CANTIDAD,
		   FAR_CONCEPTO,FAR_COD_SUNAT,FAR_FLETE,FAR_JABAS,FAR_DESCRI,FAR_PESO,FAR_TOT_FLETE,
		   FAR_EX_IGV,FAR_SIGNO_CAR,FAR_NUM_PRECIO,FAR_SUBTRA,FAR_PEDSER,FAR_PEDFAC,FAR_PEDSEC,
	           FAR_ORDEN_UNIDADES,FAR_CODUSU,FAR_MONEDA,FAR_COSTEO,FAR_COSPRO_ANT,FAR_COSTEO_REAL,
		   FAR_HORA,FAR_SERGUIA,FAR_ISLA,FAR_TURNO,FAR_TIPDOC,FAR_FBG2,FAR_PORDESCTOS,FAR_FLAG_SO,
		   FAR_NUMOPER2)
 		 VALUES
		   (@valor,@codcia,@serie,@f,@factura,@secuencia,@fecha,@numeope,@cliente,
		     @articulo,@space,@n,0,@dias,-1,@precio,@stock,0,@totaligv,0,0,0,@totalimporte,
		     1,0,0,@space,0,0,0,@c,@totalneto,0,0,0,0,@n,0,@cantidad,@space,@ftipofac,0,0,
		      @kilo,0,0,@space,-1,0,@space,@serieped,@pedido,0,0,@usuario,@fmoneda,@space,
		      0,@space,@hora,@serieguia,0,0,@ftipodocu,@ftipofac,0,@x,@nopera2 )'
	SET @PARAME=N'@codcia VARCHAR(2),
		@serie VARCHAR(3),
		@factura VARCHAR(5),
		@secuencia INTEGER,
		@fecha DATETIME,
		@numeope INTEGER,
		@cliente VARCHAR(5),
		@articulo VARCHAR(20),
		@DIAS INTEGER,
		@PRECIO float,
		@stock float,
		@totaligv float,
		@totalimporte float,
		@totalneto float,
		@cantidad float,
		@serieped VARCHAR(3),
		@pedido VARCHAR(5),
		@usuario VARCHAR(8),
		@fmoneda VARCHAR(1),
		@serieguia VARCHAR(3),
		@ftipodocu VARCHAR(2),
		@ftipofac VARCHAR(1),
		@nopera2 INTEGER,
		@n VARCHAR(1),@f VARCHAR(1),@c VARCHAR(1),@x VARCHAR(1),@kilo VARCHAR(3),@space VARCHAR(1),@valor VARCHAR(2),@HORA VARCHAR(8)'
	execute sp_executesql @cadena,@parame,@codcia,
					@serie,
					@factura,
					@secuencia,
					@fecha,
					@numeope,
					@cliente,
					@articulo,
					@dias,
					@precio,
					@stock,
					@totaligv,
					@totalimporte,
					@totalneto,
					@cantidad,
					@serieped,
					@pedido,
					@usuario,
					@fmoneda,
					@serieguia,
					@ftipodocu,
					@ftipofac,
					@nopera2,
					@n,
					@f,
					@c,
					@x,
					@kilo,
					@space,
					@valor,
					@hora
  End
If @tipo='2'	
  Begin 
  Set @cadena=N'UPDATE ['+@base+'].dbo.FACART
                  SET   FAR_TIPMOV=@VALOR,
			FAR_CODCIA=@codcia,
			FAR_NUMSER=@serie,
			FAR_FBG=@F,
			FAR_NUMFAC=@factura,
			FAR_NUMSEC=@secuencia,
			FAR_FECHA=@fecha,
			FAR_NUMOPER=@numeope,
			FAR_CODCLIE=@cliente,
			FAR_CODART=@articulo,
			FAR_TRANSITO=@space,
			FAR_ESTADO=@n,
			FAR_NUMGUIA=0,
			FAR_DIAS=@dias,
			FAR_SIGNO_ARM=0,
			FAR_PRECIO=@precio,
			FAR_STOCK=@stock,
			FAR_COSPRO=0,
			FAR_IMPTO=@totaligv,
			FAR_TOT_DESCTO=0,
			FAR_DESCTO=0,
			FAR_GASTOS=0,
			FAR_BRUTO=@totalimporte,
			FAR_EQUIV=1,
			FAR_PORDESCTO1=0,
			FAR_TIPO_CAMBIO=0
		WHERE  FAR_TIPMOV=@valor AND FAR_CODCIA=@codcia AND FAR_NUMSER=@serie AND FAR_CP=@c AND FAR_NUMFAC=@factura AND FAR_CODCLIE=@cliente AND FAR_CODART=@ARTICULO'
	SET @PARAME=N'@codcia VARCHAR(2),
		@serie VARCHAR(3),
		@factura VARCHAR(5),
		@secuencia INTEGER,
		@fecha DATETIME,
		@numeope INTEGER,
		@cliente VARCHAR(5),
		@articulo VARCHAR(20),
                @valor VARCHAR(2),
		@f VARCHAR(1),
		@space VARCHAR(1),
		@n VARCHAR(1),
		@dias INTEGER,
		@precio float,
		@stock float,
		@totaligv float,
		@totalimporte float,
		@c VARCHAR(1)'
	execute sp_executesql @cadena,@parame,
					@codcia,
					@serie,
					@factura,
					@secuencia,
					@fecha,
					@numeope,
					@cliente,
					@articulo,
			                @valor,
					@f,
					@space,
					@n,
					@dias,
					@precio,
					@stock,
					@totaligv,
					@totalimporte,
					@c
     Set @cadena=N'UPDATE ['+@base+'].dbo.FACART
                  SET   FAR_OTRA_CIA=@space,
			FAR_NUMSER_C=0,
			FAR_NUMFAC_C=0,
			FAR_NUMDOC=0,
			FAR_CP=@c,
			FAR_SUBTOTAL=@totalneto,
			FAR_CONSIG=0,
			FAR_PRECIO_NETO=0,
			FAR_CODVEN=0,
			FAR_UNIDADES=0,
			FAR_ESTADO2=@n,
			FAR_NUM_LOTE=0,
			FAR_CANTIDAD=@cantidad,
			FAR_CONCEPTO=@space,
			FAR_COD_SUNAT=@ftipofac,
			FAR_FLETE=0,
			FAR_JABAS=0,
			FAR_DESCRI=@kilo,
			FAR_PESO=0,
			FAR_TOT_FLETE=0,
			FAR_EX_IGV=@space,
			FAR_SIGNO_CAR=-1,
			FAR_NUM_PRECIO=0,
			FAR_SUBTRA=@space
		WHERE  FAR_TIPMOV=@valor AND FAR_CODCIA=@codcia AND FAR_NUMSER=@serie AND FAR_CP=@c AND FAR_NUMFAC=@factura AND FAR_CODCLIE=@cliente  AND FAR_CODART=@ARTICULO'
	SET @PARAME=N'@codcia VARCHAR(2),
		@serie VARCHAR(3),
		@factura VARCHAR(5),
		@secuencia INTEGER,
		@fecha DATETIME,
		@numeope INTEGER,
		@cliente VARCHAR(5),
		@articulo VARCHAR(20),
                @valor VARCHAR(2),
		@c VARCHAR(1),
		@f VARCHAR(1),
		@space VARCHAR(1),
		@n VARCHAR(1),
		@DIAS INTEGER,
		@PRECIO float,
		@cantidad float,
		@stock float,
		@totaligv float,
                @totalneto float,
		@totalimporte float,
		@ftipofac VARCHAR(1),
		@kilo VARCHAR(3)'
	execute sp_executesql @cadena,@parame,
					@codcia,
					@serie,
					@factura,
					@secuencia,
					@fecha,
					@numeope,
					@cliente,
					@articulo,
			                @valor,
					@c,
					@f,
					@space,
					@n,
					@dias,
					@precio,
					@cantidad,
					@stock,
					@totaligv,
					@totalneto,
					@totalimporte,
					@ftipofac,
					@kilo
     Set @cadena=N'UPDATE ['+@base+'].dbo.FACART
		   SET	FAR_PEDSER=@serieped,
			FAR_PEDFAC=@pedido,
			FAR_PEDSEC=0,
			FAR_ORDEN_UNIDADES=0,
			FAR_CODUSU=@usuario,
			FAR_MONEDA=@fmoneda,
			FAR_COSTEO=@space,
			FAR_COSPRO_ANT=0,
			FAR_COSTEO_REAL=@space,
			FAR_HORA=@hora,
			FAR_SERGUIA=@serieguia,
			FAR_ISLA=0,
			FAR_TURNO=0,
			FAR_TIPDOC=@ftipodocu,
			FAR_FBG2=@space,
			FAR_PORDESCTOS=0,
			FAR_FLAG_SO=@x,
			FAR_NUMOPER2=@nopera2 
		WHERE  FAR_TIPMOV=@valor AND FAR_CODCIA=@codcia AND FAR_NUMSER=@serie AND FAR_CP=@c AND FAR_NUMFAC=@factura AND FAR_CODCLIE=@cliente  AND FAR_CODART=@ARTICULO'
	SET @PARAME=N'@codcia VARCHAR(2),
		@serie VARCHAR(3),
		@factura VARCHAR(5),
		@secuencia INTEGER,
		@fecha DATETIME,
		@numeope INTEGER,
		@cliente VARCHAR(5),
		@articulo VARCHAR(20),
		@serieped VARCHAR(3),
		@pedido VARCHAR(5),
		@usuario VARCHAR(8),
		@fmoneda VARCHAR(1),
		@serieguia VARCHAR(3),
		@ftipodocu VARCHAR(2),
		@nopera2 INTEGER,
		@space VARCHAR(1),
		@valor VARCHAR(2),
                @hora VARCHAR(8),
		@c VARCHAR(1),
		@x VARCHAR(1)'
	execute sp_executesql @cadena,@parame,@codcia,
					@serie,
					@factura,
					@secuencia,
					@fecha,
					@numeope,
					@cliente,
					@articulo,
					@serieped,
					@pedido,
					@usuario,
					@fmoneda,
					@serieguia,
					@tipofac,
					@nopera2,
					@space,
					@valor,
					@hora,
					@c,
					@x
	
  END
GO
