SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc co_listacuenta_rpt
execute co_listacuenta_rpt 'aliterm','aliterm','%%','2008',0,'01/01/2008','31/01/2008','606100%'
*/
CREATE       Proc [co_listacuenta_rpt]
   @BaseCompra varchar(50),
   @BaseConta  varchar(50),
   @empresa    varchar(2),
   @Prove      varchar(11), 	
   @Ano        varchar(4), 
   @flagfecha  varchar(1),
   @Fechaini   VARCHAR(10),
   @fechafin   varchar(10),
   @cuenta     varchar(20)
As
Declare 
       @SqlCad varchar(5000)
Set  @SqlCad='
Select i.empresadescripcion,b.entidadcodigo,h.entidadrazonsocial,A.cabprovinumero,A.cabprovinumaux,
   A.cabprovimes,A.proveedorcodigo,A.cabprovirznsoc,a.tipocompracodigo,A.modoprovicod,
   D.tipocompradesc,
   A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,
   A.cabprovifchconta,A.monedacodigo,A.cabprovitipcambio,
   B.cuentacodigo,C.cuentadescripcion,B.centrocostocodigo,   
   detproviimpbru=Case When G.tdocumentotipo=''A'' then  B.detproviimpbru * -1 else B.detproviimpbru end,
   detproviimpigv=Case When G.tdocumentotipo=''A'' then  B.detproviimpigv * -1 else B.detproviimpigv end, 
   detproviimpina=Case When G.tdocumentotipo=''A'' then  B.detproviimpina * -1 else B.detproviimpina end, 
   detprovitotal= Case When G.tdocumentotipo=''A'' then  B.detprovitotal * -1 else B.detprovitotal end
from ['+@BaseCompra+'].dbo.co_cabeceraprovisiones a
     inner join ['+@BaseCompra+'].dbo.co_detalleprovisiones B on A.cabprovinumero=B.cabprovinumero  
     inner join ['+@BaseConta+'].dbo.ct_cuenta C on b.empresacodigo=c.empresacodigo and B.cuentacodigo  =c.cuentacodigo   
     inner join ['+@BaseCompra+'].dbo.co_tipocompra D on A.tipocompracodigo=D.tipocompracodigo      
     inner join ['+@BaseCompra+'].dbo.cp_tipodocumento G  on A.documetocodigo  =G.tdocumentocodigo 
     left join ['+@BaseCompra+'].dbo.ct_entidad h  on b.entidadcodigo  =h.entidadcodigo 
     inner join ['+@BaseCompra+'].dbo.co_multiempresas i  on a.empresacodigo=i.empresacodigo 
Where A.tipocompracodigo like '''+@Prove+''' and 
      c.cuentacodigo like '''+@cuenta+'''  and
      a.empresacodigo like '''+@empresa+''' and 
      (1='+@flagfecha+' or A.cabprovimes >=month('+@Fechaini+') and A.cabprovimes<=month('+@FechaFin+')
		and a.cabproviano>=year('''+@fechafin+''') and a.cabproviano<=year('''+@fechafin+''') ) '        
execute(@SqlCad)
GO
