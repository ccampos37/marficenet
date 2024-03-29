SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Objeto:  procedimiento almacenado dbo.ct_registroventas_rpt    fecha de la secuencia de comandos: 19/12/2007 02:57:45 p.m. ****

drop       Proc ct_registroventas_rpt

exec [ct_Libroregistroventas_rpt] 'planta_casma','03','2013','01','030,031,035,','70%74%75%76%77%49%','4011100,','78%','76%77%','74%'


*/
ALTER Proc [ct_Libroregistroventas_rpt](
--Declare 
@BASE         VARCHAR(100),
@empresa      varchar(2),
@ANNO         VARCHAR(4),
@MES          VARCHAR(2),  
@ASIENTOSPLAN VARCHAR(500),
@CTASPLANCOMP VARCHAR(500),
@CTASIGV      VARCHAR(200),
@CTASFLETE	  VARCHAR(100),
@CTASOTROS    VARCHAR(100),
@CTASDEVOL    VARCHAR(100) )
AS

Declare 
@sqlvar varchar(8000),@sqlvar1 varchar(8000),
@CADASIENTOSPLAN   VARCHAR(1000),
@CADCTASPLANCOMP VARCHAR(2000),
@CADCTASIGV      VARCHAR(1000),
@CADCTASFLETE    VARCHAR(500),
@CADCTASOTROS    VARCHAR(500),
@CADCTASDEVOL    VARCHAR(500)
Set @CADASIENTOSPLAN='('+dbo.fn_ArmaCriterio(@ASIENTOSPLAN,',','')+')'
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','a.cuentacodigo')+')'
Set @CADCTASIGV ='('+dbo.fn_ArmaCriterio(@CTASIGV,',','a.cuentacodigo')+')'
Set @CADCTASFLETE='('+dbo.fn_ArmaCriterio(@CTASFLETE,'%','a.cuentacodigo')+')'
Set @CADCTASOTROS='('+dbo.fn_ArmaCriterio(@CTASOTROS,'%','a.cuentacodigo')+')'
Set @CADCTASDEVOL='('+dbo.fn_ArmaCriterio(@CTASDEVOL,'%','a.cuentacodigo')+')'

Set @sqlvar=''+
'SELECT operaciondocumentoanulado=isnull(o.operaciondocumentoanulado,0),A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,
  H.asientodescripcion, A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,g.identidadcodigo,A.monedacodigo,aaaa='''+@ANNO+''',
  documentocodigo=isnull(A.documentocodigo,''''),tdserie=left(isnull(A.detcomprobnumdocumento,''''),4),
  documentodescripcion=A.documentocodigo+'' ''+T.documentodescripcion, 
  detcomprobnumdocumento=dbo.fn_formatoNumdoc(a.detcomprobnumdocumento),A.detcomprobfechaemision,detcomprobfechavencimiento,
  detcomprobtipocambio,montoreferencia=abs(detcomprobussdebe-detcomprobusshaber),detcomprobfecharef,
  documentoreferencia=tipdocref+''      ''+dbo.fn_formatoNumdoc(detcomprobnumref),
  f.baseimponible,f.igvimpgrab,f.montoinafecto,f.FLETE,f.OTROS,f.DEVOL   ,detcomprobnumref
  FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' a
  inner join 
  ( select empresacodigo,cabcomprobmes,cabcomprobnumero,asientocodigo,documentocodigo,detcomprobnumdocumento,
          baseimponible=sum(case when  plantillaasientoinafecto=0 and '+@CADCTASPLANCOMP + ' then (detcomprobdebe-detcomprobhaber) * -1 else 0 end),
          igvimpgrab   =sum(case when  plantillaasientoinafecto=0 and '+@CADCTASIGV+'        then (detcomprobdebe-detcomprobhaber) * -1 else 0 end),
          montoinafecto=sum(isnull(case when plantillaasientoinafecto=1 then (detcomprobdebe-detcomprobhaber )* -1 else 0 end,0)) ,
          FLETE=sum(case when  plantillaasientoinafecto=0 and '+@CADCTASFLETE+' then (detcomprobdebe-detcomprobhaber )* -1 else 0 end) ,
          OTROS=sum(case when  plantillaasientoinafecto=0 and '+@CADCTASOTROS+' then (detcomprobdebe-detcomprobhaber )* -1 else 0 end) ,
          DEVOL=sum(case when  plantillaasientoinafecto=0 and '+@CADCTASDEVOL+' then (detcomprobdebe-detcomprobhaber )* -1 else 0 end) 
    FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' a
    Where a.empresacodigo='''+@empresa+''' and A.cabcomprobmes='+@mes+' and detcomprobauto=0 
          and A.asientocodigo IN '+@CADASIENTOSPLAN+' AND NOT (A.cuentacodigo like ''12%'' OR A.cuentacodigo like ''49%'') 
   GROUP BY empresacodigo,cabcomprobmes,cabcomprobnumero,asientocodigo,documentocodigo,detcomprobnumdocumento
  ) f on a.empresacodigo=f.empresacodigo and A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero 
          and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento
 inner join ['+@base+'].dbo.ct_operacion O on a.operacioncodigo=O.operacioncodigo
 left join ['+@base+'].dbo.v_analiticoentidad G on A.analiticocodigo=G.analiticocodigo
 inner join ['+@base+'].dbo.ct_asiento H ON A.asientocodigo=H.asientocodigo
 inner join ['+@base+'].dbo.gr_documento T on A.documentocodigo=T.documentocodigo 
 where detcomprobauto=0 and A.asientocodigo IN '+@CADASIENTOSPLAN+' AND (A.cuentacodigo like ''12%'' OR A.cuentacodigo like ''49%'') '

execute(@sqlvar)




