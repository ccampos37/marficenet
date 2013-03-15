SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_registroventas_rpt    fecha de la secuencia de comandos: 19/12/2007 02:57:45 p.m. ****

drop       Proc ct_registroventas_rpt
exec XX_registroventas_rpt 'planta_casma','01','2008','1','030,031,032,033,034,035,','70%74%76%77%49%','401100,401113,','75%','76%77%','74%'


*/

CREATE    Proc [xx_registroventas_rpt](

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
@sql varchar(8000),@sqlvar1 varchar(8000),
@CADASIENTOSPLAN   VARCHAR(1000),
@CADCTASPLANCOMP VARCHAR(2000),
@CADCTASIGV      VARCHAR(1000),
@CADCTASFLETE    VARCHAR(500),
@CADCTASOTROS    VARCHAR(500),
@CADCTASDEVOL    VARCHAR(500)
Set @CADASIENTOSPLAN='('+dbo.fn_ArmaCriterio(@ASIENTOSPLAN,',','')+')'
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','b.cuentacodigo')+')'
Set @CADCTASIGV ='('+dbo.fn_ArmaCriterio(@CTASIGV,',','F.cuentacodigo')+')'
Set @CADCTASFLETE='('+dbo.fn_ArmaCriterio(@CTASFLETE,'%','F.cuentacodigo')+')'
Set @CADCTASOTROS='('+dbo.fn_ArmaCriterio(@CTASOTROS,'%','F.cuentacodigo')+')'
Set @CADCTASDEVOL='('+dbo.fn_ArmaCriterio(@CTASDEVOL,'%','F.cuentacodigo')+')'


set @sql=' select cuentacodigo,
valorafecto=case when '+@CADCTASPLANCOMP + ' then 
            detcomprobhaber-detcomprobdebe else 0 end,
               * from  ['+@base+'].dbo.ct_cabcomprob'+@anno+' a 
   inner join ['+@base+'].dbo.ct_detcomprob'+@anno+' b on a.empresacodigo=b.empresacodigo and
         a.cabcomprobnumero=b.cabcomprobnumero and a.subasientocodigo=b.subasientocodigo
   where a.empresacodigo='''+@empresa+''' and A.cabcomprobmes='+@mes +' and 
           A.asientocodigo IN '+@CADASIENTOSPLAN+''

execute(@sql)


/*
Set @sqlvar=''+
'SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
  A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,documentocodigo=isnull(A.documentocodigo,''''),
  tdserie=isnull(A.documentocodigo,'''')+left(isnull(A.detcomprobnumdocumento,''''),3),isnull(o.operaciondocumentoanulado,0),
  T.documentodescripcion, detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),A.detcomprobfechaemision,
baseimpgrab=Isnull((Select case when sum(F.detcomprobhaber-f.detcomprobdebe)>0 then sum(F.detcomprobhaber-f.detcomprobdebe) 
       else sum(F.detcomprobdebe-f.detcomprobhaber) * -1 end end),0) 
   FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F Where A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento And
        F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and '+@CADCTASPLANCOMP + ' Group By F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,
        F.detcomprobnumdocumento),0) , 
baseimpnograb=Isnull((Select isnull((case when isnull(Z.cabcomprobgrabada,0)=0 then case when sum(F.detcomprobhaber-F.detcomprobdebe)>0 then 
  sum(F.detcomprobhaber-F.detcomprobdebe) else sum(F.detcomprobdebe-F.detcomprobhaber) * -1 end 
  end),0) FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F Where  A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	 a.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento And
         F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and  '+ @CADCTASPLANCOMP +
        ' Group By F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0),	            
 montoinafecto=(select case a.plantillaasientoinafecto when ''1'' then case when sum(f.detcomprobhaber-f.detcomprobdebe)>0 then 
    sum(f.detcomprobhaber-f.detcomprobdebe) else sum(f.detcomprobhaber-f.detcomprobdebe)*-1 end else 0 end 
    from ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F   where a.empresacodigo=f.empresacodigo and A.cabcomprobmes=f.cabcomprobmes and 
          A.cabcomprobnumero=f.cabcomprobnumero and A.asientocodigo=f.asientocodigo and A.subasientocodigo=f.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento
          and F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and  '+@CADCTASPLANCOMP +' group by F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento) , 
igvimpgrab=ISNULL(( SELECT top 1 isnull((case when isnull(Z.cabcomprobgrabada,0)=1 then 
    case when F.detcomprobhaber>0 then F.detcomprobhaber else F.detcomprobdebe * -1 end end),0)         	
  	FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	      A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and 
              A.detcomprobnumdocumento=F.detcomprobnumdocumento and F.detcomprobauto=0 and '+@CADCTASIGV+'),0),
igvimpnograb=ISNULL(( SELECT top 1  isnull((case when isnull(Z.cabcomprobgrabada,0)=0 then
    case when F.detcomprobhaber>0 then F.detcomprobhaber else F.detcomprobdebe * -1 end end),0)
        FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F WHERE A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	      A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and 
              A.detcomprobnumdocumento=F.detcomprobnumdocumento and F.detcomprobauto=0 and  '+@CADCTASIGV+'),0),
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
        analiticocodigo,documentocodigo,monedacodigo,detcomprobnumdocumento,detcomprobfechaemision,
        plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobtipocambio,operacioncodigo,
        debe=sum(detcomprobdebe),haber=sum(detcomprobhaber),detcomprobusshaber=sum(detcomprobusshaber),
           detcomprobussdebe=sum(detcomprobussdebe) from ['+@base+'].dbo.ct_detcomprob'+@anno+' a
 where detcomprobauto=0 and A.asientocodigo IN '+@CADASIENTOSPLAN+' AND (A.cuentacodigo like ''12%'' OR A.cuentacodigo like ''49%'')
 group by empresacodigo,cabcomprobmes,cabcomprobnumero,asientocodigo,subasientocodigo,
          analiticocodigo,documentocodigo,monedacodigo,detcomprobnumdocumento,detcomprobnumdocumento,A.detcomprobfechaemision,
          plantillaasientoinafecto,tipdocref,detcomprobnumref,detcomprobtipocambio,operacioncodigo ) as A
   WHERE   a.empresacodigo='''+@empresa+''' and A.cabcomprobmes='+@mes +''' and 
           A.asientocodigo IN '+@CADASIENTOSPLAN+' 


*/
GO
