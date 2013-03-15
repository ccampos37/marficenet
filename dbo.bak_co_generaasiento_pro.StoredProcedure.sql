SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Armando la Cabecera*/
--Por cada comprobante de provision un documento contable.
/*****
Autor : Fernando Cossio Peralta
Objetivo:Generar Asientos Contables en Provisiones
*/
--Indicar el Parametro del Libro
--Se verifican si esos proveedores no esta registrados en contabilidad 
/*Insert into contaprueba.dbo.ct_entidad
(entidadcodigo, entidadrazonsocial, entidaddireccion, 
 entidadruc, entidadtelefono, entidadtipocontri,
 usuariocodigo, fechaact)
--Verificar luego los proveedores que no tenga ruc y que el sistema
--de un mensaje de cuales son
Select Distinct cabproviruc, cabprovirznsoc,' ',
  cabproviruc,' ','00','Sys',Getdate()   
From   compras.dbo.co_cabproviXXXX A Where A.cabprovimes=09
and  cabproviruc collate  Modern_Spanish_CI_AI 
Not in(Select entidadcodigo collate  Modern_Spanish_CI_AI from contaprueba.dbo.ct_entidad)
Insert into contaprueba.dbo.ct_analitico
(analiticocodigo, entidadcodigo, tipoanaliticocodigo, usuariocodigo, fechaact)
Select Distinct cabproviruc+'001',cabproviruc,'001','sys',getdate()
From   compras.dbo.co_cabproviXXXX A Where A.cabprovimes=09 and 
cabproviruc collate  Modern_Spanish_CI_AI 
Not in(Select entidadcodigo collate  Modern_Spanish_CI_AI from contaprueba.dbo.ct_entidad)*/
--*FALTA MODIFICAR EL PARAMETRO DE AÑO EN LAS TABLAS DE CONTABILIDAD
--*VERIFICAR QUE LAS PROVISIONES GENERADAS EN EL MES NO SE VUELVAN 
-- A GENERAR SI ES QUE TIENEN LA MARCA DE COMPROBANTE CONTABILIZADO
-- SE AÑADE RELACIONA UNA TABLA TEMPORAL CON LOS REGISTROS QUE QUIERE
-- CONTABILIZAR
--*CREAR UN CAMPO EN CONTABILIDAD Y EN PROVISIONES INDICANDO QUE HA
--SIDO CONTABILIZADO
create               PROC [bak_co_generaasiento_pro]
--Declare
        @BaseConta		Varchar(100),
        @BaseCompra 	varchar(100),
        @SubAsiento 	varchar(15),
        @Libro   		varchar(2),         
        @Mes     		varchar(2),
        @Ano     		varchar(4),
        @ctatotal       varchar(20),
        @ctaIGV         varchar(20),
        @ctaIES         varchar(20),
        @ctaRTA         varchar(20),
        @tipanal        varchar(3), 
        @Compu   		varchar(50),
        @Usuario 		varchar(20)          
AS
/*Set @BaseConta='CONTAPRUEBA'
  Set @BaseCompra='COMPRAS'
  Set @SubAsiento='0099'
  SET @Libro='02'
  Set @Mes='09'
  Set @Ano='XXXX'
  set @ctatotal='421101' 
  set @ctaIGV='401110'
  set @ctaIES='421115'
  set @ctaRTA='451596'
  set @tipanal='001'
  Set @Compu='SERVIDOR'
  Set @Usuario='Sys' */
Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000) 
       
