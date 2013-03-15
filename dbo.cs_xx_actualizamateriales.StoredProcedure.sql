SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_actualizamateriales 'planta10','planta_casma','01/01/2008','31/01/2008'
select deprecio,decantid,* from movalmdet where decodigo='10813'
delete al_cierresmensuales
*/
CREATE  PROC [cs_xx_actualizamateriales]
@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10)
as
declare  @sql varchar(2000)
set @sql=' select c.estructuranumerolinea,y=sum(deprecio*decantid) from '+@basedestino+'.dbo.movalmdet a 
   inner join '+@basedestino+'.dbo.movalmcab b
         on a.dealma=b.caalma and a.detd=catd and denumdoc=canumdoc
   inner join '+@basedestino+'.dbo.ct_centrocosto c
         on dealma=c.empresacodigo and a.decencos=c.centrocostocodigo
   inner join '+@basedestino+'.dbo.tabalm on dealma=taalma
   where cafecdoc between '''+@fechaini+''' and '''+@fechafin+''' 
   and casitgui<>''A''  group by estructuranumerolinea '
EXECUTE(@sql)
GO
