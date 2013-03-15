SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_diario02_rpt
execute ct_diario02_rpt 'gremco','40','2008','07','%%','007','%%'
*/
--*****Libro Diario Detallado
CREATE                proc [ct_diario02_rpt]
(
 @Base varchar(50),
 @empresa varchar(2), 
 @anno varchar(4), 
 @cabcomprobmes varchar(2),
 @cabcomprobnumero varchar(10),
 @asientocodigo varchar(3),
 @subasientocodigo varchar(4))
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select A.*,B.*,C.asientodescripcion ,D.subasientodescripcion,
     E.entidadrazonsocial,F.cuentadocumento,F.cuentadescripcion
    From ['+@base+'].dbo.[ct_cabcomprob'+@anno+'] A
         left join ['+@base+'].dbo.[ct_detcomprob'+@anno+'] B
           on A.empresacodigo=B.empresacodigo and
	      A.cabcomprobmes=B.cabcomprobmes and
              A.cabcomprobnumero=B.cabcomprobnumero 
              and A.asientocodigo=B.asientocodigo 
              and A.subasientocodigo=B.subasientocodigo        
         left join ['+@base+'].dbo.[ct_asiento] C
           on  B.asientocodigo=C.asientocodigo 
         left join ['+@base+'].dbo.[ct_subasiento] D
           on  B.asientocodigo=D.asientocodigo and
               B.subasientocodigo=D.subasientocodigo
  	 left join  ['+@base+'].dbo.[v_analiticoentidad] E
           on  B.analiticocodigo=E.analiticocodigo
         left join ['+@base+'].dbo.[ct_cuenta] F 
	     on  b.empresacodigo=f.empresacodigo and b.cuentacodigo = f.cuentacodigo 
 Where   A.empresacodigo like '''+@empresa+''' and 
	 A.cabcomprobmes='+@cabcomprobmes+ char(13)+         
         'and A.asientocodigo like '''+@asientocodigo+''' and 
         A.subasientocodigo like '''+@subasientocodigo+''' and 
	 A.cabcomprobnumero like '''+@cabcomprobnumero+''''
execute (@sqlcad)
--PRINT  (@sqlcad)









set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
