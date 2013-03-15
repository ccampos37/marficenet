SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [vt_rankingArticulosxmes] 'ziyaz','02','01','01/09/2011','30/09/2011','##jck','%%'

*/


CREATE PROCEDURE [vt_rankingArticulosxmes]  

@base varchar(50),    
@empresa varchar(2), 
@moneda varchar(2),   
@fecdesde varchar(10),    
@fechasta varchar(10),
@computer varchar(50)='##jck',
@cliente varchar(11)='%%'

    
AS    
    
DECLARE @sensql nvarchar (4000)    
SET @sensql = N'If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
    Drop Table ['+@computer+'] 

    select tipo=1,productocodigo,pedidotipofac,a.pedidofechafact,dato=''CANTIDAD'',
         monto= (case when tdocumentotipo=''A'' then -1 else 1 end )* abs(b.detpedcantpedida)
         into '+@computer+'
         FROM ['+@base+'].dbo.vt_pedido a  
            inner JOIN ['+@base+'].dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero     
            inner JOIN ['+@base+'].dbo.ct_tipocambio d ON a.pedidofechafact=d.tipocambiofecha   
            inner JOIN ['+@base+'].dbo.cc_tipodocumento c ON a.pedidotipofac=c.tdocumentocodigo    
            WHERE a.empresacodigo like '''+@empresa+'''  AND a.pedidofechafact  BETWEEN '''+@fecdesde+''' and '''+@fechasta+''' 
                  and isnull(pedidocondicionfactura,0)=0 '
if @cliente<>'%%' set @sensql=@sensql + ' and a.clientecodigo='''+@cliente + ''' '
set @sensql=@sensql +' union all
     select tipo=2,productocodigo,pedidotipofac,a.pedidofechafact,dato=''IMPORTES'', 
            Monto = (case when tdocumentotipo=''A'' then -1 else 1 end )* 
                     case when '''+@moneda+'''=''01''  then 
                           case when a.pedidomoneda=''01'' then abs(detpedmontoprecvta-detpedmontoimpto ) else abs((detpedmontoprecvta-detpedmontoimpto )* isnull(tipocambioventa,1)) end
                     else  case when a.pedidomoneda=''02'' then abs(detpedmontoprecvta-detpedmontoimpto ) else abs((detpedmontoprecvta-detpedmontoimpto )/ isnull(tipocambioventa,1)) end
                    end 
           FROM ['+@base+'].dbo.vt_pedido a  
           inner JOIN ['+@base+'].dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero     
           inner JOIN ['+@base+'].dbo.ct_tipocambio d ON a.pedidofechafact=d.tipocambiofecha   
           inner JOIN ['+@base+'].dbo.cc_tipodocumento c ON a.pedidotipofac=c.tdocumentocodigo    
           WHERE a.empresacodigo like '''+@empresa+'''    
               AND a.pedidofechafact  BETWEEN '''+@fecdesde+''' and '''+@fechasta+''' 
               and isnull(pedidocondicionfactura,0)=0  '

if @cliente<>'%%' set @sensql=@sensql + ' and a.clientecodigo='''+@cliente + ''' '
               

execute(@sensql)

set @sensql=' SELECT z.productocodigo,c.adescri,c.afamilia ,dato,
              aamm=case tipo
                      when 6 then ''SALDO''
                      when 5 then ''COSTO''
                      when 4 then '' PRECIO''
                      when 3 then ''  TOTALES '' 
                      else rtrim(str(year(z.pedidofechafact)))+''-''+right(''00''+ltrim(str(month(z.pedidofechafact))),2) 
                   end ,monto  from 
        ( select * from '+@computer+'
         union all
             select tipo=3,productocodigo,''01'','''+@fechasta+''',dato,monto=sum(monto) from '+@computer+' group by productocodigo,dato
         union all
             select distinct tipo=4,a.productocodigo,''01'','''+@fechasta+''',dato=''LISTA'', Monto = isnull(productoprecvta,0) 
                    from ['+@base+'].dbo.listapre1 a inner join '+@computer+' b on a.productocodigo=b.productocodigo
         union all
             select distinct tipo=5,productocodigo,''01'','''+@fechasta+''',dato=''PROMEDIO'',Monto = isnull(SMMNPREUNI,0) 
                    from '+@computer+' b 
                   left join ( select a.smcodigo, a.SMMNPREUNI from ['+@base+'].dbo.al_movresmes a
                               inner join ( select empresacodigo,smcodigo, aaaamm=max(SMMESPRO) from ['+@base+'].dbo.al_movresmes a
                                            where a.empresacodigo like '''+@empresa+''' group by empresacodigo,smcodigo
                                           ) zz on a.empresacodigo+a.smcodigo+smmespro=zz.empresacodigo+zz.smcodigo+aaaamm WHERE A.puntovtacodigo=''03''
                              ) z on b.productocodigo=z.smcodigo
         union all
             select distinct tipo=6, codigo,''01'','''+@fechasta+''',dato=''ALMACEN'', Monto = sum(isnull(disponible,0)) from
					( select zz.*,Disponible=case when (zz.stock-zz.Pedido+zz.Receta) <0 then 0 else (zz.stock-zz.Pedido+zz.Receta) end from 
	                         ( select a.stalma as Cod_alm,t.tadescri as Almacen,a.stcodigo as Codigo,a.stskdis as Stock,
	                                 sum(isnull(detpedcantpedida,0)) as Pedido, floor(isnull(c.stskdis,0)) as Receta
                               from ['+@base+'].dbo.stkart a 
	                           left join ( SELECT a.almacencodigo,a.productocodigo,pedidonumero,detpedcantpedida=detpedcantpedida-sum(isnull(decantid,0))
                                           from ['+@base+'].dbo.v_almacenyventas a 
                                           left join ['+@base+'].dbo.vt_modoventa c on a.modovtacodigo=c.modovtacodigo
                                           where isnull(c.modovtacanje,0)<>1 and a.almacencodigo=''13'' 
                                           group by a.almacencodigo,a.productocodigo,pedidonumero,detpedcantpedida
                                         ) b on a.stalma=b.almacencodigo and  a.stcodigo=b.productocodigo
	                            left join ( select stalma,codkit,stskdis=min(stskdis) from 
	                                              ( select stalma,codkit,codart,stskdis=case when isnull(stskdis,0)=0 then 0 else (isnull(stskdis,0))/canart end
	                                                from  ['+@base+'].dbo.kits b  
	                                                left join  ['+@base+'].dbo.stkart c on codart=stcodigo where stalma=''13'' 
                                                  ) z  	group by stalma,codkit
                                          ) c on a.stalma=c.stalma and a.stcodigo=c.codkit
	                             inner join ['+@base+'].dbo.tabalm t on a.stalma=t.taalma		
                                 where a.stalma=''13'' and t.consolidado<>(''1'') group by a.stalma,t.tadescri,a.stcodigo,c.stskdis,a.stskdis
                             ) zz  
                     ) z1 where codigo in ( select distinct productocodigo from '+@computer+'  ) group by codigo
         ) z
        inner JOIN ['+@base+'].dbo.MAEART c ON z.productocodigo=c.acodigo    
        where  isnull(AFSTOCK,1)=1 and isnull(monto,0) <> 0 '    
  
execute (@sensql)    
   
/*
AND isnull(ALINEA,0)=301 and z.productocodigo=''102363''    
*/
GO
