SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      proc [cs_tablaayudas_rpt]
--Declare 
   @Base varchar(100),
   @op int,
   @Criterio varchar(4000)=Null 
as 
/*
Set @Base='Costos' 	
set @op=4
Set @Criterio=' Where A.unidadnegociocodigo like ''01'''*/
--Set @Criterio=''
--exec cs_tablaayudas_rpt 'costos',7,''
Declare @Sqlcad varchar(8000)
Set @Sqlcad=
  case @op 
  	when 1 then --Reporte de Unidad de Negocio
		'Select unidadnegociocodigo, unidadnegociodescripcion, usuario, fechaact 
         From ['+@Base+'].dbo.cs_unidaddenegocio '	           
    when 2 then --Flujo del Negocio
        'Select A.unidadnegociocodigo,B.unidadnegociodescripcion, 
                A.flujonegociocodigo,A.flujonegociodescripcion, 
         A.usuario,A.fechaact  
         From ['+@Base+'].dbo.cs_flujodelnegocio A 
         Inner join  ['+@Base+'].dbo.cs_unidaddenegocio B
         on A.unidadnegociocodigo=B.unidadnegociocodigo  ' 
    when 3 then --Maquina por Negocio
        'Select A.maqxnegcodigo, A.maqxnegociodescripcion, 
                A.flujonegociocodigo,C.flujonegociodescripcion,
                A.unidadnegociocodigo,B.unidadnegociodescripcion,
                A.usuario,A.fechaact
         From ['+@Base+'].dbo.cs_maqxnegocio A      
         inner join ['+@Base+'].dbo.cs_unidaddenegocio B 
         on A.unidadnegociocodigo=B.unidadnegociocodigo 
         inner join ['+@Base+'].dbo.cs_flujodelnegocio C 
         on A.unidadnegociocodigo=C.unidadnegociocodigo and 
            A.flujonegociocodigo=C.flujonegociocodigo ' 
    when 4 then --Productos
       ' Select A.productocodigo, A.unidadnegociocodigo,
               B.unidadnegociodescripcion,A.codigodescripcin, 
               A.familiaproductocodigo,C.negociodescripcion,
               A.usuario, A.fechaact
        From ['+@Base+'].dbo.cs_productos A 
        Inner Join ['+@Base+'].dbo.cs_unidaddenegocio B 
        on A.unidadnegociocodigo=B.unidadnegociocodigo 
        Inner Join ['+@Base+'].dbo.cs_tipodefamilia C 
        on A.unidadnegociocodigo=C.unidadnegociocodigo and 
           A.familiaproductocodigo=C.familiaproductocodigo   '
   when 5 then --Familia de Productos
       'Select A.unidadnegociocodigo,B.unidadnegociodescripcion, 
               A.familiaproductocodigo,A.negociodescripcion,
         A.usuario,A.fechaact  
         From ['+@Base+'].dbo.cs_tipodefamilia A 
         Inner join  ['+@Base+'].dbo.cs_unidaddenegocio B
         on A.unidadnegociocodigo=B.unidadnegociocodigo  '  
   when 6 then 
	  ' Select  A.costoscodigo,B.costosdescripcion,A.cencostos2,
               C.costosdescripcion,
               A.factordistrib, A.usuario, A.fechaact
       From ['+@Base+'].dbo.cs_factordecencostos A
       Inner join  
       (select costoscodigo,costosdescripcion from ['+@Base+'].dbo.cs_centrodecostos) B 
        on A.costoscodigo=B.costoscodigo  
       Inner join          
       (select costoscodigo,costosdescripcion from ['+@Base+'].dbo.cs_centrodecostos) C 
        on A.costoscodigo=C.costoscodigo  '           
   when 7 then 
	       'Select A.unidadnegociocodigo,B.unidadnegociodescripcion, 
               A.familiainsumocodigo,A.familiainsumodescripcion,
         A.usuario,A.fechaact  
         From ['+@Base+'].dbo.cs_familiainsumo A 
         Inner join  ['+@Base+'].dbo.cs_unidaddenegocio B
         on A.unidadnegociocodigo=B.unidadnegociocodigo  '  
		 
  End  
Exec(@Sqlcad+@Criterio)
GO
