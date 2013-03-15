SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*


drop proc ct_BalanceGen_Anexo_rpt

execute ct_balancegen_anexo_rpt 'planta_casma','01','2009','01',2,'xx',0


*/

CREATE    Proc [ct_BalanceGen_Anexo_rpt]
@Base varchar(50),
@empresa	varchar(2),
@Anno  varchar(4),
@Mes  varchar(2),
@Nivel Varchar(2),
@Compu Varchar(50),
@Modo  integer=0
as
If Exists(Select name from tempdb.dbo.sysobjects where name ='##tmp_balance_anexo'+@compu)
	Exec('Drop Table ##tmp_balance_anexo'+@compu)
Declare
@SqlCad Varchar(8000)
Set @SqlCad='
select a.cuentadescripcion,zz.*from ['+@Base+'].dbo.ct_cuenta a inner join
( Select a.empresacodigo,it=''1'',strucbalancedual,tipo=''ACTIVO'',A.CuentaCodigo,strucbalancedescrip1,
       debe=saldoacumdebe'+@Mes+',
               haber=saldoacumhaber'+@Mes+', 	       
	       linea=B.strucbalancelinea                      
	 from ['+@Base+'].dbo.ct_saldos'+@Anno+' A ,['+@Base+'].dbo.ct_strucbalance B
 	 Where a.empresacodigo='''+@empresa+''' and PATINDEX(''%*''+left(A.Cuentacodigo,'+@Nivel+')+''*%'',B.strucbalancenivel1) > 0  
             AND ( saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+' >0 or
                  (strucbalancesigno1=''-'' and  saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+' <>0 ))
           
     UNION ALL
  Select a.empresacodigo,it=''2'',strucbalancedual,tipo=''PASIVO'',A.CuentaCodigo,strucbalancedescrip2,
	       debe=saldoacumdebe'+@Mes+',
               haber=saldoacumhaber'+@Mes+', 	       
	       linea=B.strucbalancelinea                      
	 from ['+@Base+'].dbo.ct_saldos'+@anno+' A ,['+@Base+'].dbo.ct_strucbalance B
 	 Where a.empresacodigo='''+@empresa+''' and PATINDEX(''%*''+left(A.Cuentacodigo,'+@Nivel+')+''*%'',B.strucbalancenivel2) > 0  
             AND (saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+' <0 or 
                    (strucbalancedual=0 and saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+'<>0))
 ) as zz on a.empresacodigo=zz.empresacodigo and a.cuentacodigo=zz.cuentacodigo ' 
      
execute( @SqlCad)
GO
