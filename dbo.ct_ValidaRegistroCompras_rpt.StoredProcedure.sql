SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE                        Proc [ct_ValidaRegistroCompras_rpt]
--Declare 
@BASE         	VARCHAR(100),
@BASECOMPRA 	VARCHAR(50),
@SERVER			VARCHAR(50),
@ANNO        	VARCHAR(4),
@MES          	VARCHAR(2),  
@ASIENTOSPLAN  VARCHAR(500),
@CTASPLANCOMP 	VARCHAR(500),
@CTASIGV      	VARCHAR(200),
@CTASIES      	VARCHAR(100),
@CTASRENTA    	VARCHAR(100)
AS
Declare 
@sqlvar varchar(8000),@sqlvar1 varchar(8000),
@CADASIENTOSPLAN   VARCHAR(1000),
@CADCTASPLANCOMP VARCHAR(2000),
@CADCTASIGV      VARCHAR(1000),
@CADCTASIES      VARCHAR(500),
@CADCTASRENTA    VARCHAR(500)
Set @CADASIENTOSPLAN='('+dbo.fn_ArmaCriterio(@ASIENTOSPLAN,',','')+')'
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','F.cuentacodigo')+')'
Set @CADCTASIGV ='('+dbo.fn_ArmaCriterio(@CTASIGV,',','F.cuentacodigo')+')'
Set @CADCTASIES='('+dbo.fn_ArmaCriterio(@CTASIES,',','F.cuentacodigo')+')'
Set @CADCTASRENTA='('+dbo.fn_ArmaCriterio(@CTASRENTA,',','F.cuentacodigo')+')'
/**Ejecuta el Store del Reg. Compras Provisión**/
exec marfice.dbo.co_registrocompra_rpt @BASECOMPRA,@BASE,@BASECOMPRA,@SERVER,@SERVER,@SERVER,@ANNO,@MES,'Desa3'
If Exists(select name from tempdb..sysobjects where name='##tmpregcompraconta')
Begin
	Exec('Set Nocount on
           drop table '+'##tmpregcompraconta   
          Set Nocount off' )
End 
Set @sqlvar=''+
'SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
        A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,
        documentocodigo=isnull(A.documentocodigo,''''),
        T.documentodescripcion,
        detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),
        A.detcomprobfechaemision,
		baseimpgrab=Isnull((Select isnull((case when isnull(Z.cabcomprobgrabada,0)=1 
                   then case when sum(F.detcomprobdebe)>0 then sum(F.detcomprobdebe) 
                             else sum(F.detcomprobhaber) * -1 end end),0)
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
                   then case when sum(F.detcomprobdebe)>0 then sum(F.detcomprobdebe) 
                             else sum(F.detcomprobhaber) * -1 end end),0)                
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
                                isnull((case when sum(F.detcomprobdebe)>0 then sum(F.detcomprobdebe) 
                                       else sum(F.detcomprobhaber) * -1 end ),0)
                      Else 0 end
          
        			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
        			WHERE
			          F.plantillaasientoinafecto=1 and 	F.detcomprobauto=0 and 
			          A.cabcomprobmes=F.cabcomprobmes and 
				      A.cabcomprobnumero=F.cabcomprobnumero and 
				      A.asientocodigo=F.asientocodigo and 
				      A.subasientocodigo=F.subasientocodigo and 
			          A.documentocodigo=F.documentocodigo and 
			          A.detcomprobnumdocumento=F.detcomprobnumdocumento   
         Group By F.cabcomprobnumero,F.asientocodigo,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento,F.plantillaasientoinafecto),0), 
       	igvimpgrab=ISNULL(( SELECT top 1 
         	       		isnull((case when isnull(Z.cabcomprobgrabada,0)=1 
                   			then case when F.detcomprobdebe>0 then F.detcomprobdebe 
                            	 else F.detcomprobhaber * -1 end end),0)         	
       		
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
                                    then case when F.detcomprobdebe>0 then F.detcomprobdebe 
                                    else F.detcomprobhaber * -1 end end),0)
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE	   		
			            A.cabcomprobmes=F.cabcomprobmes and 
				        A.cabcomprobnumero=F.cabcomprobnumero and 
				        A.asientocodigo=F.asientocodigo and 
				        A.subasientocodigo=F.subasientocodigo and 
			            A.documentocodigo=F.documentocodigo and             
			            F.detcomprobauto=0 and  '+@CADCTASIGV+'),0),
        IES=ISNULL(( SELECT top 1
         	          isnull(case when F.detcomprobdebe>0 then F.detcomprobdebe 
                             else F.detcomprobhaber * -1 end,0)         	       		
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE
				   		A.cabcomprobmes=F.cabcomprobmes and 
				      	A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and 
				      	A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and 
			          	A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
			            F.detcomprobauto=0 and '+@CADCTASIES+'),0),
		RENTA=ISNULL(( SELECT top 1
         	          isnull(case when F.detcomprobdebe>0 then F.detcomprobdebe 
                             else F.detcomprobhaber * -1 end,0)         	       		
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE
				   		A.cabcomprobmes=F.cabcomprobmes and 
				      	A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and 
				      	A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and 
			          	A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
			            F.detcomprobauto=0 and '+@CADCTASRENTA+'),0),
		  tipdocref=isnull(A.tipdocref,''''),detcomprobnumref=isnull(A.detcomprobnumref,''''),A.detcomprobtipocambio,		
        MontoReferencia=case when A.monedacodigo=''02'' then  
                           isnull((case when A.detcomprobussdebe>0 then A.detcomprobussdebe * -1  
                                   else A.detcomprobusshaber  end),0) 
                           else 0 end,A.detcomprobnlibro,
		  NumAuxiliar=Z.cabcomprobnprovi
			
		into ##tmpregcompraconta 
		
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
   	(A.cuentacodigo like ''421%'' ) and 
      A.analiticocodigo=G.analiticocodigo and 
      A.asientocodigo=H.asientocodigo and 
      A.documentocodigo=T.documentocodigo and         
      A.detcomprobauto=0 and A.cabcomprobmes='+@mes
exec(@sqlvar+@sqlvar1)
GO
