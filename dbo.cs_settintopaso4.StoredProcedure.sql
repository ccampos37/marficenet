SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [cs_settintopaso4]
/*
Paso nro 5 Insertando las familias de insumos
*/
--Declare 
	@Basedest varchar(50),	
    @BaseOrig varchar(50),
    @unidadnegociocodigo varchar(2),--Se refiere a la ubicacion fisica del negocio 
                                  --que puede ser tintoreria,tejeduria o confecciones	
    @compu varchar(50) 
/*Set @Basedest='costos'
Set @BaseOrig='empresas'
Set @unidadnegociocodigo='01'
Set @compu='Desarrollo3'*/
as
Declare @Sqlcad varchar(8000)
--delete costos.dbo.cs_familiainsumo
Set @Sqlcad=''+
'Insert into ['+@Basedest+'].dbo.cs_familiainsumo
(unidadnegociocodigo,
 familiainsumocodigo,
 familiainsumodescripcion )
Select 
  unidadnegociocodigo='''+@unidadnegociocodigo+''',
  familiainsumocodigo=A.SubfamiliaId,
  familiainsumodescripcion=A.Descripcion   
from ['+@BaseOrig+'].dbo.SubFamilias A
where A.SubfamiliaId in 
(select distinct SubfamiliaId from ['+@BaseOrig+'].dbo.[Maestro Quimicos]
where QuimicoId in 
(select distinct QuimicoId from ##tmp_quimicopartesitems'+@compu+' )
) and A.SubfamiliaId not in (select familiainsumocodigo from ['+@Basedest+'].dbo.cs_familiainsumo) ' 
 
exec(@Sqlcad)
GO
