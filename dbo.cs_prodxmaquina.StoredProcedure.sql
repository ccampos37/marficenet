SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [cs_prodxmaquina]
@Base varchar(50),
@unidadnegociocodigo varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)	
/*Set @Base='Costos'	
Set @unidadnegociocodigo='01'
Set @fechaini='37710'
Set @fechafin='37719'*/
as
--Exec cs_prodxmaquina 'Costos','01','37710','37719'
Declare @SqlCad varchar(8000)	
Set @SqlCad=''+
'select 
   A.unidadnegociocodigo,	
   A.maqxnegcodigo,
   B.maqxnegociodescripcion,
   A.prodmaqfecha,
   A.tipoprocesocodigo,
   proceso=case when A.tipoprocesocodigo=''0'' then ''Prod. Normal'' else ''Reproc'' end,
   A.prodmaqunid,
   A.productocodigo,
   C.codigodescripcin   
from ['+@Base+'].dbo.cs_produciionxmaquina A
Inner Join ['+@Base+'].dbo.cs_maqxnegocio B
on A.maqxnegcodigo=B.maqxnegcodigo and 
   A.unidadnegociocodigo=B.unidadnegociocodigo
inner join ['+@Base+'].dbo.cs_productos C 
on 
A.productocodigo=C.productocodigo and 
A.unidadnegociocodigo=C.unidadnegociocodigo
where 
   A.unidadnegociocodigo='''+@unidadnegociocodigo+''' and 
   floor(cast(A.prodmaqfecha as real)) between '+ @fechaini +' and  '+ @fechafin + ' 
Order by A.prodmaqfecha '    
Exec(@SqlCad)
GO
