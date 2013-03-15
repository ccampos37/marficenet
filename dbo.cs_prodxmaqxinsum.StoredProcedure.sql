SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  proc [cs_prodxmaqxinsum]
/*
Author : Fernando Cossio peralta
Objetivo: Reporte de produccion por maquina y fecha 
y los insumos que se han utilizado para la elaboracion de cada color 
se representa como referencia cruzada en el crystal report
*/
-- select cast(cast('01/04/2003' as datetime ) as real)
-- select cast(cast('10/04/2003' as datetime ) as real)
--Declare 
@Base varchar(50),
@unidadnegociocodigo varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)	
/*Set @Base='Costos'	
Set @unidadnegociocodigo='01'
Set @fechaini='37710'
Set @fechafin='37725'*/
as
Declare @SqlCad varchar(8000)	
Set @SqlCad=''+
'select 
    A.prodmaqfecha,
    A.maqxnegcodigo,
    C.maqxnegociodescripcion,
    A.productocodigo,
	D.codigodescripcin,
	A.insumocodigo,
    B.insumodescripcion,
    kilos=A.consumounidfisica,
    precio=A.consumounidmonetaria
from 
   ['+@Base+'].dbo.cs_consumoproduccion A
inner join ['+@Base+'].dbo.cs_insumos B
    on A.insumocodigo=B.insumocodigo and  
       A.unidadnegociocodigo=B.unidadnegociocodigo
inner join ['+@Base+'].dbo.cs_maqxnegocio C
    on A.maqxnegcodigo=C.maqxnegcodigo and 
       A.unidadnegociocodigo=C.unidadnegociocodigo 
inner join ['+@Base+'].dbo.cs_productos D
    on A.productocodigo=D.productocodigo and 
       A.unidadnegociocodigo=D.unidadnegociocodigo   
Where A.unidadnegociocodigo='''+@unidadnegociocodigo+''' and 
      floor(cast(A.prodmaqfecha as real)) between '+@fechaini+' and '+@fechafin
Exec(@SqlCad)
GO
