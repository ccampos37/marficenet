SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute al_transferenciasxarticulo_rpt 'newgreen','26/03/2008','26/03/2008'
drop proc al_repotransferencias_rep

select * from ##transferencias

*/

CREATE        procedure [al_transferenciasxarticulo_rpt]

@base varchar(50),
@fini varchar(10),
@ffin varchar(10)
as
declare @ncadena varchar(4000)
declare @tr varchar(2)
declare @anulado varchar(1)
set @tr='TR'
SET @anulado='A'
drop table ##transferencias
set @ncadena='(select cacodpro,catipotransf,canrotransf,
                      cantidaproveedor=sum(decantid),num=count(*)
                into ##transferencias
	           from ['+@base+'].dbo.movalmcab inner join ['+@base+'].dbo.movalmdet
	                      on caalma=dealma and catd=detd and canumdoc=denumdoc
                   where cafecdoc>='''+@fini+''' and cafecdoc<='''+@ffin+''' and 
	                catipotransf='''+@tr+''' and casitgui<>'''+@anulado+''' 
                        and decantid > 0 and catipmov=''S'' 
                   group by cacodpro,catipotransf,canrotransf
                   having count(*) <=2 ) '
execute(@ncadena)

set @ncadena='select distinct z.*,decodigo,e.clienterazonsocial,c.aunidad,
                descripcion=case when isnull(decodref,'''')='''' then c.amarca else d.amarca end,
                decantid,decanref from ['+@base+'].dbo.movalmcab a 
                inner join ['+@base+'].dbo.movalmdet b on caalma=dealma and catd=detd and canumdoc=denumdoc
                inner join ['+@base+'].dbo.maeart c on b.decodigo=c.acodigo
                left join ['+@base+'].dbo.maeart d on b.decodref=d.acodigo
                inner join (select distinct zz.*,codigo=b.decodigo 
                            from ['+@base+'].dbo.movalmcab a inner join ['+@base+'].dbo.movalmdet b 
                                      on caalma=dealma and catd=detd and canumdoc=denumdoc
                              inner join ##transferencias zz 
                             on a.catipotransf+a.canrotransf=zz.catipotransf+zz.canrotransf
			               where a.decantid > 0 and catipmov=''S'' 
                            ) as z  
                inner join ['+@base+'].dbo.cp_proveedor e on z.cacodpro=e.clientecodigo
            where a.catipmov=''I'' '

execute(@ncadena)
GO
