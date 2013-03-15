SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [cs_settintopaso2]
--3 Procedimiento 
/*
  Insertando los productos que vendrian hacer los colores en tintoreria
  se extrae de la tabla ##tmp_CTRLordendesarrollo3
  La familia se especificara luego por base de datos o a traves de un mantenimiento
*/
--Select * from ##tmp_headordendesarrollo3
--Select * from ##tmp_Detordendesarrollo3
--Select * from ##tmp_CTRLordendesarrollo3
--Declare 
	@Basedest varchar(50),
	@BaseOrig varchar(50),
    @unidadnegociocodigo varchar(2),--Se refiere a la ubicacion fisica del negocio 
                                   --que puede ser tintoreria,tejeduria o confecciones
    @compu varchar(50)
/*Set @Basedest='costos'
Set @BaseOrig='db_costos'
Set @unidadnegociocodigo='01'
Set @compu='Desarrollo3'*/
as
Declare @sqlcad varchar(8000)
Set @sqlcad=''+
'Insert into ['+@Basedest+'].dbo.cs_productos (
 unidadnegociocodigo,
 familiaproductocodigo,
 productocodigo,
 codigodescripcin )
Select 
  unidadnegociocodigo='''+@unidadnegociocodigo+''',
  familiaproductocodigo=''01'',
  productocodigo=A.Cod_Pnt,
  codigodescripcin=Descr_Pnt 	 
from  ['+@BaseOrig+'].dbo.pantone A,  
 (Select distinct Cod_Color=A.Cod_Pnt from ['+@BaseOrig+'].dbo.Formula A,
    (Select distinct cod_formula from ##tmp_headorden'+@compu+') B
  Where A.Cod_Form=B.cod_formula) B
  Where A.Cod_Pnt=B.Cod_Color and 
      A.Cod_Pnt not in (Select productocodigo from ['+@Basedest+'].dbo.cs_productos ) '
Exec(@sqlcad)
GO
