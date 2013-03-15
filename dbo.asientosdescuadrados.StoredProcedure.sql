SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [asientosdescuadrados]
(
	@base		varchar(50),
	@anno		varchar(4),
	@mes		varchar(2)
)
as
declare @sqlcad varchar(3000)
set @sqlcad='
select cabcomprobnumero,sumadebe=sum(detcomprobdebe),sumahaber=sum(detcomprobhaber) 
from  [' +@base+ '].dbo.ct_detcomprob' +@anno+ '
where cabcomprobmes=' +@mes+ '
group by cabcomprobnumero
having sum(detcomprobdebe)<>sum(detcomprobhaber)'
exec(@sqlcad)
--exec asientosdescuadrados 'contaprueba','2002','12'
GO
