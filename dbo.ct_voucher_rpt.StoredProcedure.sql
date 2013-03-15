SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_voucher_rpt    fecha de la secuencia de comandos: 19/12/2007 11:54:28 a.m. *****
drop proc ct_voucher_rpt
*/
CREATE     proc [ct_voucher_rpt]
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
     E.*,F.* 
     From ['+@base+'].dbo.[ct_cabcomprob'+@anno+'] A
          inner join ['+@base+'].dbo.[ct_detcomprob'+@anno+'] B
             on   A.empresacodigo=B.empresacodigo and 
                  A.cabcomprobmes=B.cabcomprobmes and 
                  A.cabcomprobnumero=B.cabcomprobnumero and 
                  A.asientocodigo=B.asientocodigo and  
                  A.subasientocodigo=B.subasientocodigo 
          left join ['+@base+'].dbo.[ct_asiento] C
             on   B.asientocodigo=C.asientocodigo 
          left join ['+@base+'].dbo.[ct_subasiento] D
             on   B.asientocodigo=D.asientocodigo and 
                  B.subasientocodigo=D.subasientocodigo 
  	 left join ['+@base+'].dbo.[v_analiticoentidad] E
             on   B.analiticocodigo=E.analiticocodigo 
          inner join ['+@base+'].dbo.[ct_cuenta] F 
             on   b.empresacodigo=f.empresacodigo and B.cuentacodigo=F.cuentacodigo
     Where    
              A.empresacodigo='''+@empresa+''' and 
              A.cabcomprobmes='+@cabcomprobmes+ char(13)+'and 
              A.asientocodigo='''+@asientocodigo+''' and 
              A.subasientocodigo='''+@subasientocodigo+''' and 
	      A.cabcomprobnumero like '''+@cabcomprobnumero+''''
execute (@sqlcad)  
--execute ct_voucher_rpt 'data_mmj','2005',7,'0706500005','065','0013'
GO
