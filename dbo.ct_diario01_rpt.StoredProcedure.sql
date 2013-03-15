SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_diario01_rpt    fecha de la secuencia de comandos: 01/01/2008 07:57:55 p.m. ******/
/*
drop proc ct_diario01_rpt 
execute ct_diario01_rpt 'gremco','12','2008','01','%%','%%'
*/
--***Diario Resumido***
CREATE         proc [ct_diario01_rpt]
(
 @Base varchar(50),
 @empresa varchar(2),
 @anno varchar(4),
 @cabcomprobmes varchar(2),
 --@cabcomprobnumero varchar(10),
 @asientocodigo varchar(3),
 @subasientocodigo varchar(4))
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select tipo=case when A.detcomprobdebe > 0 then ''1'' else ''2'' end,a.empresacodigo, A.asientocodigo,A.subasientocodigo,A.cuentacodigo,B.CuentaDescripcion,
            A.detcomprobdebe,A.detcomprobhaber,C.asientodescripcion,D.subasientodescripcion,
            left(A.cuentacodigo,2) as cod2
    From ['+@base+'].dbo.[ct_detcomprob'+@anno+'] A
         left join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
          left join ['+@base+'].dbo.[ct_asiento] C on A.asientocodigo=C.asientocodigo 
         left join ['+@base+'].dbo.[ct_subasiento] D 
              on  A.asientocodigo=D.asientocodigo and A.subasientocodigo=D.subasientocodigo 
    	
    Where 
	A.empresacodigo like ''' + @empresa+ ''' and 
	A.asientocodigo like ''' + @asientocodigo+ ''' and 
        A.subasientocodigo like ''' + @subasientocodigo + ''' and 
	A.cabcomprobmes=''' + @cabcomprobmes + ''''
EXECUTE (@sqlcad)
GO
