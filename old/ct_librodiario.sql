SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_diario02_rpt
execute [ct_Librodiario_rpt] 'planta_casma','03','2011','02','%%','%%','%%'
*/
--*****Libro Diario Detallado
ALTER  proc [ct_libroDiario_rpt]
(
 @Base varchar(50),
 @empresa varchar(2), 
 @anno varchar(4), 
 @cabcomprobmes varchar(2),
 @cabcomprobnumero varchar(10)='%%',
 @asientocodigo varchar(3)='%%',
 @subasientocodigo varchar(4)='%%',
 @formato varchar(30)='FORMATO 05.01'
)
as
Declare @sqlcad varchar(5000)


set @sqlcad='declare @cad1 varchar(100)
declare @cad2 varchar(100)
Set @cad1=(select formatodescripcion1 from '+@base+'.dbo.ct_formatos where formatocodigo='''+@formato+''' )
Set @cad2=(select formatodescripcion2 from '+@base+'.dbo.ct_formatos where formatocodigo='''+@formato+''' ) '

set @sqlcad=@sqlcad+' SELECT formatodescripcion1=@cad1,formatodescripcion2=@cad2,formato='''+@formato+''',
      documento=b.documentocodigo+''  ''+dbo.fn_formatoNumDoc(b.detcomprobnumdocumento), 
      A.*,B.*,C.asientodescripcion ,D.subasientodescripcion,
     E.entidadrazonsocial,F.cuentadocumento,F.cuentadescripcion,aaaa='''+@anno+''' 
    From ['+@base+'].dbo.[ct_cabcomprob'+@anno+'] A
         left join ['+@base+'].dbo.[ct_detcomprob'+@anno+'] B on A.empresacodigo=B.empresacodigo and
	      A.cabcomprobmes=B.cabcomprobmes and A.cabcomprobnumero=B.cabcomprobnumero 
              and A.asientocodigo=B.asientocodigo and A.subasientocodigo=B.subasientocodigo        
         left join ['+@base+'].dbo.[ct_asiento] C on  B.asientocodigo=C.asientocodigo 
         left join ['+@base+'].dbo.[ct_subasiento] D on  B.asientocodigo=D.asientocodigo and
               B.subasientocodigo=D.subasientocodigo
  	 left join  ['+@base+'].dbo.[v_analiticoentidad] E on  B.analiticocodigo=E.analiticocodigo
         left join ['+@base+'].dbo.[ct_cuenta] F on  b.empresacodigo=f.empresacodigo and b.cuentacodigo = f.cuentacodigo 
 Where   A.empresacodigo like '''+@empresa+''' and 
	 A.cabcomprobmes='+@cabcomprobmes+ char(13)+         
         'and A.asientocodigo like '''+@asientocodigo+''' and 
         A.subasientocodigo like '''+@subasientocodigo+''' and 
	 A.cabcomprobnumero like '''+@cabcomprobnumero+''''
execute (@sqlcad)
--PRINT  (@sqlcad)









set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
