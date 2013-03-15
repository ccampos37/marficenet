SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [vt_tiposdecontacto] 'ZIYAZ','01/08/2008','01/10/2008'
CREATE  PROC [vt_tiposdecontacto]		/*EN USO*/
@base varchar(50),
@fecdesde as varchar(10),
@fechasta as varchar(10)

AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'select a.pedidofecha,b.tipocontactodescripcion,sum(a.pedidototneto) as Total 
from ['+@base+'].dbo.vt_pedido a 
inner join ['+@base+'].dbo.vt_tipodecontacto b on a.tipocontactocodigo=b.tipocontactocodigo
where a.pedidofecha between '''+@fecdesde+''' and '''+@fechasta+''' 
group by b.tipocontactodescripcion,a.pedidofecha'

exec (@sensql)
RETURN
GO
