SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [cs_settintopaso3]
/*4 Procedimiento
  Insertando los datos de produccion por maquina 
  y tambien los kilos 
*/
--Select * from ##tmp_headordendesarrollo3
--Select * from ##tmp_Detordendesarrollo3
--Select * from ##tmp_CTRLordendesarrollo3
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
Set @compu='Desarrollo4'*/
As
Declare @Sqlcad varchar(8000)
--delete costos.dbo.cs_produciionxmaquina
Set @Sqlcad='Delete from ['+@Basedest+'].dbo.cs_produciionxmaquina where 
             month(prodmaqfecha)='+cast(@mes as varchar(2))+ ' and year(prodmaqfecha)='
             + cast(@year as varchar(4))    
exec(@Sqlcad)
Set @Sqlcad=''+
'Insert Into ['+@Basedest+'].dbo.cs_produciionxmaquina (
unidadnegociocodigo,
cod_orden,
prodmaqfecha,
maqxnegcodigo,
tipoprocesocodigo,
productocodigo,
prodmaqhorastrab,
horasparadas,
prodmaqunid,
prodmaqimportes
 )
Select 
   unidadnegociocodigo='''+@unidadnegociocodigo+''',
   cod_orden='''', 
   FechaProduccion=Cast(floor(cast(A.H_Final as real)) as Datetime),
   maqxnegcodigo=Right(A.Cod_Rel,3),
   tipoprocesocodigo=0,
   productocodigo=isnull(A.Cod_Color,''@@''),   
   prodmaqhorastrab=0,          
   horasparadas=0,
   prodmaqunid=sum(A.Kilos_par),
   prodmaqimportes=0                                        
from  ##tmp_CTRLorden'+@compu+' A 
--where not A.Cod_Color is null 
Group by Right(A.Cod_Rel,3),A.Cod_Color,Cast(floor(cast(A.H_Final as real)) as datetime)
 '
EXec (@Sqlcad)
GO
