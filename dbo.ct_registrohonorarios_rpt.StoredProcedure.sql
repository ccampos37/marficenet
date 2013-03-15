SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_registrohonorarios_rpt    fecha de la secuencia de comandos: 19/12/2007 02:54:21 p.m. *****
DROP Proc ct_registrohonorarios_rpt
exec ct_registrohonorarios_rpt 'aliterm2012','01','2012','10','064,','63%64%65%','4017200,','404200,','%%'
select * from gr_documento

*/
CREATE             Proc [ct_registrohonorarios_rpt]
(
@BASE         VARCHAR(100),
@EMPRESA      VARCHAR(2),
@ANNO         VARCHAR(4),
@MES          VARCHAR(2),  
@ASIENTOSPLAN   VARCHAR(500),
@CTASPLANCOMP VARCHAR(500),
@CTASIES      VARCHAR(100),
@CTASRENTA    VARCHAR(100),
@CODANALITICO VARCHAR(20))
AS
Declare 
@sqlvar varchar(8000),@sqlvar1 varchar(8000),
@CADASIENTOSPLAN   VARCHAR(1000),
@CADCTASPLANCOMP VARCHAR(2000),
@CADCTASIES      VARCHAR(500),
@CADCTASRENTA    VARCHAR(500)
Set @CADASIENTOSPLAN='('+dbo.fn_ArmaCriterio(@ASIENTOSPLAN,',','')+')'
Set @CADCTASPLANCOMP='('+dbo.fn_ArmaCriterio(@CTASPLANCOMP,'%','F.cuentacodigo')+')'
Set @CADCTASIES='('+dbo.fn_ArmaCriterio(@CTASIES,',','F.cuentacodigo')+')'
Set @CADCTASRENTA='('+dbo.fn_ArmaCriterio(@CTASRENTA,',','F.cuentacodigo')+')'

set @sqlvar='declare @sistemamonista int
Set @sistemamonista=(select top 1 sistemamonista from '+@base+'.dbo.ct_sistema )'
execute(@sqlvar)    

Set @sqlvar=''+
'SELECT A.cabcomprobmes,A.cabcomprobnumero,A.subasientocodigo,A.asientocodigo,H.asientodescripcion, 
        A.analiticocodigo,G.entidadruc,G.entidadrazonsocial,A.monedacodigo,
        documentocodigo=isnull(A.documentocodigo,''''),
        documentodescripcion,
        detcomprobnumdocumento=isnull(A.detcomprobnumdocumento,''''),
        A.detcomprobfechaemision,
        importeprovision=Isnull((Select case when sum(F.detcomprobdebe)>0 then sum(F.detcomprobdebe) 
                             else sum(F.detcomprobhaber) * -1 end FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
        Where A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and A.empresacodigo = F.empresacodigo And
	      A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and 
              A.detcomprobnumdocumento=F.detcomprobnumdocumento And
        F.asientocodigo IN '+@CADASIENTOSPLAN+' /*AND F.detcomprobauto=0*/ and '+@CADCTASPLANCOMP +
        ' Group By F.cabcomprobnumero,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0),	            
 	impuestorenta=ISNULL(( SELECT top 1
         	          isnull(case when F.detcomprobdebe>0 then F.detcomprobdebe 
                             else F.detcomprobhaber * -1 end,0)
       	  			FROM ['+@BASE+'].dbo.ct_detcomprob'+@ANNO+' F
       	  			WHERE  a.empresacodigo=f.empresacodigo and A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
				      	A.asientocodigo=F.asientocodigo and A.subasientocodigo=F.subasientocodigo and 
			          	A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento and              
			            /*F.detcomprobauto=0 and */ '+@CADCTASRENTA+'),0),
		  tipdocref=isnull(A.tipdocref,''''),detcomprobnumref=isnull(A.detcomprobnumref,''''),A.detcomprobtipocambio,		
/*          MontoReferencia=isnull((select case when A.monedacodigo=''02'' then  
                             (case when sum(f.detcomprobussdebe) >0 then sum(f.detcomprobussdebe) 
                                   else 0  end) else 0 end  
                      FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' F
                      Where a.empresacodigo=f.empresacodigo and  A.cabcomprobmes=F.cabcomprobmes and A.cabcomprobnumero=F.cabcomprobnumero and 
	                 A.subasientocodigo=F.subasientocodigo and A.documentocodigo=F.documentocodigo and A.detcomprobnumdocumento=F.detcomprobnumdocumento And
                         F.asientocodigo IN '+@CADASIENTOSPLAN+' AND F.detcomprobauto=0 and '+@CADCTASPLANCOMP +
                       ' Group By F.cabcomprobnumero,F.subasientocodigo,F.documentocodigo,F.detcomprobnumdocumento),0),
*/
                     A.detcomprobnlibro                 
     FROM ['+@base+'].dbo.ct_detcomprob'+@anno+' A 
           inner join ['+@base+'].dbo.ct_cabcomprob'+@anno+' Z 
           on a.empresacodigo=z.empresacodigo and A.cabcomprobmes=Z.cabcomprobmes and A.cabcomprobnumero=Z.cabcomprobnumero and 
	   	      A.asientocodigo=Z.asientocodigo and  A.subasientocodigo=Z.subasientocodigo '
Set @sqlvar1=' inner join ['+@base+'].dbo.ct_asiento H  on  A.asientocodigo=H.asientocodigo 
               inner join  ['+@base+'].dbo.gr_documento t on a.documentocodigo=t.documentocodigo  
               left join ['+@base+'].dbo.v_analiticoentidad G on  A.analiticocodigo=G.analiticocodigo  
  	WHERE  A.asientocodigo IN '+@CADASIENTOSPLAN+' AND (A.cuentacodigo like ''424%'' ) and 
           A.empresacodigo like '''+@empresa + ''' and A.analiticocodigo like '''+@CODANALITICO + ''' and  
           A.detcomprobauto=0 and A.cabcomprobmes='+@mes

execute(@sqlvar+@sqlvar1)


---select * from gremco.dbo.gr_documento
GO
