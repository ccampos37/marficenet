SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop  proc ct_asientosdescuadrados
exec ct_asientosdescuadrados 'gremco','37','2008','02'
*/
CREATE    proc [ct_asientosdescuadrados]
(
	@base		varchar(50),
        @empresa 	varchar(2),
	@anno		varchar(4),
	@mes		varchar(2)
)
as
declare @sqlcad varchar(3000)
set @sqlcad='
select asientocodigo,subasientocodigo,a.cabcomprobnumero,sumadebe=sum(a.detcomprobdebe),sumahaber=sum(a.detcomprobhaber) 
from  [' +@base+ '].dbo.ct_detcomprob' +@anno+ ' a
left join  [' +@base+ '].dbo.ct_analitico b on a.analiticocodigo=b.analiticocodigo
inner join  [' +@base+ '].dbo.ct_cuenta c on a.empresacodigo=c.empresacodigo and a.cuentacodigo=c.cuentacodigo
where a.empresacodigo='''+@empresa+''' and a.cabcomprobmes=' +@mes+'
group by asientocodigo,subasientocodigo,cabcomprobnumero
having round(sum(detcomprobdebe),2)<>round(sum(detcomprobhaber),2)
order by 1'
exec(@sqlcad)
--print(@sqlcad)
GO
