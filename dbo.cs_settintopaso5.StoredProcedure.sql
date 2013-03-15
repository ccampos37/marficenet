SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [cs_settintopaso5]
/*
Paso nro 6 
--Insertando los insumos 
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
--delete costos.dbo.cs_insumos 
Set @Sqlcad=''+
'Insert into ['+@Basedest+'].dbo.cs_insumos 
(unidadnegociocodigo,
 insumocodigo,
 insumodescripcion,
 familiainsumocodigo
  )
select
 unidadnegociocodigo='''+@unidadnegociocodigo+''',
 insumocodigo=A.QuimicoId,
 insumodescripcion=A.QuimicoDescripcion,
 familiainsumocodigo=A.SubfamiliaId 
from ['+@BaseOrig+'].dbo.[Maestro Quimicos] A
where QuimicoId in 
(select distinct QuimicoId from ##tmp_quimicopartesitems'+@compu+') 
 and  QuimicoId not in (select insumocodigo from ['+@Basedest+'].dbo.cs_insumos ) '
Exec(@Sqlcad)
GO
