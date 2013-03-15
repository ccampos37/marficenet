SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create  proc [cs_prodxmaqResuTiempo_rpt]
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
@anno varchar(4)
/*Set @Base='Costos'	
Set @unidadnegociocodigo='01'
Set @anno='2003'*/
As
Declare @SqlCad varchar(8000)	
Set @SqlCad=''+
'select 
   A.unidadnegociocodigo,	
   A.maqxnegcodigo,
   B.maqxnegociodescripcion,   
   A.tipoprocesocodigo,
   proceso=case when A.tipoprocesocodigo=''01'' then ''Prod. Normal'' else ''Reproc'' end,
   Sumprodmaqtiempo=Sum(A.prodmaqhorastrab),
   mes=month(A.prodmaqfecha)   
from ['+@Base+'].dbo.cs_produciionxmaquina A
Inner Join ['+@Base+'].dbo.cs_maqxnegocio B
on A.maqxnegcodigo=B.maqxnegcodigo and 
   A.unidadnegociocodigo=B.unidadnegociocodigo
where 
   A.unidadnegociocodigo='''+@unidadnegociocodigo+''' and    
   year(A.prodmaqfecha)='+@anno+'
Group by A.unidadnegociocodigo,A.maqxnegcodigo,
         B.maqxnegociodescripcion,A.tipoprocesocodigo,
         A.tipoprocesocodigo,month(A.prodmaqfecha)    '
Exec(@SqlCad)
GO
