SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Drop Proc [dbo].[co_listagastosdetallado_rpt]
*/
CREATE          Proc [co_listagastosdetallado_rpt]
   @Base varchar(50),
   @Ano        varchar(4), 
   @Fechaini   varchar(10),
   @fechafin   varchar(10),
   @tipo       varchar(1)='1', 
   @cuenta     varchar(10)='%%', 
   @codigo     varchar(11)='%%',
   @entidad  varchar(11)='%%',
   @centrocosto  varchar(10)='%',
   @oficina  varchar(3)='%%',
   @detraccion int=0,
   @Empresa varchar(2)='%%'
As
Declare 
       @SqlCad varchar(4000)
Set  @SqlCad='
     Select distinct empresadescripcion,A.cabprovinumero,A.cabprovinumaux,a.cabprovimes,
       proveedorcodigo =case when '+@tipo+'=1  then  a.proveedorcodigo else h.entidadcodigo end,
       cabprovirznsoc =case when '+@tipo+'=1   then  a.cabprovirznsoc else h.entidadrazonsocial end,
       b.entidadcodigo,
       clienteruc=case when '+@tipo+'=1  then  a.proveedorcodigo else h.entidadcodigo end,
       A.modoprovicod,
       D.modoprovidesc,
       A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,
       A.cabprovifchconta,A.monedacodigo,
       cabprovitipcambio=case when A.cabprovitipcambio=0 then 1 else A.cabprovitipcambio end ,
       B.gastoscodigo,C.gastosdescripcion,
       a.cabprovioficina,j.vendedornombres,
       b.centrocostocodigo,i.centrocostodescripcion, 
       detproviimpbru=Case When G.tdocumentotipo=''A'' then  B.detproviimpbru * -1 else B.detproviimpbru end,
       detproviimpigv=Case When G.tdocumentotipo=''A'' then  B.detproviimpigv * -1 else B.detproviimpigv end, 
       detproviimpina=Case When G.tdocumentotipo=''A'' then  B.detproviimpina * -1 else B.detproviimpina end, 
       detprovitotal= Case When G.tdocumentotipo=''A'' then  B.detprovitotal * -1 else B.detprovitotal end
     from 
       ['+@Base+'].dbo.co_cabeceraprovisiones A 
       inner join ['+@Base+'].dbo.co_detalleprovisiones B
         on A.cabprovinumero=B.cabprovinumero
       LEFT join ['+@Base+'].dbo.co_gastos C 
         on  B.gastoscodigo =c.gastoscodigo 
       inner join ['+@Base+'].dbo.co_modoprovi D     
         on  A.modoprovicod=D.modoprovicod       
       left join  ['+@Base+'].dbo.cp_proveedor E 
          on  A.proveedorcodigo=e.clientecodigo  
       inner join  ['+@Base+'].dbo.cp_tipodocumento G 
          on  a.documetocodigo=g.tdocumentocodigo  
       left join  ['+@Base+'].dbo.ct_entidad h 
          on  b.entidadcodigo=h.entidadcodigo  
       left join  ['+@Base+'].dbo.ct_centrocosto i
          on  b.empresacodigo=i.empresacodigo and b.centrocostocodigo=i.centrocostocodigo  
       left join  ['+@Base+'].dbo.cp_oficina j
          on  a.cabprovioficina=j.vendedorcodigo  
       left join  ['+@Base+'].dbo.co_multiempresas k
          on  a.empresacodigo=k.empresacodigo  
   Where   
       B.gastoscodigo like '''+rtrim(@cuenta)+'%''
       and a.proveedorcodigo like '''+rtrim(@codigo)+'%''
       and B.entidadcodigo like '''+rtrim(@entidad)+'%''
       and b.centrocostocodigo like '''+rtrim(@centrocosto)+'%''
       and a.cabprovioficina like '''+rtrim(@oficina)+'%''
       and a.cabprovifchconta between '''+@Fechaini+'''and '''+@FechaFin+'''
 	   and a.empresacodigo like '''+@Empresa+''' '
If @detraccion='1' set @sqlcad=@sqlcad + ' and c.habilitadodetraccion=''1'' '
execute(@SqlCad)
--EXECUTE co_listagastosdetallado_rpt 'gremco','2008','01/08/2007','31/08/2007','1','%%','%%','%%','%%','%%','0','30'
--select * from docsa.dbo.co_cabprovi2007 where cabprovimes>=month('01/08/2007') and cabprovimes<=month('31/08/2007')
-- select * from invbrisa.dbo.co_detprovi2006 where isnull(gastoscodigo,'00')='00'
---update invbrisa.dbo.co_detprovi2006 set gastoscodigo='00' where isnull(gastoscodigo,'00')='00'
GO
