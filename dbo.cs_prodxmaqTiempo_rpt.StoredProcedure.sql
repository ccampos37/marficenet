SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [cs_prodxmaqTiempo_rpt]
/*
Author : Fernando Cossio peralta
Objetivo: Reporte de produccion por maquina y fecha
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
Set @fechafin='37719'*/
as
Declare @SqlCad varchar(8000)	
Set @SqlCad=''+
'select 
   A.unidadnegociocodigo,	
   A.maqxnegcodigo,
   B.maqxnegociodescripcion,
   A.prodmaqfecha,
   A.tipoprocesocodigo,
   proceso=case when A.tipoprocesocodigo=''01'' then ''Prod. Normal'' else ''Reproc'' end,
   A.prodmaqhorastrab  
from ['+@Base+'].dbo.cs_produciionxmaquina A
Inner Join ['+@Base+'].dbo.cs_maqxnegocio B
on A.maqxnegcodigo=B.maqxnegcodigo and 
   A.unidadnegociocodigo=B.unidadnegociocodigo
where 
   A.unidadnegociocodigo='''+@unidadnegociocodigo+''' and 
   floor(cast(A.prodmaqfecha as real)) between '+ @fechaini +' and  '+ @fechafin + ' 
Order by A.prodmaqfecha '    
Exec(@SqlCad)
GO
