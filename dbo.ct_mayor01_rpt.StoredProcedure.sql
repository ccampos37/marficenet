SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/******Libro Mayor Analitico
drop proc ct_mayor01_rpt 
*/
CREATE proc [ct_mayor01_rpt]
(@Base varchar(50),
 @empresa varchar(2),
 @anno varchar(4), 
 @mesproceso varchar(2),
 @cuentacodigo as varchar(20))
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select A.*,B.*,C.asientodescripcion ,D.subasientodescripcion,
     E.entidadrazonsocial,F.cuentadocumento,F.cuentadescripcion
    From ['+@base+'].dbo.[ct_cabcomprob'+@anno+'] A
         inner join ['+@base+'].dbo.[ct_detcomprob'+@anno+'] B
              on  a.empresacodigo=b.empresacodigo and A.cabcomprobmes=B.cabcomprobmes 
                  and A.cabcomprobnumero=B.cabcomprobnumero and A.asientocodigo=B.asientocodigo 
                  and A.subasientocodigo=B.subasientocodigo 
         inner join ['+@base+'].dbo.[ct_asiento] C
              on a.asientocodigo=C.asientocodigo 
         inner join ['+@base+'].dbo.[ct_subasiento] D
              on a.asientocodigo=D.asientocodigo and a.subasientocodigo=D.subasientocodigo  
  	 inner join ['+@base+'].dbo.[v_analiticoentidad] E
              on   B.analiticocodigo=E.analiticocodigo  	      
         inner join ['+@base+'].dbo.[ct_cuenta] F 
              on   b.empresacodigo=f.empresacodigo and b.cuentacodigo = f.cuentacodigo and 
    Where a.empresacodigo like '''+@empresa+''' and 
          f.cuentacodigo like '''+@cuentacodigo+''''
exec (@sqlcad)
---execute ct_mayor01_rpt 'docsa','2007','06','%%'
GO
