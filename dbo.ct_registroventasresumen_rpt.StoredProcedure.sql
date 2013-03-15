SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_registroventasresumen_rpt    fecha de la secuencia de comandos: 19/12/2007 03:06:55 p.m. ******/
/**Analiticos*
drop PROC ct_registroventasresumen_rpt
*/
CREATE   PROC [ct_registroventasresumen_rpt](
@BASE         VARCHAR(100),
@empresa      varchar(2),
@ANNO         VARCHAR(4),
@MES          VARCHAR(2),  
@ASIENTOSPLAN VARCHAR(500),
@CTASPLANCOMP VARCHAR(500),
@CTASIGV      VARCHAR(500),
@NOMBREPC     VARCHAR(50))
as 
/*SET @BASE='CONTAPRUEBA'
SET @ANNO='2002'
SET @MES='9'
SET @ASIENTOSPLAN=' (''070'') '
SET @CTASPLANCOMP=' (A.cuentacodigo like ''70%'' or A.cuentacodigo like ''74%'' or A.cuentacodigo like ''75%'' or A.cuentacodigo like ''76%'' or A.cuentacodigo like ''77%'') '
SET @CTASIGV=' (A.cuentacodigo like ''401110'') '
*/
Declare 
@sqlvar varchar(8000)
--IF EXISTS (SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME='##GGG')
--  DROP TABLE  [TEMPDB].DBO.##GGG  
--GO
Set @sqlvar='Set nocount on  
SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
        A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,
        documentocodigo=isnull(A.documentocodigo,''''),
	tdserie=isnull(A.documentocodigo,'''')+left(isnull(A.detcomprobnumdocumento,''''),3),
        T.documentodescripcion,
        detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),
        A.detcomprobfechaemision,
	    C.baseimpgrab,C.baseimpnograb,
          montoinafecto=isnull((SELECT TOP 1
          Case when F.plantillaasientoinafecto=1 then 
             isnull((case when F.detcomprobhaber>=0 then F.detcomprobhaber 
                             else F.detcomprobdebe * -1 end ),0)
          Else 0 end
          
       FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
       WHERE
          F.plantillaasientoinafecto=1 and F.detcomprobauto=0 and 
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
                           isnull((case when A.detcomprobusshaber>0 then A.detcomprobusshaber * -1  
                                   else A.detcomprobussdebe  end),0) 
                           else 0 end       
       INTO ##GGG 
        
       FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,
      (SELECT 
	   baseimpgrab=isnull((case when isnull(b.cabcomprobgrabada,0)=1 
                   then case when A.detcomprobhaber>0 then A.detcomprobhaber 
                             else A.detcomprobdebe * -1 end end),0),
	   baseimpnograb=isnull((case when isnull(b.cabcomprobgrabada,0)=0 
                   then case when A.detcomprobhaber>0 then A.detcomprobhaber 
                             else A.detcomprobdebe * -1 end end),0),
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
                   then case when A.detcomprobhaber>0 then A.detcomprobhaber 
                             else A.detcomprobdebe * -1 end end),0),
         	igvimpnograb=isnull((case when isnull(b.cabcomprobgrabada,0)=0 
                   then case when A.detcomprobhaber>0 then A.detcomprobhaber 
                             else A.detcomprobdebe * -1 end end),0),
       		A.*
       	 FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A,['+@base+'].dbo.ct_cabcomprob'+@anno+' B
       	 WHERE 		a.empresacodigo=b.empresacodigo and
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
   	   (A.cuentacodigo like ''121%'' ) and 
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
        A.detcomprobauto=0 and a.empresacodigo='''+@empresa+'''  and A.cabcomprobmes='+@mes+' 
Set nocount off '   
Set nocount on
exec(@sqlvar)
Set nocount off
Select * from  ##GGG 
--PRINT(@SQLVAR)
--EXEC ct_registroventasresumen_rpt 'CONTAPRUEBA','2002','9',' (''070'') ','(A.cuentacodigo like ''70%'' or A.cuentacodigo like ''74%'' or A.cuentacodigo like ''75%'' or A.cuentacodigo like ''76%'' or A.cuentacodigo like ''77%'') ',' (A.cuentacodigo like ''401110'') ','DESARROLLO3'
--drop table ##GGG
SET QUOTED_IDENTIFIER OFF
GO
