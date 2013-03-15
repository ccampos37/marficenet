SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute al_repotransferencias_rep 'ziyaz','01/05/2009','31/05/2009','01','04','%%'

drop proc al_repotransferencias_rep
*/


CREATE    procedure [al_repotransferencias_rep]

@base varchar(50),
@fini varchar(10),
@ffin varchar(10),
@Almacen1 varchar(2),
@Almacen2 varchar(2),
@transaccion varchar(2)

as
declare @ncadena varchar(4000)
declare @tr varchar(2)
declare @anulado varchar(1)
set @tr='TR'
SET @anulado='A'
set @ncadena='
	select caalma,tadescri,clienterazonsocial,a.catipotransf,a.canrotransf,deitem,carftdoc,carfndoc,catd,canumdoc,catipmov,cafecdoc,
	       decantid,decanref1,decodigo,adescri ,cacodmov ,tt_descri,DECODREF,DECANREF
	from ['+@base+'].dbo.movalmcab a inner join ['+@base+'].dbo.movalmdet
	     on caalma=dealma and catd=detd and canumdoc=denumdoc
    left join ['+@base+'].dbo.tabtransa on catipmov+cacodmov=tt_tipmov+tt_codmov
	inner join ['+@base+'].dbo.maeart on decodigo=acodigo
    inner join ['+@base+'].dbo.tabalm t on caalma=taalma
    left join ['+@base+'].dbo.cp_proveedor on cacodpro=clientecodigo
    inner join 
    ( select catipotransf,canrotransf from ['+@base+'].dbo.movalmcab where 
    catipotransf+canrotransf in 
    ( select distinct catipotransf+canrotransf  from  ['+@base+'].dbo.movalmcab  
 	      where cafecdoc>='''+@fini+''' and cafecdoc<='''+@ffin+''' and 
	      catipotransf='''+@tr+''' and casitgui<>'''+@anulado+''' and 
          caalma like  '''+@almacen1+'''  and cacodmov like '''+@transaccion+'''and catipmov=''S'' 
     ) and catipmov=''I'' and caalma like  '''+@almacen2+''' 
     ) z
     on a.catipotransf+a.canrotransf=z.catipotransf+z.canrotransf
    where decantid > 0 and ( caalma like  '''+@almacen1+''' or catipmov=''I'' and caalma like  '''+@almacen2+''' )
     order by a.catipotransf,a.canrotransf,catipmov desc,caalma,deitem'

execute(@ncadena)
---execute al_repotransferencias_rep 'mmjserver','01/11/2006','03/11/2006'
GO