Set @SqlCad=''+
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select numprovi=cast(A.cabprovinumero as varchar(20)),
        cabcomprobmes=A.cabprovimes,cabcomprobnumero=cast(''0'' as bigint) ,correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=cabprovifchconta,
        subasientocodigo='''+@SubAsiento+''',usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo=co.eqconta ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Provision de compras Nº''+rtrim(cast(A.cabprovinumero as varchar(20))),
        cabcomprobtotdebe=case when  A.monedacodigo=''01'' then A.cabprovitotal Else 0 end ,
        cabcomprobtothaber=case when  A.monedacodigo=''01'' then A.cabprovitotal Else 0 end,
        cabcomprobtotussdebe=case when A.monedacodigo=''02'' then A.cabprovitotal Else 0 end,
        cabcomprobtotusshaber=case when A.monedacodigo=''02'' then A.cabprovitotal Else 0 end,cabcomprobgrabada=A.cabproviopergrab,cabcomprobnref='' '',
        cabcomprobnlibro=0 Into [##tmpgenasientocab'+@Compu+'] 
 From   ['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A,['+@BaseCompra+'].dbo.co_tipocompra co              
        Where A.tipocompracodigo=co.tipocompracodigo and 
              A.cabprovimes='+@Mes+' and ltrim(rtrim(isnull(A.cabprovinconta,'''')))=''''
 --Item del Importe Bruto
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
  
 Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 (select numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=''00'',
       asientocodigo=co.eqconta,detcomprobitem=''00001'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.documetocodigo,operacioncodigo=''01'',cuentacodigo=B.cuentacodigo,
       detcomprobnumdocumento=A.cabprovinumdoc,detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa='' '',            
       detcomprobdebe=case when isnull(gd.documentonotacredito,0)=0 then  Case when A.monedacodigo=''01'' then B.detproviimpbru else 0 end else 0 end ,
       detcomprobhaber=case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.monedacodigo=''01'' then B.detproviimpbru else 0 end else 0 end ,
       detcomprobusshaber=case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.monedacodigo=''02'' then B.detproviimpbru else 0 end else 0 end,
       detcomprobussdebe=case when isnull(gd.documentonotacredito,0)=0 then  Case when A.monedacodigo=''02'' then B.detproviimpbru else 0 end else 0 end,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
from ['+@BaseCompra+'].dbo.co_detprovi'+@Ano+' B,['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A,
     ['+@BaseCompra+'].dbo.co_tipocompra co,['+@BaseConta+'].dbo.gr_documento gd
   
Where   
     A.tipocompracodigo=co.tipocompracodigo and  
     A.documetocodigo collate  Modern_Spanish_CI_AI =gd.documentocodigo collate  Modern_Spanish_CI_AI
     and 
     B.cabprovinumero=A.cabprovinumero and A.cabprovimes='+@Mes+'
  Union all 
--Registro del IGV
select numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=''00'',
       asientocodigo=co.eqconta,detcomprobitem=''00002'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when A.tipocompracodigo <>''64'' then '''+@ctaIGV+'''  
                    else '''+@ctaIES+''' end,
       detcomprobnumdocumento=A.cabprovinumdoc,detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa='' '',            
       detcomprobdebe=case when isnull(gd.documentonotacredito,0)=0 then  Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end else 0 end,
       detcomprobhaber=case when isnull(gd.documentonotacredito,0)=0 then Case when A.monedacodigo=''01'' and A.tipocompracodigo =''64'' then Abs(sum(B.detproviimpigv)) else 0 end  
                       Else Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end End ,
       detcomprobusshaber=case when isnull(gd.documentonotacredito,0)=0 then  Case when A.monedacodigo=''02'' and A.tipocompracodigo =''64''  then Abs(sum(B.detproviimpigv)) else 0 end
                       Else Case when A.monedacodigo=''02'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end End ,
       detcomprobussdebe=case when isnull(gd.documentonotacredito,0)=0 then Case when A.monedacodigo=''02'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end else 0 end,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
from ['+@BaseCompra+'].dbo.co_detprovi'+@Ano+' B,['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A,
     ['+@BaseCompra+'].dbo.co_tipocompra co,['+@BaseConta+'].dbo.gr_documento gd
   
Where   
     	 A.tipocompracodigo=co.tipocompracodigo and  
     	 A.documetocodigo collate  Modern_Spanish_CI_AI =gd.documentocodigo collate  Modern_Spanish_CI_AI
         and 
         B.cabprovinumero=A.cabprovinumero and A.cabprovimes='+@Mes+'
group by B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,A.documetocodigo,A.cabprovinumdoc,
         A.cabprovifchdoc,A.cabprovifchven,B.detprovitipcam,A.cabproviruc,B.detproviformcamb,
         A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.documentonotacredito
Union all '
Set @SqlCad2='
--Registro Inafecto 
 select numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=A.cabproviruc+'''+@tipanal+''',
       asientocodigo=co.eqconta,detcomprobitem=''00003'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when A.tipocompracodigo <>''64'' then B.cuentacodigo
                    else '''+@ctaRTA+'''end,
       detcomprobnumdocumento=A.cabprovinumdoc,detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa='' '',            
       detcomprobdebe=Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then Abs(B.detproviimpina) else 0 end,
       detcomprobhaber=Case when A.monedacodigo=''01'' and A.tipocompracodigo =''64'' then Abs(B.detproviimpina) else 0 end,
       detcomprobusshaber=Case when A.monedacodigo=''02'' and A.tipocompracodigo =''64'' then Abs(B.detproviimpina) else 0 end,
       detcomprobussdebe=Case when A.monedacodigo=''02'' and  A.tipocompracodigo <>''64'' then Abs(B.detproviimpina) else 0 end,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=case when A.tipocompracodigo <>''64'' then  1 else 0 End,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
from ['+@BaseCompra+'].dbo.co_detprovi'+@Ano+' B,['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A,
     ['+@BaseCompra+'].dbo.co_tipocompra co,['+@BaseConta+'].dbo.gr_documento gd
   
Where   
     A.tipocompracodigo=co.tipocompracodigo and  
     A.documetocodigo collate  Modern_Spanish_CI_AI =gd.documentocodigo collate  Modern_Spanish_CI_AI
     and 
     B.cabprovinumero=A.cabprovinumero and A.cabprovimes='+@Mes+' and B.detproviimpina <> 0
--Registro del Total Compra
Union all 
 select numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=A.cabproviruc+'''+@tipanal+''',
       asientocodigo=co.eqconta,detcomprobitem=''00004'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.documetocodigo,operacioncodigo=''01'',cuentacodigo='''+@ctatotal+''' ,
       detcomprobnumdocumento=A.cabprovinumdoc,detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa='' '',            
       detcomprobdebe=case when isnull(gd.documentonotacredito,0)=1 then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end  else 0 End ,
       detcomprobhaber=case when isnull(gd.documentonotacredito,0)=0 then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobusshaber=case when isnull(gd.documentonotacredito,0)=0 then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobussdebe=case when isnull(gd.documentonotacredito,0)=1 then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End ,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
from   ['+@BaseCompra+'].dbo.co_detprovi'+@Ano+' B,['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A,
       ['+@BaseCompra+'].dbo.co_tipocompra co,['+@BaseConta+'].dbo.gr_documento gd   
Where   
      A.tipocompracodigo=co.tipocompracodigo and  
      A.documetocodigo collate  Modern_Spanish_CI_AI =gd.documentocodigo collate  Modern_Spanish_CI_AI
      and 
      B.cabprovinumero=A.cabprovinumero and A.cabprovimes='+@Mes+'  
group by B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,A.documetocodigo,A.cabprovinumdoc,
         A.cabprovifchdoc,A.cabprovifchven,B.detprovitipcam,A.cabproviruc,B.detproviformcamb,
         A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.documentonotacredito
) as XX Where ltrim(rtrim(isnull(XX.cabprovinconta,'''')))='''''  
--print (@SqlCad) 
--print (@SqlCad2)
Exec(@SqlCad+@SqlCad2)
Declare @CtaReg BigInt
Exec('
Declare CuentaReg Cursor for 
Select CtaReg=Count(*) From [##tmpgenasientocab'+@compu+']')
Open CuentaReg
Fetch Next from CuentaReg into @CtaReg
Close CuentaReg
Deallocate CuentaReg
If @CtaReg=0 
Begin
   Print 'No Existen Registros para generar a contabilidad '	
   Return 0
End
--El correlativo es por libros 
--se tiene generar un temporal por cada asiento y su correlativo
--para cada correlativo de cada libro
SET @SqlCad='
 If Exists(Select name from tempdb..sysobjects where name=''##tmpcorrela'+@compu+''') 
    Drop Table [##tmpcorrela'+@compu+']  
 select MaxAsi=asientonumcorr'+@mes+',A.eqconta,Ultimo=asientonumcorr'+@mes+'  Into [##tmpcorrela'+@compu+'] 
 from ['+@BaseCompra+'].dbo.co_tipocompra A,['+@BaseConta+'].dbo.ct_asientocorre B
 where B.asientoanno='''+@Ano+''' and 
       A.eqconta collate  Modern_Spanish_CI_AI =B.asientocodigo collate  Modern_Spanish_CI_AI        
  ' 
--print(@SqlCad)
Exec(@SqlCad)
SET @SqlCad='  
Declare @Asiento varchar(3),@Numprovi varchar(20)
Declare Correla cursor for 
select asientocodigo,numprovi from [##tmpgenasientocab'+@compu+']
order by asientocodigo
Open Correla
fetch next from Correla into @Asiento,@Numprovi
While @@Fetch_Status=0 
Begin 
   update [##tmpgenasientocab'+@compu+']
   set cabcomprobnumero=isnull(B.Ultimo,0) +1
   From  [##tmpgenasientocab'+@compu+'] A,
         [##tmpcorrela'+@compu+'] B
   Where A.Asientocodigo=B.eqconta and 
         numprovi=@Numprovi
   
   Update  [##tmpcorrela'+@compu+'] 
   Set  Ultimo=ISNULL(Ultimo,0)+1 
   Where  eqconta=@Asiento
   fetch next from Correla into @Asiento,@Numprovi		
End
Close Correla
Deallocate Correla '
--print(@SqlCad)     
exec(@SqlCad)
Set @SqlCad2=' '+ 
'Update [##tmpgenasientodet'+@compu+']
 Set
     detcomprobtipocambio=tipocambioventa,
     detcomprobformacambio=''02'',
     detcomprobdebe=isnull(case when A.monedacodigo =''01'' then  A.detcomprobdebe else round(A.detcomprobussdebe*tipocambioventa,2) end,0) ,
     detcomprobussdebe=isnull(case when A.monedacodigo =''02'' then  A.detcomprobussdebe else round(A.detcomprobdebe/tipocambioventa,2) end,0), 
     detcomprobhaber=isnull(case when A.monedacodigo =''01'' then  A.detcomprobhaber else round(A.detcomprobusshaber*tipocambioventa,2) end,0), 
     detcomprobusshaber=isnull(case when A.monedacodigo =''02'' then  A.detcomprobusshaber else round(A.detcomprobhaber/tipocambioventa,2) end,0)   
 From [##tmpgenasientodet'+@compu+'] A,
              ['+@baseconta+'].dbo.gr_documento B,
              ['+@baseconta+'].dbo.ct_tipocambio C
 Where A.documentocodigo collate  Modern_Spanish_CI_AI =B.documentocodigo collate  Modern_Spanish_CI_AI and  
      (Case When B.documentonotacredito=0 then A.detcomprobfechaemision 
       Else A.detcomprobfecharef end) =C.tipocambiofecha ' 
--print(@SqlCad2)
Exec(@SqlCad2)
Set @SqlCad2=''+ 
'Declare @nprobiantes bigint,@nprovi bigint,@conta bigint,@numfila BigInt
 set @nprobiantes=-20
 Declare llenaritem Cursor  for
 select numprovi,numfila from [##tmpgenasientodet'+@compu+'] 
 order by numprovi,detcomprobitem
 open llenaritem
 fetch next from llenaritem into @nprovi,@numfila
 While @@Fetch_Status=0 
 Begin
    If @nprobiantes <> @nprovi Set @Conta=0 
    Set @conta=@conta+1 
    Set @nprobiantes=@nprovi 	
    update [##tmpgenasientodet'+@compu+']
    Set detcomprobitem=replicate(''0'',5-len(@conta))+ltrim(rtrim(cast(@conta as varchar(20))))         
    where numfila=@numfila    
    fetch next from llenaritem into @nprovi,@numfila
End 
Close llenaritem
Deallocate llenaritem '
--print(@SqlCad2)
Exec(@SqlCad2)
Set @SqlCad2='
 Declare @MaxLibro Bigint 
 Select @MaxLibro=libronumcorr'+@mes+' from '+@BaseConta+'.dbo.ct_librocorre 
 where  librocodigo='''+@Libro+''' and libroanno='''+@Ano+''' 
 Insert Into ['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+'
(cabcomprobmes, cabcomprobnumero , cabcomprobfeccontable, subasientocodigo, 
 usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones, 
 fechaact, cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber,
 cabcomprobtotussdebe, cabcomprobtotusshaber, cabcomprobgrabada,
 cabcomprobnref, cabcomprobnlibro,cabcomprobnprovi)
 Select  cabcomprobmes,
         comprobnumero='''+@mes+'''+asientocodigo+replicate(''0'',5-len(cabcomprobnumero))+ltrim(rtrim(cast(cabcomprobnumero as varchar(20))))     
         , cabcomprobfeccontable, subasientocodigo, 
        usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones, fechaact, 
        cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber, cabcomprobtotussdebe, 
        cabcomprobtotusshaber, cabcomprobgrabada, cabcomprobnref,
        comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+correlibro))+ltrim(rtrim(cast(@MaxLibro+correlibro as varchar(20)))),
        numprovi  
 from [##tmpgenasientocab'+@compu+'] A     
Insert Into ['+@BaseConta+'].dbo.ct_detcomprob'+@Ano+'
(cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
 detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,
 cuentacodigo, detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
 detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe,
 detcomprobtipocambio, detcomprobruc, detcomprobauto, detcomprobformacambio,
 detcomprobajusteuser, plantillaasientoinafecto, tipdocref,
 detcomprobnumref, detcomprobconci, detcomprobnlibro, detcomprobfecharef)
Select A.cabcomprobmes, 
       comprobnumero='''+@mes+'''+A.asientocodigo+replicate(''0'',5-len(B.cabcomprobnumero))+ltrim(rtrim(cast(B.cabcomprobnumero as varchar(20)))),
       A.subasientocodigo, A.analiticocodigo, A.asientocodigo,
       A.detcomprobitem, A.monedacodigo, A.centrocostocodigo, A.documentocodigo, A.operacioncodigo,
       A.cuentacodigo, A.detcomprobnumdocumento, A.detcomprobfechaemision, A.detcomprobfechavencimiento,
       A.detcomprobglosa, A.detcomprobdebe, A.detcomprobhaber, A.detcomprobusshaber, A.detcomprobussdebe,
       A.detcomprobtipocambio, A.detcomprobruc, A.detcomprobauto, A.detcomprobformacambio,
       A.detcomprobajusteuser, A.plantillaasientoinafecto,
       tipdocref= case when rtrim(isnull(A.tipdocref,''00''))='''' then ''00'' else isnull(A.tipdocref,''00'') end,
       A.detcomprobnumref, A.detcomprobconci, 
       comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+B.correlibro))+ltrim(rtrim(cast(@MaxLibro+B.correlibro as varchar(20))))
       , A.detcomprobfecharef
from [##tmpgenasientodet'+@compu+'] A, 
     [##tmpgenasientocab'+@compu+'] B,
     [##tmpcorrela'+@compu+'] C        
Where A.numprovi=cast(B.numprovi as bigint) and 
      A.asientocodigo=C.eqconta 
    '
--print (@SqlCad2)
Exec(@SqlCad2)
--Generar Automaticos 
--Generando Asientos Automaticos y Calculando el total del comprobante
Declare @Xcabcomprobnumero varchar(10),@Xasientocodigo varchar(3),
        @Xsubasientocodigo varchar(4),@Xtabla varchar(50)
Set @Xtabla='ct_detcomprob'+@Ano
set @Sqlcad=' Declare GenAuto Cursor for 
select B.cabcomprobnumero,B.asientocodigo,B.subasientocodigo 
from [##tmpgenasientocab'+@compu+'] A,['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' B
Where
  A.numprovi=B.cabcomprobnprovi ' 
Exec(@Sqlcad)
Open GenAuto
Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo
While @@Fetch_status=0 
Begin
    Exec ct_grabaautomatico_pro @baseconta,@Xtabla,@mes,
    @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo                                   
   	
    Exec ct_CalcComprob_pro '',@baseconta,@Ano,@mes,
    @Xasientocodigo,@Xsubasientocodigo,@Xcabcomprobnumero   
    Print  @Xasientocodigo +' '+@Xsubasientocodigo+' '+@Xcabcomprobnumero
    Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo	
End
Close GenAuto
Deallocate GenAuto
--Se actualizo el numero de comprobante en la cabecera de provisiones
Set @SqlCad=''+
'Update ['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' 
Set cabprovinconta=C.cabcomprobnumero 
from ['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A, 
              ##tmpgenasientocab'+@Compu+' B,
              ['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' C 
Where 
       cast(A.cabprovinumero as varchar(20))=B.numprovi   and 
       cast(A.cabprovinumero as varchar(20))=C.cabcomprobnprovi) '
exec(@SqlCad)
--Actualizar Correlativos de Asientos 
Set @SqlCad=''+
'Update ['+@BaseConta+'].dbo.ct_asientocorre 
 Set asientonumcorr'+@Mes+'= B.Ultimo
 From  
 ['+@BaseConta+'].dbo.ct_asientocorre A,
 [##tmpcorrela'+@Compu+'] B
 Where A.asientoanno='''+@Ano+''' and 
       A.asientocodigo collate  Modern_Spanish_CI_AI  =B.eqconta collate  Modern_Spanish_CI_AI         
 ' 
Exec(@SqlCad) 
--Actualiza correlativo de Libros
Set @SqlCad=''+
'Update  ['+@BaseConta+'].dbo.ct_librocorre
 Set libronumcorr'+@Mes+'=libronumcorr'+@Mes+'+ 
           (Select count(*)  from ##tmpgenasientocab'+@COMPU+') 
 Where librocodigo='''+@Libro+''' and  libroanno='''+@Ano+''''
Exec(@SqlCad)
--exec co_generaasiento_pro 'Contaprueba','ComprasPrueba','0099','02','02','2003','421101','401110','403140','401174','001','Desarrollo3','sa'
GO
