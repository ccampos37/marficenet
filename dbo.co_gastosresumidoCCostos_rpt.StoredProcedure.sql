SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      proc [co_gastosresumidoCCostos_rpt]
@Base nvarchar(20),
@Ano  varchar(4), 
@Fechaini   varchar(10)='01/01/2007',
@fechafin   varchar(10)='31/12/2007',
@tipo      int=0,
@cuenta     varchar(20)='%%',
@codigo     varchar(11)='%%',
@entidad  varchar(11)='%%',
@centrocosto varchar(10)='%%',
@oficina varchar(10)='%%',
@detraccion int=0
as 
declare
@SqlCad varchar(4000)
set @SqlCad=N'select z.*,
soles =case when z.monedacodigo=''02'' then
            z.cabprovitipcambio*z.detprovitotal  
         else  z.detprovitotal end,
dolares =case when z.monedacodigo=''01'' then
            z.detprovitotal/z.cabprovitipcambio  
         else  z.detprovitotal end
from 
(
   Select  a.cabprovioficina,j.vendedornombres,
       b.centrocostocodigo,i.centrocostodescripcion,
       A.cabprovinumero,A.cabprovinumaux,
       proveedorcodigo,cabprovirznsoc =a.cabprovirznsoc,
       cabentidadrznsoc= h.entidadrazonsocial,
       b.entidadcodigo,A.modoprovicod,D.modoprovidesc,
       A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,
       A.cabprovifchconta,A.monedacodigo,A.cabprovimes,
       cabprovitipcambio=case when A.cabprovitipcambio=0 then 1 else A.cabprovitipcambio end ,
       B.gastoscodigo,
       gastosdescripcion=B.gastoscodigo+'' ''+C.gastosdescripcion,
       detproviimpbru=Case When G.tdocumentotipo=''A'' then  B.detproviimpbru * -1 else B.detproviimpbru end,
       detproviimpigv=Case When G.tdocumentotipo=''A'' then  B.detproviimpigv * -1 else B.detproviimpigv end, 
       detproviimpina=Case When G.tdocumentotipo=''A'' then  B.detproviimpina * -1 else B.detproviimpina end, 
       detprovitotal= Case When G.tdocumentotipo=''A'' then  B.detprovitotal * -1 else B.detprovitotal end
   from ['+@Base+'].dbo.co_cabeceraprovisiones A 
       inner join ['+@Base+'].dbo.co_detalleprovisiones  B
                on A.cabprovinumero=B.cabprovinumero
       LEFT join ['+@Base+'].dbo.co_gastos C 
         on  B.gastoscodigo =c.gastoscodigo 
       inner join ['+@Base+'].dbo.co_modoprovi D     
         on  A.modoprovicod=D.modoprovicod       
       left join  ['+@Base+'].dbo.cp_proveedor E 
          on  A.proveedorcodigo=e.clientecodigo  
       left join ['+@Base+'].dbo.cp_tipodocumento G 
          on  a.documetocodigo=g.tdocumentocodigo  
       left join  ['+@Base+'].dbo.ct_entidad h 
          on  b.entidadcodigo=h.entidadcodigo 
       left join  ['+@Base+'].dbo.ct_centrocosto i 
          on  b.centrocostocodigo=i.centrocostocodigo 
       left join  ['+@Base+'].dbo.cp_oficina j 
          on  a.cabprovioficina=j.vendedorcodigo 
) as z 
Where z.gastoscodigo like '''+@cuenta+''' 
 and z.centrocostocodigo like '''+@centrocosto+'''
 and z.cabprovioficina like '''+@oficina+'''
 and z.cabprovimes >=month('''+@Fechaini+''') and z.cabprovimes<=month('''+@FechaFin+''')
 and z.cabproviano >=year('''+@fechaini+''') and z.cabproviano<=year('''+@fechafin+''') '
execute(@sqlcad) 
--execute co_gastosresumidoCCostos_rpt 'acuaplayacasma','2007','01/01/2007','30/06/2007',1,'%%','%%','%%','%%','%%',1
GO
