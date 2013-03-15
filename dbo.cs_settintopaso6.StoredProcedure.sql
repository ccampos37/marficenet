SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [cs_settintopaso6]
/*
Paso 7 
Insertar el consumo de 
*/
--Declare 
	@Basedest varchar(50),
	@BaseOrig varchar(50),
    @unidadnegociocodigo varchar(2),--Se refiere a la ubicacion fisica del negocio 
                                  --que puede ser tintoreria,tejeduria o confecciones	
    @compu varchar(50),
    @mes int, 
    @year int  
/*Set @Basedest='costos'
Set @BaseOrig='db_costos'
Set @unidadnegociocodigo='01'
Set @mes=4 
set @year=2003
Set @compu='Desarrollo3'*/
as
Declare @Sqlcad varchar(8000)
--delete costos.dbo.cs_consumoproduccion
Set @Sqlcad='Delete from ['+@Basedest+'].dbo.cs_consumoproduccion where 
             month(prodmaqfecha)='+cast(@mes as varchar(2))+ ' and year(prodmaqfecha)='
             + cast(@year as varchar(4))    
exec(@Sqlcad)
Set @Sqlcad=''+
'Insert Into ['+@Basedest+'].dbo.cs_consumoproduccion (
 unidadnegociocodigo,
 cod_orden, 
 insumocodigo,
 prodmaqfecha,
 maqxnegcodigo,
 productocodigo,
 tipoprocesocodigo,
 consumounidfisica,
 consumounidmonetaria
 )
Select 
unidadnegociocodigo='''+@unidadnegociocodigo+''',
cod_orden=A.cod_orden, 
insumocodigo=B.QuimicoId,
prodmaqfecha=A.FechaDespacho,
maqxnegcodigo=A.maqxnegcodigo,
productocodigo=A.productocodigo,
tipoprocesocodigo=A.tipoprocesocodigo,
consumounidfisica=B.cant,
consumounidmonetaria=B.importe 
from (
Select    
   b.cod_orden, 
   C.FechaDespacho,
   maqxnegcodigo=B.Cod_Maq,
   tipoprocesocodigo=case when  isnull(C.reproceso,0)=0 then ''01'' else ''02'' end,
   productocodigo=E.Cod_Pnt,      
   horasparadas=0   
from (select distinct cod_partida from ##tmp_CTRLorden'+@compu+') as A
inner join  ##tmp_Detorden'+@compu+' B
		on A.Cod_Partida=B.Cod_Partida
inner join ##tmp_headorden'+@compu+' C
on B.cod_orden=C.cod_orden
inner join ['+@BaseOrig+'].dbo.Formula E 
on C.cod_formula=E.Cod_Form
Group by B.cod_orden,B.Cod_Maq,C.reproceso,E.Cod_Pnt,C.FechaDespacho ) as A
inner join 
   ( select A.cod_orden,
	       B.QuimicoId,cant=sum(B.QuimicoCantidadS),importe=sum(B.QuimicoImporteS ) 
	from 
	  ##tmp_quimicopartes'+@compu+' A,##tmp_quimicopartesitems'+@compu+' B 
	where A.NroMovQuimico=B.NroMovQuimico
	group by cod_orden,QuimicoId ) as B 
on A.cod_orden=B.cod_orden '
Exec (@Sqlcad)
GO
