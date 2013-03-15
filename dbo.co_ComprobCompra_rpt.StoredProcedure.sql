SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [co_ComprobCompra_rpt]
--Declare
@basecompra varchar(50),
@anno 		varchar(4),
@mes  		varchar(2),
@numprovi  	varchar(10)
as
declare @sqlcad varchar(3000)
set @sqlcad='
select a.*,b.*,c.tipocompradesc,d.modoprovidesc,e.monedadescripcion,f.cuentadescripcion,g.empresadescripcion
from [' +@basecompra+ '].dbo.co_cabeceraprovisiones a
inner join [' +@basecompra+ '].dbo.co_detalleprovisiones b on  a.cabprovinumero=b.cabprovinumero 
inner join [' +@basecompra+ '].dbo.co_tipocompra c on  a.tipocompracodigo=c.tipocompracodigo 
inner join [' +@basecompra+ '].dbo.co_modoprovi d on  a.modoprovicod=d.modoprovicod 
inner join [' +@basecompra+ '].dbo.gr_moneda e on a.monedacodigo=e.monedacodigo 
left join  [' +@basecompra+ '].dbo.ct_cuenta f on b.empresacodigo=f.empresacodigo and b.cuentacodigo=f.cuentacodigo
inner join  [' +@basecompra+ '].dbo.co_multiempresas g on a.empresacodigo=g.empresacodigo
where 
	a.cabproviano='''+@anno+''' and 
	a.cabprovimes=''' +@mes+ ''' and
	a.cabprovinumero like ''' +@numprovi+ ''''
exec(@sqlcad)
--select * from campos2012.dbo.ct_cabcomprob2012 where cabcomprobnprovi='37665' 
--exec co_RepComprobCompra_rpt 'mmjserver','aliterm','2008','1','6'
GO
