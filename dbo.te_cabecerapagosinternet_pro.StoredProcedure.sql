SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute te_cabecerapagosinternet_pro 'planta_casma','1','01','333333','01/11/2009','01','01','wwww  '

*/


CREATE PROCEDURE [te_cabecerapagosinternet_pro]

@BASE nvarchar(50),
@tipo char(1),
@empresa char(2),
@numero char(6),
@fecha datetime,
@moneda nchar(2),
@banco char(2),
@cuenta nvarCHAR(20),
@tipodecambio float

AS

declare @CADENA AS nvarchar(4000)
declare @parame as nvarchar(4000)

	SET @cadena =N' Insert Into '+@base +'.dbo.te_cabecerapagosinternet
                (empresacodigo, pagosnumero,pagosfecha,
                 pagosmoneda,bancocodigo,bancocuenta,pagostipodecambio )
      VALUES ( @empresa , @numero,@fecha,
               @moneda,@banco,@cuenta,@tipodecambio ) '

	SET @Parame ='@tipo char(1), @empresa char(2), @numero char(6),
                    @fecha datetime,@moneda nchar(2),@banco char(2), 
                    @CUENTA nvarchar(20) , @tipodecambio float '

	EXEC sp_executesql @cadena,@parame,@base,
              @empresa ,@numero ,@fecha 
              ,@moneda ,@banco ,@CUENTA ,@tipodecambio
GO
