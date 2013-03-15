SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc te_actsaldo_pro
execute te_actsaldo_pro 'aliterm',1,'C','01','01','200801','01', 1200.00,'01/01/2008','sa'
*/
create        PROCEDURE [te_actsaldo_pro]
    (@base varchar(50),     
     @op int,
     @empresa varchar(2),
     @Oper 	varchar(1),
     @CodcajaBanco	varchar (2),
     @CtaBanco 	varchar(30),
     @aaaamm varchar (6),
     @CodMon 	varchar (2),
     @SaldoDisp  float,
     @fechaact  datetime,
     @usuariocodigo varchar(20))
As
DECLARE @sqlcad nvarchar(4000),@sqlparam nvarchar(4000)
IF @op=1 --Insertar Datos
BEGIN
Set @sqlcad=' INSERT INTO ['+@Base+'].[dbo].[Te_Saldosmensuales] 
	 ( empresacodigo,
	[tipocajabanco], 
	[CajaBancoCodigo], 
	[MonedaCuenta], 
	[mesproceso],
      	[Monedacodigo],
	[saldoinicial],
	fechaact,
	usuariocodigo ) 
 VALUES ( @empresa,@Oper,@CodcajaBanco,@CtaBanco,@aaaamm,@CodMon,@SaldoDisp,
	@fechaact,@usuariocodigo )'
set @sqlparam=N'@base varchar(50),     
     @Oper 	varchar(1),
     @empresa varchar(2),
     @CodcajaBanco	varchar (2),
     @CtaBanco 	varchar(30),
     @aaaamm varchar (6),
     @CodMon 	varchar (2),
     @SaldoDisp  float,
     @fechaact  datetime,
     @usuariocodigo varchar(20)'
EXEC sp_executesql @sqlcad,@sqlparam,@base,@Oper,@empresa,@CodcajaBanco,@CtaBanco,@aaaamm,@CodMon,@SaldoDisp,
	@fechaact,@usuariocodigo
End
GO
