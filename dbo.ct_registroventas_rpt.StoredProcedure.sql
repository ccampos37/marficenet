SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_registroventas_rpt    fecha de la secuencia de comandos: 19/12/2007 02:57:45 p.m. ****

drop       Proc ct_registroventas_rpt

exec ct_registroventas_rpt 'empresax','01','2012','06','030,032,034,','70%74%76%77%49%','4011100,4011101,','75%','76%77%','74%'


*/

CREATE                            Proc [ct_registroventas_rpt](
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
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','F.cuentacodigo')+')'
Set @CADCTASIGV ='('+dbo.fn_ArmaCriterio(@CTASIGV,',','F.cuentacodigo')+')'
Set @CADCTASFLETE='('+dbo.fn_ArmaCriterio(@CTASFLETE,'%','F.cuentacodigo')+')'
Set @CADCTASOTROS='('+dbo.fn_ArmaCriterio(@CTASOTROS,'%','F.cuentacodigo')+')'
Set @CADCTASDEVOL='('+dbo.fn_ArmaCriterio(@CTASDEVOL,'%','F.cuentacodigo')+')'

Set @sqlvar=''+
'SELECT operaciondocumentoanulado=isnull(o.operaciondocumentoanulado,0),A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
  A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,documentocodigo=isnull(A.documentocodigo,''''),
  tdserie=isnull(A.documentocodigo,'''')+left(isnull(A.detcomprobnumdocumento,''''),4),isnull(o.operaciondocumentoanulado,0),
  T.documentodescripcion, detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),A.detcomprobfechaemision,
baseimpgrab=Isnull((Select case when sum(F.detcomprobhaber-f.detcomprobdebe)>0 then sum(F.detcomprobhaber-f.detcomprobdebe) 
       else sum(F.detcomprobdebe-f.detcomprobhaber) * -1 end
   FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F Where A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento And
        F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and f.plantillaasientoinafecto=0 and '+@CADCTASPLANCOMP + ' Group By F.cabcomprobnumero,F.subasientocodigo,F.documentocodigo,
        F.detcomprobnumdocumento),0) , 
baseimpnograb=Isnull((Select case when sum(F.detcomprobhaber-F.detcomprobdebe)>0 then 
      sum(F.detcomprobhaber-F.detcomprobdebe) else sum(F.detcomprobdebe-F.detcomprobhaber) * -1 end
      FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F Where  A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	 A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento And
         F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and f.plantillaasientoinafecto=0  and  '+ @CADCTASPLANCOMP +
        ' Group By F.cabcomprobnumero,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0),
montoinafecto=isnull((select case when sum(f.detcomprobhaber-f.detcomprobdebe)>0 then 
    sum(f.detcomprobhaber-f.detcomprobdebe) else sum(f.detcomprobdebe-f.detcomprobhaber)*-1 end  
    from ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F   where a.empresacodigo=f.empresacodigo and A.cabcomprobmes=f.cabcomprobmes and 
          A.cabcomprobnumero=f.cabcomprobnumero and A.subasientocodigo=f.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento
          and F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and f.plantillaasientoinafecto=1 and  '+@CADCTASPLANCOMP +' group by F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0) , 
igvimpgrab=ISNULL(( SELECT top 1 case when (F.detcomprobhaber-f.detcomprobdebe) >0 then 
                (F.detcomprobhaber-f.detcomprobdebe) else (F.detcomprobdebe-f.detcomprobhaber) * -1 end         	
  	FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	      A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and 
              A.detcomprobnumdocumento=F.detcomprobnumdocumento and F.detcomprobauto=0 and f.plantillaasientoinafecto=0 and '+@CADCTASIGV+'),0),
igvimpnograb=ISNULL(( SELECT top 1 case when (F.detcomprobhaber-f.detcomprobdebe) >0 then 
                (F.detcomprobhaber-f.detcomprobdebe) else (F.detcomprobhaber-f.detcomprobdebe) * -1 end         	
  	FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	      A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and 
              A.detcomprobnumdocumento=F.detcomprobnumdocumento and F.detcomprobauto=0 and f.plantillaasientoinafecto=1 and '+@CADCTASIGV+'),0),
flete=ISNULL(( SELECT top 1 isnull(case when F.detcomprobhaber>0 then F.detcomprobhaber else F.detcomprobdebe * -1 end,0)         	       		
	FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
              A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and 
              A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento and F.detcomprobauto=0 and '+@CADCTASFLETE+'),0),
otros=ISNULL(( SELECT top 1 isnull(case when F.detcomprobhaber>0 then F.detcomprobhaber else F.detcomprobdebe * -1 end,0)         	       		
 		FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE	A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	            A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and 
		    A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
		    F.detcomprobauto=0 and '+@CADCTASOTROS+'),0),
devol=ISNULL(( SELECT top 1 isnull(case when F.detcomprobhaber>0 then F.detcomprobhaber else F.detcomprobdebe * -1 end,0) 
               FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F wHERE A.cabcomprobmes=F.cabcomprobmes and a.cabcomprobnumero=F.cabcomprobnumero and 
   	      A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and 
	      A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
	      F.detcomprobauto=0 and '+@CADCTASDEVOL+'),0),
tipdocref=isnull(A.tipdocref,''''),detcomprobnumref=isnull(A.detcomprobnumref,''''),A.detcomprobtipocambio,		
MontoReferencia=case when A.monedacodigo=''02'' then isnull((case when A.detcomprobusshaber>0 then A.detcomprobusshaber * -1  
                     else A.detcomprobussdebe  end),0) else 0 end,z.cabcomprobnlibro                 
         FROM ['+@base+'].dbo.ct_cabcomprob'+@anno+' Z,['+@base+'].dbo.ct_operacion O, '
Set @sqlvar1=' ['+@base+'].dbo.v_analiticoentidad G, ['+@base+'].dbo.ct_asiento H,['+@base+'].dbo.gr_documento T,
(select empresacodigo,cabcomprobmes,cabcomprobnumero,asientocodigo,subasientocodigo,
        analiticocodigo,a.documentocodigo,monedacodigo,detcomprobnumdocumento,detcomprobfechaemision,
        plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobtipocambio,operacioncodigo,
        debe=sum(detcomprobdebe),haber=sum(detcomprobhaber),detcomprobusshaber=sum(detcomprobusshaber),
           detcomprobussdebe=sum(detcomprobussdebe) from ['+@base+'].dbo.ct_detcomprob'+@anno+' a,['+@base+'].dbo.gr_documento b
 where A.documentocodigo=b.documentocodigo  ----and detcomprobauto=0 
  and A.asientocodigo IN '+@CADASIENTOSPLAN+' AND (A.cuentacodigo like ''12%'' OR A.cuentacodigo like ''49%'') 
---and ((a.detcomprobdebe >= 0 and isnull(b.documentonotacredito,0)=0 ) or (a.detcomprobhaber >= 0 and isnull(b.documentonotacredito,0)=1 ))
 group by empresacodigo,cabcomprobmes,cabcomprobnumero,asientocodigo,subasientocodigo,
          analiticocodigo,a.documentocodigo,monedacodigo,detcomprobnumdocumento,detcomprobnumdocumento,A.detcomprobfechaemision,
          plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobtipocambio,a.operacioncodigo ) as A

   WHERE   a.empresacodigo=z.empresacodigo and A.cabcomprobmes=Z.cabcomprobmes and a.operacioncodigo=o.operacioncodigo and  
	   a.cabcomprobnumero=Z.cabcomprobnumero and A.asientocodigo=Z.asientocodigo and
	   A.subasientocodigo=Z.subasientocodigo and  A.analiticocodigo=G.analiticocodigo and A.asientocodigo=H.asientocodigo and 
        A.documentocodigo=T.documentocodigo and a.empresacodigo='''+@empresa+''' and A.cabcomprobmes='+@mes

execute(@sqlvar+@sqlvar1)
GO
