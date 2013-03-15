SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [al_transformacion_rpt]
@base varchar(50),
@fini varchar(10),
@ffin varchar(10)
as
declare @ncadena varchar(1000)
declare @tr varchar(2)
declare @anulado varchar(1)
set @tr='TR'
SET @anulado='A'
set @ncadena='
	select tadescri,catipotransf,canrotransf,deitem,carftdoc,carfndoc,caalma,catd,canumdoc,catipmov,cafecdoc,
	       decantid,decanref1,decodigo,adescri 
	from ['+@base+'].dbo.movalmcab inner join ['+@base+'].dbo.movalmdet
	     on caalma=dealma and catd=detd and canumdoc=denumdoc
	inner join ['+@base+'].dbo.maeart
             on decodigo=acodigo
        inner join ['+@base+'].dbo.tabalm
             on caalma=taalma
	where cafecdoc>='''+@fini+''' and cafecdoc<='''+@ffin+''' and 
	catipotransf='''+@tr+''' and casitgui<>'''+@anulado+'''
	order by caalma,carftdoc,carfndoc,catipotransf,canrotransf,deitem,catipmov'
execute(@ncadena)
---execute al_repotransferencias_rep 'green','01/11/2006','03/11/2006'
GO
