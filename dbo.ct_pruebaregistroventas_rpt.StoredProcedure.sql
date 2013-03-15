SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE               Proc [ct_pruebaregistroventas_rpt](
--Declare 
@BASE         VARCHAR(100),
@ANNO         VARCHAR(4),
@MES          VARCHAR(2),  
@ASIENTOSPLAN VARCHAR(500),
@CTASPLANCOMP VARCHAR(500),
@CTASIGV      VARCHAR(200),
@CTASFLETE	  VARCHAR(100),
@CTASOTROS    VARCHAR(100))
--@CTASDEVOL    VARCHAR(100) )
AS
Declare 
@sqlvar varchar(8000),@sqlvar1 varchar(8000),
@CADASIENTOSPLAN   VARCHAR(1000),
@CADCTASPLANCOMP VARCHAR(2000),
@CADCTASIGV      VARCHAR(1000),
@CADCTASFLETE    VARCHAR(500),
@CADCTASOTROS    VARCHAR(500)
--@CADCTASDEVOL    VARCHAR(500)
Set @CADASIENTOSPLAN='('+dbo.fn_ArmaCriterio(@ASIENTOSPLAN,',','')+')'
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','F.cuentacodigo')+')'
Set @CADCTASIGV ='('+dbo.fn_ArmaCriterio(@CTASIGV,',','F.cuentacodigo')+')'
--Set @CADCTASIES='('+dbo.fn_ArmaCriterio(@CTASIES,',','F.cuentacodigo')+')'
Set @CADCTASFLETE='('+dbo.fn_ArmaCriterio(@CTASFLETE,'%','F.cuentacodigo')+')'
Set @CADCTASOTROS='('+dbo.fn_ArmaCriterio(@CTASOTROS,'%','F.cuentacodigo')+')'
--Set @CADCTASDEVOL='('+dbo.fn_ArmaCriterio(@CTASDEVOL,'%','F.cuentacodigo')+')'
Set @sqlvar=''+
'SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
        A.analiticocodigo,
        entidadruc=case when left(A.analiticocodigo,8)=''88888888'' then A.detcomprobruc else G.entidadruc end,
        entidadrazonsocial=case when left(A.analiticocodigo,8)=''88888888'' then A.detcomprobglosa else G.entidadrazonsocial end,        
        A.monedacodigo,
        documentocodigo=isnull(A.documentocodigo,''''),
        tdserie=isnull(A.documentocodigo,'''')+left(isnull(A.detcomprobnumdocumento,''''),3),
        T.documentodescripcion,
        detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),
        A.detcomprobfechaemision,
		baseimpgrab=Isnull((Select isnull((case when isnull(Z.cabcomprobgrabada,0)=1 
                   then case when sum(F.detcomprobhaber)>0 then sum(F.detcomprobhaber) 
                             else sum(F.detcomprobdebe) * -1 end end),0)
        FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
        Where  
		A.cabcomprobmes=F.cabcomprobmes and 
				      A.cabcomprobnumero=F.cabcomprobnumero and 
				      A.asientocodigo=F.asientocodigo and 
				      A.subasientocodigo=F.subasientocodigo and 
			          A.documentocodigo=F.documentocodigo and 
			          A.detcomprobnumdocumento=F.detcomprobnumdocumento And
        F.asientocodigo IN '+@CADASIENTOSPLAN+' AND 
        F.detcomprobauto=0 and  F.plantillaasientoinafecto=0 and '+
		@CADCTASPLANCOMP + 
        ' Group By F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0) , 
        baseimpnograb=Isnull((Select isnull((case when isnull(Z.cabcomprobgrabada,0)=0 
                   then case when sum(F.detcomprobhaber)>0 then sum(F.detcomprobhaber) 
                             else sum(F.detcomprobdebe) * -1 end end),0)                
		FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
        Where  
		A.cabcomprobmes=F.cabcomprobmes and 
				      A.cabcomprobnumero=F.cabcomprobnumero and 
				      A.asientocodigo=F.asientocodigo and 
				      A.subasientocodigo=F.subasientocodigo and 
			          A.documentocodigo=F.documentocodigo and 
			          A.detcomprobnumdocumento=F.detcomprobnumdocumento And
        F.asientocodigo IN '+@CADASIENTOSPLAN+' AND 
        F.detcomprobauto=0 and  F.plantillaasientoinafecto=0 and '+                  
		@CADCTASPLANCOMP +
        ' Group By F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0),	            
        montoinafecto=isnull((SELECT TOP 1
                      Case when F.plantillaasientoinafecto=1 then 
                                isnull((case when F.detcomprobhaber>=0 then F.detcomprobhaber 
                                       else F.detcomprobdebe * -1 end ),0)
                      Else 0 end
          
        			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
        			WHERE
			          	F.plantillaasientoinafecto=1 and 	F.detcomprobauto=0 and 
			          	A.cabcomprobmes=F.cabcomprobmes and 
				      	A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and 
				      	A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and '
						 	+@CADCTASPLANCOMP+ ' AND
			          	A.detcomprobnumdocumento=F.detcomprobnumdocumento),0), 
       	igvimpgrab=ISNULL(( SELECT top 1 
         	       		isnull((case when isnull(Z.cabcomprobgrabada,0)=1 
                   			then case when F.detcomprobhaber>0 then F.detcomprobhaber 
                            	 else F.detcomprobdebe * -1 end end),0)         	
       		
       	 			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	 			WHERE	   		
			            A.cabcomprobmes=F.cabcomprobmes and 
				        A.cabcomprobnumero=F.cabcomprobnumero and 
				        A.asientocodigo=F.asientocodigo and 
				        A.subasientocodigo=F.subasientocodigo and 
			            A.documentocodigo=F.documentocodigo and 
			            F.detcomprobauto=0 and '+@CADCTASIGV+'),0),
        igvimpnograb=ISNULL(( SELECT top 1          	
         	                  isnull((case when isnull(Z.cabcomprobgrabada,0)=0 
                                    then case when F.detcomprobhaber>0 then F.detcomprobhaber 
                                    else F.detcomprobdebe * -1 end end),0)
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE	   		
			            A.cabcomprobmes=F.cabcomprobmes and 
				        A.cabcomprobnumero=F.cabcomprobnumero and 
				        A.asientocodigo=F.asientocodigo and 
				        A.subasientocodigo=F.subasientocodigo and 
			            A.documentocodigo=F.documentocodigo and             
			            F.detcomprobauto=0 and  '+@CADCTASIGV+'),0),
        flete=ISNULL(( SELECT top 1
         	          isnull(case when F.detcomprobhaber>0 then F.detcomprobhaber 
                             else F.detcomprobdebe * -1 end,0)         	       		
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE
				   		A.cabcomprobmes=F.cabcomprobmes and 
				      	A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and 
				      	A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and 
			          	A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
			            F.detcomprobauto=0 and '+@CADCTASFLETE+'),0),
		otros=ISNULL(( SELECT top 1
         	          isnull(case when F.detcomprobhaber>0 then F.detcomprobhaber 
                             else F.detcomprobdebe * -1 end,0)         	       		
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE
				   		A.cabcomprobmes=F.cabcomprobmes and 
				      	A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and 
				      	A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and 
			          	A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
			            F.detcomprobauto=0 and '+@CADCTASOTROS+'),0),
		  tipdocref=isnull(A.tipdocref,''''),detcomprobnumref=isnull(A.detcomprobnumref,''''),A.detcomprobtipocambio,		
          MontoReferencia=case when A.monedacodigo=''02'' then  
                           isnull((case when A.detcomprobusshaber>0 then A.detcomprobusshaber * -1  
                                   else A.detcomprobussdebe  end),0) 
                           else 0 end,A.detcomprobnlibro                 
       FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,['+@base+'].dbo.ct_cabcomprob'+@anno+' Z, '
Set @sqlvar1='  	          	
            ['+@base+'].dbo.v_analiticoentidad G, 
            ['+@base+'].dbo.ct_asiento H,
            ['+@base+'].dbo.gr_documento T         	        	
	WHERE
		A.cabcomprobmes=Z.cabcomprobmes and 
	   A.cabcomprobnumero=Z.cabcomprobnumero and 
	   A.asientocodigo=Z.asientocodigo and 
	   A.subasientocodigo=Z.subasientocodigo and 		
	   A.asientocodigo IN '+@CADASIENTOSPLAN+' AND 
   	(A.cuentacodigo like ''121%'' ) and 
   	A.analiticocodigo=G.analiticocodigo and 
      A.asientocodigo=H.asientocodigo and 
      A.documentocodigo=T.documentocodigo and         
      A.detcomprobauto=0 and A.cabcomprobmes='+@mes
execute(@sqlvar+@sqlvar1)
--exec ct_pruebaregistroventas_rpt 'CONTAPRUEBA','2003','1','070,071,072,073,074,','70%74%75%76%77%','401110,','75%','76%'
GO
