SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [cs_settintopaso1]
/* 
2 Paso creacion de los registros de maquina segun lo consultado
  utilizando la tabla temporal 
  ##tmp_headordendesarrollo3 
*/
--Select * from ##tmp_headordendesarrollo3
--Select * from ##tmp_Detordendesarrollo3
--Select * from ##tmp_CTRLordendesarrollo3
--Declare 
	@Basedest varchar(50),
	@BaseOrig varchar(50),
    @unidadnegociocodigo varchar(2),--Se refiere a la ubicacion fisica del negocio 
                                   --que puede ser tintoreria,tejeduria o confecciones
	@flujonegociocodigo varchar(2), --Se refiere a un proceso por maquina
    @compu varchar(50)
/*Set @Basedest='costos'
  Set @BaseOrig='db_costos'
  Set @unidadnegociocodigo='01'
  Set @flujonegociocodigo='01'
  Set @compu='Desarrollo3' */
as
Declare @sqlcad varchar(8000)
Set @sqlcad=''+ 
'Insert into ['+@Basedest+'].dbo.cs_maqxnegocio (
 unidadnegociocodigo, 
 flujonegociocodigo,
 maqxnegcodigo,
 maqxnegociodescripcion )
 Select 
	unidadnegociocodigo='''+@unidadnegociocodigo+''',
   flujonegociocodigo='+@flujonegociocodigo+',
   maqxnegcodigo=B.cod_maq,
   maqxnegociodescripcion=B.Nom_Maq   
 from  
   (select distinct cod_maq from ##tmp_headorden'+@compu+') as A, 
   ['+@BaseOrig+'].dbo.Maquinas B
 Where  A.Cod_Maq=B.Cod_Maq and 
       A.Cod_Maq not in (
       Select maqxnegcodigo 
       From ['+@Basedest+'].dbo.cs_maqxnegocio   
        ) '
Exec(@sqlcad)
GO
