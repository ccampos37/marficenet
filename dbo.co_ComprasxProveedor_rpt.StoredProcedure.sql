SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [co_ComprasxProveedor_rpt]
@base varchar(50),
@empresa varchar(2),
@periodo varchar(4),
@proveedor varchar(11)='%%',
@tipo integer=0
as
declare @sql varchar(4000)
set @sql=''
if @tipo=1 set @sql=@sql+ 'select clienteruc,clienterazonsocial,mes,total=sum(total ) from  ( '
   set @sql=@sql + ' select mes=right(''00'' + ltrim(str(cabprovimes)),2)+'' - ''+ dbo.fn_DescripcionMes( cabprovimes),
   proveedorcodigo,clienteruc,clienterazonsocial,a.cabprovinumero,A.cabprovifchdoc,A.documetocodigo,
   c.tdocumentodescripcion,a.monedacodigo,cabprovinumdoc=dbo.fn_FormatoNumDoc(A.cabprovinumdoc),
   totref= ( Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)*         
	       Isnull( ( Case When A.monedacodigo=''01'' then 0
                     Else (A.cabprovitotal-A.cabprovitotigv) end )
                  ,0) ,
   tipocambioventa=Case When A.monedacodigo=''01'' then 0 else d.tipocambioventa end ,
   Total=( Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)*         
	       Isnull( ( Case When A.monedacodigo=''01'' then (A.cabprovitotal-A.cabprovitotigv)
                     Else (A.cabprovitotal-A.cabprovitotigv)  * d.tipocambioventa end )
                  ,0)
   from '+@base+'.dbo.co_cabeceraprovisiones a
   inner join '+@base+'.dbo.cp_proveedor b on a.proveedorcodigo=b.clientecodigo
   inner join ['+@Base+'].dbo.cp_tipodocumento C on  A.documetocodigo =C.tdocumentocodigo   
   inner join ['+@Base+'].dbo.ct_tipocambio d
       on Case When upper(C.tdocumentotipo)=''A'' then 
               cabprovifechdocref Else A.cabprovifchdoc End
               =d.tipocambiofecha 
   inner join ['+@Base+'].dbo.co_modoprovi e on A.modoprovicod=e.modoprovicod      
   where empresacodigo='''+@empresa +''' and cabproviano='''+@periodo+''' 
         and  isnull(e.modoproviregcom,0)=1 and A.documetocodigo not in (''02'',''16'') '
if @proveedor<>'%%' set @sql=@sql + ' and a.proveedorcodigo='''+@proveedor +''' ' 
if @tipo=1 set @sql=@sql + ' ) z group by clienteruc, clienterazonsocial,mes '
 
execute(@sql)
/*
IES=case when  A.tipocompracodigo = ''64'' or A.tipocompracodigo = ''65'' then 
             Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv  
                    Else A.cabprovitotigv  * B.tipocambioventa end ),0)
             
         Else 0 End,
ImpRta=case when  A.tipocompracodigo = ''64'' or A.tipocompracodigo = ''65'' then 
           Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotinaf  
                    Else A.cabprovitotinaf  * B.tipocambioventa end ),0)            
         Else 0 End,
Total=(Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)*         
	      Isnull(
                (Case When A.monedacodigo=''01'' then A.cabprovitotal
                  Else A.cabprovitotal  * B.tipocambioventa end ),0),
*/
GO
