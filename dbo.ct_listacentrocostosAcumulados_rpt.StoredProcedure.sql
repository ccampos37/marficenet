SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [ct_listacentrocostosAcumulados_rpt] 'aliterm2012','01','2012','12','1'

*/
--***Diario Resumido***
CREATE      proc [ct_listacentrocostosAcumulados_rpt]
@Base varchar(50),
@empresa varchar(2),
@anno varchar(4), 
@cabcomprobmes varchar(2),
@tipo varchar(1)='0'
as
Declare @sqlcad varchar(5000)
if @tipo='0' Set @sqlcad=''+ 
    'Select tipo='' ''+c.centrocostodescripcion, CuentaDescripcion= A.cuentacodigo+'' - ''+B.CuentaDescripcion,
            dato='' MES'',gastos=a.gastos'+@cabcomprobmes+' From ['+@base+'].dbo.[ct_gastos'+@anno+'] A
    inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
    INNER join ['+@base+'].dbo.[ct_centrocosto] C on a.empresacodigo=c.empresacodigo and A.centrocostocodigo=C.centrocostocodigo 
    where a.empresacodigo='''+@empresa+'''
 union all
    Select tipo='' ''+c.centrocostodescripcion, CuentaDescripcion= A.cuentacodigo+'' - ''+B.CuentaDescripcion,
            dato=''ACUM'',gastos=a.gastosacum'+@cabcomprobmes+ ' From ['+@base+'].dbo.[ct_gastos'+@anno+'] A
    inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
    INNER join ['+@base+'].dbo.[ct_centrocosto] C on a.empresacodigo=c.empresacodigo and A.centrocostocodigo=C.centrocostocodigo 
    where a.empresacodigo='''+@empresa+'''
 union all
    Select tipo=''TOTAL'',CuentaDescripcion= A.cuentacodigo+'' - ''+B.CuentaDescripcion,dato='' MES'',gastos=sum(a.gastos'+@cabcomprobmes+ ') 
           From ['+@base+'].dbo.[ct_gastos'+@anno+'] A 
    inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
    where a.empresacodigo='''+@empresa+'''
    group by A.cuentacodigo,B.CuentaDescripcion
 union all
    Select tipo=''TOTAL'',CuentaDescripcion= A.cuentacodigo+'' - ''+B.CuentaDescripcion,dato=''ACUM'',gastos=sum(a.gastosacum'+@cabcomprobmes+ ') 
           From ['+@base+'].dbo.[ct_gastos'+@anno+'] A 
    inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
    where a.empresacodigo='''+@empresa+'''
    group by A.cuentacodigo,B.CuentaDescripcion  '
if @tipo='1' Set @sqlcad=''+ 
    'select cuenta=left(A.cuentacodigo,2),
     descuenta=x.CuentaDescripcion , 
     CuentaDescripcion= A.cuentacodigo+'' - ''+B.CuentaDescripcion,
         gastos01=sum(gastos01),gastos02=sum(gastos02),gastos03=sum(gastos03),gastos04=sum(gastos04),
         gastos05=sum(gastos05),gastos06=sum(gastos06),gastos07=sum(gastos07),gastos08=sum(gastos08),
         gastos09=sum(gastos09),gastos10=sum(gastos10),gastos11=sum(gastos11),gastos12=sum(gastos12),
         gastos03=sum(gastos03),gastos03=sum(gastos03),gastos03=sum(gastos03),
         gastosacum12=SUM(gastosacum12)
     From ['+@base+'].dbo.[ct_gastos'+@anno+'] A 
     inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
     left join ['+@base+'].dbo.[ct_cuenta] x on a.empresacodigo+LEFT(a.cuentacodigo,2)=x.empresacodigo+x.cuentacodigo
     where a.empresacodigo='''+@empresa+''' and b.cuentaestadoccostos =1
     GROUP BY  left(A.cuentacodigo,2),x.CuentaDescripcion ,A.cuentacodigo , B.CuentaDescripcion '
execute (@sqlcad)
--select * from mmj.dbo.ct_gastos2007
---execute ct_listacentrocostosAcumulados_rpt 'planta_casma','01','2008','07','1'


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
