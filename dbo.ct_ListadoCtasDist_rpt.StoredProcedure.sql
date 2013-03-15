SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_ListadoCtasDist_rpt
*/
CREATE   proc [ct_ListadoCtasDist_rpt]
(  
	@base 		varchar(50),
        @empresa        varchar(2),
	@cuentacodigo 	varchar(20)
)
as
Declare @sqlcad	varchar(2000)	
set @sqlcad='SELECT A.cuentacodigo, A.cuentadescripcion, 
		B.distribucioncargo, B.distribucionabono, B.distribucionporcen
		FROM ['  +@base+ '].dbo.ct_cuenta A, [' +@base+ '].dbo.ct_distribucion B
		WHERE A.cuentacodigo = B.cuentacodigo AND
                a.empresacodigo ='''+@empresa+''' and 
		A.cuentacodigo LIKE ''' +@cuentacodigo+ '%''
		order by 1'
exec(@sqlcad)
GO
