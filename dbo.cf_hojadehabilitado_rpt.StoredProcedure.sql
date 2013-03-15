SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [cf_hojadehabilitado_rpt]
--declare
@base varchar(50),
@numcorte varchar(10)
as
--set @base='sanildefonso'
declare @cadena as varchar(1000)
set @cadena='select A.cortenumero,A.ordennumero,A.colorcodigo,B.colorDescripcion,A.tallascodigo,A.habilitadonumerodepqte,
       		habilitadocantidaddeprendasxpqte
        	from ['+@base+'].dbo.cf_hojadehabilitado A 
	 	inner join ['+@base+'].dbo.cf_colores B
		on A.colorcodigo=B.colorcodigo
		where A.cortenumero = '''+@numcorte+''' 
	  order by habilitadonumerodepqte'
--		order by a.tallascodigo desc,a.colorcodigo asc,a.habilitadonumerodepqte asc'
--habilitadonumerodepqte'		
exec (@cadena)
--print(@cadena)
-- exec cf_hojadehabilitado_rpt 'desarrollo5'
GO
