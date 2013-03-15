SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Tengo que actualizar el mantenimiento de provisiones 
--Con el nuevo campo operacion grabada.
CREATE     Proc [co_bak_registrocompra_rpt]
      @BaseCompra varchar(50),
      @BaseConta varchar(50),
      @BaseVenta varchar(50), 
      @ServCompra varchar(50),
      @ServConta varchar(50),
      @ServVenta varchar(50),
      @Ano       varchar(4),
      @Mes       varchar(2),
      @Compu     varchar(50)
As
/*Set @BaseCompra='Compras'
Set @BaseConta='Contaprueba'
Set @BaseVenta='Ventas'
--exec co_registrocompra_rpt 'Camtex_tj','Contaprueba','Camtex_tj','server_tc','server_tc','server_tc','2003','05','Desa3'
Set @Ano='XXXX'
Set @Mes='9'*/
Set Nocount on
If Exists(select name from tempdb..sysobjects where name='##tmpregcompra'+@compu)
Begin
	Exec('Set Nocount on
           drop table '+'##tmpregcompra'+@compu+'   
          Set Nocount off' )
End 
Declare @SqlCad  Varchar(8000)
Set @SqlCad=''+
'Set Nocount on
 Select 
A.cabprovifchdoc,A.documetocodigo,A.cabprovinumdoc,
A.cabproviruc,A.cabprovirznsoc,
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
Inafecto=case when  A.tipocompracodigo <> ''64'' 
         then 
			(Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 	
           Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotinaf 
                    Else A.cabprovitotinaf * B.tipocambioventa end ),0)
           
         Else 0 End,
IGVCD=  (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 
		Case When isnull(A.cabproviopergrab,0) <> 0 and A.tipocompracodigo <> ''64''
           then 
			  Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv 
                    Else A.cabprovitotigv * B.tipocambioventa end ),0)                   
           Else 0 end,
IGVSD=  (Case When upper(C.tdocumentotipo)=''A'' then -1 else 1 end)* 
        Case When isnull(A.cabproviopergrab,0)=0 and A.tipocompracodigo <> ''64''
           then 
			  Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv  
                    Else A.cabprovitotigv  * B.tipocambioventa end ),0)				  	
               
           Else 0 end,
IES=case when  A.tipocompracodigo = ''64'' then 
             Isnull(
                   (Case When A.monedacodigo=''01'' then A.cabprovitotigv  
                    Else A.cabprovitotigv  * B.tipocambioventa end ),0)
             
         Else 0 End,
ImpRta=case when  A.tipocompracodigo = ''64'' then 
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
Into ##tmpregcompra'+@compu+'
From ['+@ServCompra+'].['+@BaseCompra+'].dbo.co_cabeceraprovisiones A,
     ['+@ServConta+'].['+@BaseConta+'].dbo.ct_tipocambio B,
     ['+@ServVenta+'].['+@BaseVenta+'].dbo.cp_tipodocumento C,      
     ['+@ServCompra+'].['+@BaseCompra+'].dbo.co_modoprovi  D  
     Where 
     A.modoprovicod=D.modoprovicod and isnull(D.modoproviregcom,0)=1 and       
     Case When upper(C.tdocumentotipo)=''A'' then 
               cabprovifechdocref Else A.cabprovifchdoc End
        *=B.tipocambiofecha and 
     A.documetocodigo collate  Modern_Spanish_CI_AI =C.tdocumentocodigo collate  Modern_Spanish_CI_AI and 
     A.cabprovimes='+@Mes+ ' 
     Order By A.numaux 
Set Nocount Off
'
exec(@SqlCad)
GO
