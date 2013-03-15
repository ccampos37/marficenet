SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Declare 
--Author: Fernando Cossio
CREATE   Proc [co_listagastosresumido_rpt]
   @Base varchar(50),
   @Ano        varchar(4), 
   @Fechaini   Float,
   @fechafin   Float,
   @tipo      int=0,
   @cuenta     varchar(20)='%%',
   @codigo     varchar(11)='%%',
   @entidad  varchar(11)='%%',
   @centrocosto  varchar(10)='%%',
   @oficina  varchar(10)='%%'
As
Declare 
       @XFechaini  varchar(10),
       @XFechaFin  varchar(10),
       @SqlCad varchar(4000)
Set    @XFechaini=cast (@Fechaini as varchar(10))  
Set    @XFechaFin=Cast(@fechafin as varchar(10))
Set  @SqlCad='
 select distinct z.gastoscodigo,z.gastosdescripcion,   
       detimpbrusol =  sum(case when z.monedacodigo=''01'' then detimpbru else round(detimpbru*cabprovitipcambio,2) end),
       detimpbrudol =  sum(case when z.monedacodigo=''02'' then detimpbru else round(detimpbru/cabprovitipcambio,2) end),
       detprovitotal  =  sum(case when z.monedacodigo=''01'' then dettotal else round(dettotal*cabprovitipcambio,2) end )
       from 
   (   Select A.cabprovinumero,A.cabprovinumaux,
       A.cabprovimes,A.proveedorcodigo,A.cabprovirznsoc,A.modoprovicod,
       D.modoprovidesc,
       A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,
       A.cabprovifchconta,A.monedacodigo,
       cabprovitipcambio= case when A.cabprovitipcambio=0 then 1 else A.cabprovitipcambio end,
       B.gastoscodigo,C.gastosdescripcion,   
       detimpbru=Case When G.tdocumentotipo=''A'' then  (B.detproviimpbru+ detproviimpina) * -1 else (B.detproviimpbru+ detproviimpina) end,
       dettotal= Case When G.tdocumentotipo=''A'' then  B.detprovitotal * -1 else B.detprovitotal end
  
  from 
       ['+@Base+'].dbo.co_cabeceraprovisiones A 
       inner join ['+@Base+'].dbo.co_detalleprovisiones B
         on A.cabprovinumero=B.cabprovinumero
       left join ['+@Base+'].dbo.co_gastos C 
         on  B.gastoscodigo =c.gastoscodigo 
       inner join ['+@Base+'].dbo.co_modoprovi D     
         on  A.modoprovicod=D.modoprovicod       
       inner join  ['+@Base+'].dbo.cp_tipodocumento G 
          on  a.documetocodigo=g.tdocumentocodigo  
   Where   
        B.gastoscodigo like '''+@cuenta+''' 
        and b.centrocostocodigo like '''+@centrocosto+'''
        and a.cabprovioficina like '''+@oficina+'''
       and a.cabprovifchconta between '''+@xFechaini+'''and '''+@xFechaFin+'''

 ) as z 
 GROUP BY z.gastoscodigo,z.gastosdescripcion'
execute (@SqlCad)
--EXECUTE co_listagastosresumido_rpt 'green','2006',30700,39800,1,'%%','%%','%%','%%'
GO
