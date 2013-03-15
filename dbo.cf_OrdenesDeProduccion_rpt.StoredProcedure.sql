SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  procedure [cf_OrdenesDeProduccion_rpt]
(
	@Servidor 	varchar(50),
	@base varchar(50)
)
as
declare @sqlcad varchar(3000)
set @sqlcad='
select 
ordennumero,colorcodigo,tallascodigo,
ordencantdiacorte,ordencantsemanacorte,ordencantcorte,
ordentotcorte,(ordencantcorte/ordentotcorte)*100,
ordencanthabilitado,(ordencanthabilitado/ordentotcorte)*100,
ordencantdiaconfeccion,ordencantmesconfeccion,
ordencantconfeccionprimera,ordencantconfeccionsegunda+ordencantsinconfeccionservicios
ordentotconfeccion,
ordencantconfeccionprimera,ordencantconfeccionsegunda,
ordencantserviciosprimera,
ordencantdiaacabado,ordencantmesacabado,
ordencantacabado
from [' +@Servidor+ '].[' +@base+ '].dbo.cf_detalleordendefabricacion'''
exec(@sqlcad)
--select * from comprasprueba.dbo.co_detprovi2003 where cabprovimes=1
--exec co_RepComprobCompra_rpt 'server_tc','camtex_tinto','2003','4','3086'
GO
