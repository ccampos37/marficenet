SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop       proc ct_PlanCuentas_rpt
*/
CREATE   proc [ct_PlanCuentas_rpt]
(@Base varchar(50),
 @empresa varchar(2),
 @cuentacodigo as varchar(20))
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select Cuenta1=left(cuentacodigo,2),Cuenta2=left(cuentacodigo,3),Cuenta3=left(cuentacodigo,4),
			cuentacodigo,cuentadescripcion,tipoanaliticocodigo 
	 From [' +@base+'].dbo.ct_cuenta
    Where empresacodigo='''+@empresa+'''and cuentacodigo like '''+@cuentacodigo+''' and cuentanivel=''4''
	 order by cuentacodigo'
exec (@sqlcad)
GO
