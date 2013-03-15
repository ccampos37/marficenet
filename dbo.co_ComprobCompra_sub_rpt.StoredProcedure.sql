SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [co_ComprobCompra_sub_rpt]
--Declare
@basecompra varchar(50),
@empresa varchar(2),
@anno 		varchar(4),
@mes  		varchar(2),
@numprovi  	varchar(10)
as
declare @sqlcad varchar(3000)
set @sqlcad=' select a.empresacodigo,a.cabcomprobanno,a.cabcomprobmes,a.cabcompronumero ,b.cuentacodigo,c.cuentadescripcion,b.monedacodigo,c.monedasimbolo ,
   montoref=case when b.monedacodigo=''01'' then (detcomprobdebe+detcomprobhaber) else detcomprobussdebe+detcomprobusshaber end ,detcomporobglosa,
   cabcomprobnprovi from ['+@basecompra+ '].dbo.ct_cabcomprob'+@anno+' a
inner join ['+@basecompra+ '].dbo.ct_detcomprob'+@anno+' b on a.empresacodigo+a.cabcomprobnumero=b.empresacodigo+b.cabcomprobnumero
left join ['+@basecompra+ '].dbo.gr_moneda c on b.monedacodigo=c.monedacodigo 
where a.cabcomprobanno='''+@anno+''' and a.cabcomprobmes=''' +@mes+ ''' and	a.cabcomprobnumero='''+@numprovi+ ''''

print(@sqlcad)
--select * from campos2012.dbo.gr_moneda 
-- select * from aliterm2012.dbo.ct_cabcomprob2012
 
--exec co_ComprobCompra_sub_rpt 'campos2012','2012','10','37665'
GO
