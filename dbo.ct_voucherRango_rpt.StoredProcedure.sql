SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop  proc ct_voucherRango_rpt
*/
CREATE   proc [ct_voucherRango_rpt]
(@Base varchar(50),
 @empresa varchar(2),
 @anno varchar(4), 
 @cabcomprobmes varchar(2),
 @cabcomprobnumeroini varchar(10),
 @cabcomprobnumerofin varchar(10))
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select A.*,B.*,C.asientodescripcion ,D.subasientodescripcion,
     E.entidadrazonsocial,F.cuentadocumento 
    From ['+@base+'].dbo.[ct_cabcomprob'+@anno+'] A inner join ['+@base+'].dbo.[ct_detcomprob'+@anno+'] B
           on a.empresacodigo=b.empresacodigo and A.cabcomprobmes=B.cabcomprobmes and 
              A.cabcomprobnumero=B.cabcomprobnumero and
              A.asientocodigo=B.asientocodigo and A.subasientocodigo=B.subasientocodigo 
         inner join ['+@base+'].dbo.[ct_asiento] C on B.asientocodigo=C.asientocodigo 
         inner join ['+@base+'].dbo.[ct_subasiento] D 
               on B.asientocodigo=D.asientocodigo and B.subasientocodigo=D.subasientocodigo 
         inner join ['+@base+'].dbo.[v_analiticoentidad] E on B.analiticocodigo=E.analiticocodigo  	      
         inner join ['+@base+'].dbo.[ct_cuenta] F on b.empresacodigo=f.empresacodigo and b.cuentacodigo = f.cuentacodigo
   Where a.empresacodigo='''+@empresa+''' and A.cabcomprobmes='+@cabcomprobmes+ char(13)+         
         'and ' + '(A.cabcomprobnumero between '''+@cabcomprobnumeroini+''' and '''+ @cabcomprobnumerofin + ''')'
exec (@sqlcad)
GO
