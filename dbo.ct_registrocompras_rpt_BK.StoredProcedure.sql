SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**Analiticos**/
CREATE   PROC [ct_registrocompras_rpt_BK](
@BASE         VARCHAR(100),
@ANNO         VARCHAR(4),
@MES          VARCHAR(2),  
@ASIENTOSPLAN   VARCHAR(500),
@CTASPLANCOMP VARCHAR(500),
@CTASIGV      VARCHAR(500))
as 
Declare 
@sqlvar varchar(8000)
Set @sqlvar=''+
'SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
        A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,
        documentocodigo=isnull(A.documentocodigo,''''),
        T.documentodescripcion,
        detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),
        A.detcomprobfechaemision,
	    C.baseimpgrab,C.baseimpnograb,
          montoinafecto=isnull((SELECT TOP 1
          Case when F.plantillaasientoinafecto=1 then 
             isnull((case when F.detcomprobdebe>=0 then F.detcomprobdebe 
                             else F.detcomprobhaber * -1 end ),0)
          Else 0 end
          
       FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
       WHERE
          F.plantillaasientoinafecto=1 and 	F.detcomprobauto=0 and 
          A.cabcomprobmes=F.cabcomprobmes and 
	      A.cabcomprobnumero=F.cabcomprobnumero and 
	      A.asientocodigo=F.asientocodigo and 
	      A.subasientocodigo=F.subasientocodigo and 
          A.documentocodigo=F.documentocodigo and 
          A.detcomprobnumdocumento=F.detcomprobnumdocumento),0)
          , 
          D.igvimpgrab,D.igvimpnograb,
          tipdocref=isnull(A.tipdocref,''''),detcomprobnumref=isnull(A.detcomprobnumref,''''),A.detcomprobtipocambio,	
          MontoReferencia=case when A.monedacodigo=''02'' then  
                           isnull((case when A.detcomprobussdebe>0 then A.detcomprobussdebe * -1  
                                   else A.detcomprobusshaber  end),0) 
                           else 0 end       
        
       FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,
      (SELECT 
	   baseimpgrab=isnull((case when isnull(b.cabcomprobgrabada,0)=1 
                   then case when A.detcomprobdebe>0 then A.detcomprobdebe 
                             else A.detcomprobhaber * -1 end end),0),
	   baseimpnograb=isnull((case when isnull(b.cabcomprobgrabada,0)=0 
                   then case when A.detcomprobdebe>0 then A.detcomprobdebe 
                             else A.detcomprobhaber * -1 end end),0),
	   A.*
		  
	   FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,['+@base+'].dbo.ct_cabcomprob'+@anno+' B
     
	   WHERE
			A.cabcomprobmes=B.cabcomprobmes and 
			A.cabcomprobnumero=B.cabcomprobnumero and 
			A.asientocodigo=B.asientocodigo and 
			A.subasientocodigo=B.subasientocodigo and 
        	A.asientocodigo IN '+@ASIENTOSPLAN+' AND 
        	A.detcomprobauto=0 and  A.plantillaasientoinafecto=0 and '+
			@CTASPLANCOMP +' ) as C,
       	( SELECT 
         	igvimpgrab=isnull((case when isnull(b.cabcomprobgrabada,0)=1 
                   then case when A.detcomprobdebe>0 then A.detcomprobdebe 
                             else A.detcomprobhaber * -1 end end),0),
         	igvimpnograb=isnull((case when isnull(b.cabcomprobgrabada,0)=0 
                   then case when A.detcomprobdebe>0 then A.detcomprobdebe 
                             else A.detcomprobhaber * -1 end end),0),
       		A.*
       	 FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,['+@base+'].dbo.ct_cabcomprob'+@anno+' B
       	 WHERE
	   		A.cabcomprobmes=B.cabcomprobmes and 
	   		A.cabcomprobnumero=B.cabcomprobnumero and 
	   		A.asientocodigo=B.asientocodigo and 
	   		A.subasientocodigo=B.subasientocodigo and 
            A.asientocodigo IN '+@ASIENTOSPLAN+' AND 
            A.detcomprobauto=0 and '+ 
	  		@CTASIGV+' ) As D,
            ['+@base+'].dbo.v_analiticoentidad G, 
            ['+@base+'].dbo.ct_asiento H,
            ['+@base+'].dbo.gr_documento T         	        	
	WHERE		
    	A.asientocodigo IN '+@ASIENTOSPLAN+' AND 
   	   (A.cuentacodigo like ''421%'' ) and 
        A.analiticocodigo=G.analiticocodigo and 
        A.asientocodigo=H.asientocodigo and 
        A.documentocodigo=T.documentocodigo and 
        A.cabcomprobmes=C.cabcomprobmes and 
	    A.cabcomprobnumero=C.cabcomprobnumero and 
	    A.asientocodigo=C.asientocodigo and 
	    A.subasientocodigo=C.subasientocodigo and 
        A.documentocodigo=C.documentocodigo and 
        A.detcomprobnumdocumento=C.detcomprobnumdocumento and 
        A.cabcomprobmes=D.cabcomprobmes and 
	    A.cabcomprobnumero=D.cabcomprobnumero and 
	    A.asientocodigo=D.asientocodigo and 
	    A.subasientocodigo=D.subasientocodigo and 
        A.documentocodigo=D.documentocodigo and 
        A.detcomprobnumdocumento=D.detcomprobnumdocumento and  
        t.documentoregcompras=1 AND   
        A.detcomprobauto=0 and A.cabcomprobmes='+@mes
exec(@sqlvar)
GO
