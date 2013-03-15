SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

select * from ziyaz.dbo.movalmdet

execute [al_TransResumenAnual_rpt] 'ziyaz','03','02','01/01/2012','31/01/2012'

*/



CREATE procedure [al_TransResumenAnual_rpt]
@base as varchar(50),
@empresa char(2),
@puntovta as varchar(2),
@fechaini as varchar(10),
@fechafin as varchar(10)
as
declare @cadena as nvarchar(4000)
declare @a as char(1)

set @cadena='SELECT d.puntovtacodigo,puntovtadescripcion,cacodmov,TT_DESCRI,aaaa=year(cafecdoc),
             mm=right(''00''+ltrim(str(month(cafecdoc))),2)+'' ''+dbo.fn_DescripcionMes(month(cafecdoc)),
             tipo=case when catipmov=''I'' then '' INGRESOS '' else '' SALIDAS '' end,
             deprecio=decantid*deprecio FROM ['+@base+'].dbo.MOVALMCAB a 
             inner join ['+@base+'].dbo.movalmdet b on caalma+catd+canumdoc=dealma+detd+denumdoc 
             inner join ['+@base+'].dbo.tabtransa c on a.cacodmov =c.TT_CODMOV
             inner join ['+@base+'].dbo.tabalm d on a.caalma=d.taalma
             inner join ['+@base+'].dbo.vt_puntoventa e on d.puntovtacodigo=e.puntovtacodigo
      	     WHERE a.empresacodigo='''+@empresa+''' and cafecdoc between '''+@fechaini + ''' and '''+@fechafin+''' 
      	           and CASITGUI =''V''and  estadocosto=1 '
if @puntovta<>'%%' set @cadena=@cadena+' and d.puntovtacodigo='''+@puntovta+''' '
		   
execute(@cadena)
GO
