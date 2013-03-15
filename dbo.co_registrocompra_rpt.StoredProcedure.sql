SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Tengo que actualizar el mantenimiento de provisiones 
--Con el nuevo campo operacion grabada.
-- drop proc co_registrocompra_rpt
/*
exec co_registrocompra_rpt 'aliterm2012','aliterm2012','empresax','01','2012','10'
*/

CREATE      Proc [co_registrocompra_rpt]
      @BaseCompra varchar(50),
      @BaseConta varchar(50),
      @ServCompra varchar(50),
      @tipo varchar(2),
      @Ano       varchar(4),
      @Mes       varchar(2)
As
Set Nocount on
Declare @SqlCad  Varchar(8000)
Set @SqlCad=''+
'Select a.cabprovinumero,A.cabprovifchdoc,A.documetocodigo,
c.tdocumentodescripcion,A.cabprovinumdoc,
empresacodigo= right(''00''+rtrim(A.empresacodigo),2),
e.empresadescripcion,
cabproviruc=f.clienteruc,cabprovirznsoc=f.clienterazonsocial,
BaseImpCD=Case When isnull(A.cabproviopergrab,0) <> 0 
               then
                   (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 
                   Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotbru 
                    Else A.cabprovitotbru * B.tipocambioventa end ),0)
               Else 0 end,
BaseImpSD=Case When isnull(A.cabproviopergrab,0)=0 
               then 
				   (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 		
				   Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotbru 
                    Else A.cabprovitotbru * B.tipocambioventa end ),0)
               Else 0 end,
Inafecto=case when  A.tipocompracodigo <> ''64'' and A.tipocompracodigo <> ''65'' 
         then 
			(Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 	
           Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotinaf 
                    Else A.cabprovitotinaf * B.tipocambioventa end ),0)
           
         Else 0 End,
IGVCD=  (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 
		Case When isnull(A.cabproviopergrab,0) <> 0 and (A.tipocompracodigo <> ''64'' or A.tipocompracodigo <> ''65'')
           then 
			  Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv 
                    Else A.cabprovitotigv * B.tipocambioventa end ),0)                   
           Else 0 end,
IGVSD=  (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 
        Case When isnull(A.cabproviopergrab,0)=0 and (A.tipocompracodigo <> ''64'' or A.tipocompracodigo <> ''65'')
           then 
			  Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv  
                    Else A.cabprovitotigv  * B.tipocambioventa end ),0)				  	
               
           Else 0 end,
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
Tdref=A.cabprovitipdocref,
Docref=A.cabprovinref,
TipCamb=B.tipocambioventa,
Tipcompra=A.tipocompracodigo,
Compconta=A.cabprovinconta,
numaux=A.cabprovinumaux,
BaseRef=(Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end) * Isnull(
              (Case When A.monedacodigo=''02'' then A.cabprovitotal  
               Else 0 end ),0)    	                        
From ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A
     inner join ['+@BaseCompra+'].dbo.cp_tipodocumento C
         on  A.documetocodigo =C.tdocumentocodigo   
     inner join ['+@BaseConta+'].dbo.ct_tipocambio B
       on Case When upper(C.tdocumentotipo)=''A'' then 
               cabprovifechdocref Else A.cabprovifchdoc End
               =B.tipocambiofecha 
     inner join ['+@BaseCompra+'].dbo.co_modoprovi  D 
        on A.modoprovicod=D.modoprovicod      
     left join ['+@BaseCompra+'].dbo.co_multiempresas  e  
        on a.empresacodigo=e.empresacodigo  
     inner join ['+@BaseCompra+'].dbo.cp_proveedor  f
        on A.proveedorcodigo=f.clientecodigo 
where  isnull(D.modoproviregcom,0)=1 and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+ ' 
        and a.empresacodigo like '''+@tipo+'''
        Order By A.cabprovinumaux '
execute(@SqlCad)
--print(@SqlCad)
--select * from acuaplayacasma.dbo.co_cabprovi2006 where documetocodigo='02' 
--exec co_registrocompra_rpt 'acop_centro','acop_centro','marianela','%%','2007',1
GO
