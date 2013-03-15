SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute te_GeneraAsientosTesoreriaTransflinea_pro 'planta_casma','planta_casma','03','011','0099','04','01','2011','##jck','','001691','7761000','6761100'

*/                            
CREATE             proc [te_GeneraAsientosTesoreriaTransflinea_pro] 
--Declare
  @Baseventa    	varchar(100),
  @Baseconta 		varchar(100),
  @empresa   varchar(2),
  @Asiento	    	varchar(15), 
  @SubAsiento 		varchar(15),
  @Libro   			varchar(2),         
  @Mes     			varchar(2),
  @Ano     			varchar(4),        
  @Compu   			varchar(50),
  @Usuario 			varchar(20), 
  @Ntransfer 	    		varchar(15),
  @ajustedebe                  	varchar(20),
  @ajustehaber                 	varchar(20)

as    
Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000)

exec te_GeneraTempContableTransfLinea @Baseventa,@Baseconta,@empresa,@ajustehaber,@ajustedebe,@Compu,@Mes,@Ano,@Ntransfer

Set @SqlCad=
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select a.empresacodigo,numprovi=A.cabrec_numrecibo,
        cabcomprobmes='+@Mes+',
        cabcomprobnumero=cast(''0'' as bigint) ,correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=A.FechaEmision ,
        subasientocodigo='''+@SubAsiento+''',usuariocodigo='''+@Usuario+''',estcomprobcodigo=''01'',
        asientocodigo='''+@Asiento+'''   ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Numero de transferencia ''+A.cabrec_numrecibo,
        cabcomprobtotdebe=0,
        cabcomprobtothaber=0,
        cabcomprobtotussdebe=0,
        cabcomprobtotusshaber=0,cabcomprobgrabada=0,cabcomprobnref='' '',
        cabcomprobnlibro=0 Into [##tmpgenasientocab'+@Compu+'] 
 From   [##tmpAsientosContaTransf'+@Compu+'] A
 Group by A.FechaEmision,a.empresacodigo,A.cabrec_numrecibo'
execute(@SqlCad) 
Set @SqlCad='
 --Seleccion del Detalle
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
  
 Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 (select a.empresacodigo, numprovi=A.cabrec_numrecibo,
       cabcomprobmes='+@Mes+',
       cabcomprobnumero=''    '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=rtrim(A.clientecodigo),                      
       asientocodigo='''+@Asiento+''',detcomprobitem=Replicate(''0'',5-len(A.detrec_item))+rtrim(ltrim(cast(A.detrec_item as varchar(10)))),monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.detrec_tipodoc_concepto,operacioncodigo=''03'',cuentacodigo=A.cuenta,
       detcomprobnumdocumento=A.detrec_numdocumento,detcomprobfechaemision=A.FechaEmision,
       detcomprobfechavencimiento=A.FechaCancela,detcomprobglosa=A.detrec_observacion,            
       detcomprobdebe=isnull(A.DebeS ,0),
       detcomprobhaber=isnull(A.HaberS,0),
       detcomprobussdebe= isnull(DebeD,0), 
       detcomprobusshaber=isnull(HaberD,0),  
       detcomprobtipocambio=A.TipoCambio , detcomprobruc=space(11),
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=space(2), detcomprobnumref=space(11),
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=null,cabprovinconta=A.cabrec_numrecibo
from  [##tmpAsientosContaTransf'+@compu+']  A
     ) as XX '     

execute(@SqlCad) 

--Inserta Analiticos 

Declare @Analitico varchar(15),@Ruc varchar(11)
exec te_InsertaAnaliticoLinea_pro @Baseconta,@Baseventa,@Compu,@Analitico Output,@Ruc Output  
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
--collate  Modern_Spanish_CI_AI
SET @SqlCad='
 If Exists(Select name from tempdb..sysobjects where name=''##tmpcorrela'+@compu+''') 
    Drop Table [##tmpcorrela'+@compu+']  
 
 select MaxAsi=asientonumcorr'+@MES+',Asiento2=a.asientocodigo,Ultimo=asientonumcorr'+@MES+' 
 Into [##tmpcorrela'+@compu+']
 from ['+@BaseConta+'].dbo.ct_asientocorre a 
 where a.empresacodigo='''+@empresa+''' and a.asientoanno='''+@Ano+''' and a.asientocodigo='''+@asiento+'''' 
EXEC(@SqlCad)
SET @SqlCad='  
Declare @Asiento varchar(3),@Numprovi VARCHAR(20)
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
   Where A.Asientocodigo collate  Modern_Spanish_CI_AI  =B.Asiento2 collate  Modern_Spanish_CI_AI  and 
         numprovi=@Numprovi
   
   Update  [##tmpcorrela'+@compu+'] 
   Set  Ultimo=ISNULL(Ultimo,0)+1 
   Where  Asiento2=@Asiento
   fetch next from Correla into @Asiento,@Numprovi		
End
Close Correla
Deallocate Correla '
EXEC(@SqlCad)     
Set @SqlCad2=' '+ 
'Update [##tmpgenasientodet'+@compu+']
 Set
     detcomprobtipocambio=tipocambioventa,
     detcomprobformacambio=''02'',
     detcomprobdebe=isnull(case when A.monedacodigo =''01''     then  A.detcomprobdebe else Case when left(A.cuentacodigo,2) in (''77'',''97'') then 0 else round(A.detcomprobussdebe*tipocambioventa,2) end end  ,0)   ,
     detcomprobhaber=isnull(case when A.monedacodigo =''01''    then  A.detcomprobhaber else Case when left(A.cuentacodigo,2) in (''77'',''97'') then  0 else round(A.detcomprobusshaber*tipocambioventa,2) end end,0), 
     detcomprobussdebe=isnull(case when A.monedacodigo =''02''  then  A.detcomprobussdebe else Case when left(A.cuentacodigo,2) in (''77'',''97'') then  0 else round(A.detcomprobdebe/tipocambioventa,2) end end ,0) , 
     detcomprobusshaber=isnull(case when A.monedacodigo =''02'' then  A.detcomprobusshaber else Case when left(A.cuentacodigo,2) in (''77'',''97'') then 0 else round(A.detcomprobhaber/tipocambioventa,2) end end,0)  
 From [##tmpgenasientodet'+@compu+'] A,
              ['+@baseconta+'].dbo.gr_documento B,
              ['+@baseconta+'].dbo.ct_tipocambio C
 Where A.documentocodigo  =B.documentocodigo  and  
      (Case When B.documentonotacredito=0 then A.detcomprobfechaemision 
       Else A.detcomprobfecharef end) =C.tipocambiofecha ' 

execute(@sqlcad2)

Set @SqlCad2='
 Declare @MaxLibro Bigint
 Select @MaxLibro=libronumcorr'+@mes+' from '+@BaseConta+'.dbo.ct_librocorre 
 where  librocodigo='''+@Libro+''' and libroanno='''+@Ano+''' 
 Insert Into ['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+'
(empresacodigo,cabcomprobmes, cabcomprobnumero , cabcomprobfeccontable, subasientocodigo, 
 usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones, 
 fechaact, cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber,
 cabcomprobtotussdebe, cabcomprobtotusshaber, cabcomprobgrabada,
 cabcomprobnref, cabcomprobnlibro,cabcomprobnprovi)
 Select  empresacodigo,cabcomprobmes,
       comprobnumero='''+@mes+'''+asientocodigo+replicate(''0'',5-len(cabcomprobnumero))+ltrim(rtrim(cast(cabcomprobnumero as varchar(20))))     
       , cabcomprobfeccontable, subasientocodigo, 
        usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones, fechaact, 
        cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber, cabcomprobtotussdebe,         cabcomprobtotusshaber, cabcomprobgrabada, cabcomprobnref,
        comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+correlibro))+ltrim(rtrim(cast(@MaxLibro+correlibro as varchar(20)))),
        ''TES''+numprovi  
 from [##tmpgenasientocab'+@compu+'] A 
Insert Into ['+@BaseConta+'].dbo.ct_detcomprob'+@Ano+'
(empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
 detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,
 cuentacodigo, detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
 detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobussdebe,
 detcomprobusshaber,  detcomprobtipocambio, detcomprobruc, detcomprobauto, detcomprobformacambio,
 detcomprobajusteuser, plantillaasientoinafecto, tipdocref,
 detcomprobnumref, detcomprobconci, detcomprobnlibro, detcomprobfecharef)
Select Distinct a.empresacodigo,
       A.cabcomprobmes, 
       comprobnumero='''+@mes+'''+A.asientocodigo+replicate(''0'',5-len(B.cabcomprobnumero))+ltrim(rtrim(cast(B.cabcomprobnumero as varchar(10)))),
       A.subasientocodigo,
       analitico=Case when isnull(C.cuentaestadoanalitico,0) <> 0 then rtrim('''+@Analitico+''')+c.tipoanaliticocodigo   else ''00'' End ,
       A.asientocodigo,
       A.detcomprobitem, A.monedacodigo, A.centrocostocodigo, A.documentocodigo, A.operacioncodigo,
       A.cuentacodigo, A.detcomprobnumdocumento, A.detcomprobfechaemision, A.detcomprobfechavencimiento,
       detcomprobglosa=left(A.detcomprobglosa,50), A.detcomprobdebe, A.detcomprobhaber, A.detcomprobussdebe, A.detcomprobusshaber, 
       A.detcomprobtipocambio,
	   detcomprobruc=Case when isnull(C.cuentaestadoanalitico,0) <> 0 then '''+@Ruc+''' else '''' End,
       A.detcomprobauto, A.detcomprobformacambio,
       A.detcomprobajusteuser, A.plantillaasientoinafecto,
       tipdocref= case when rtrim(isnull(A.tipdocref,''00''))='''' then ''00'' else isnull(A.tipdocref,''00'') end,
       A.detcomprobnumref, A.detcomprobconci, 
       comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',5-len(@MaxLibro+B.correlibro))+ltrim(rtrim(cast(@MaxLibro+B.correlibro as varchar(10))))
       , A.detcomprobfecharef
from [##tmpgenasientodet'+@compu+'] A, 
     [##tmpgenasientocab'+@compu+'] B,['+@baseconta+'].dbo.ct_cuenta C
Where ltrim(rtrim(A.numprovi))=rtrim(ltrim(B.numprovi)) and  
      A.cuentacodigo=C.cuentacodigo  '

execute (@SqlCad2)


--Se actualiza el numero de comprobante en la cabecera del Recibo

Set @SqlCad=''+
'Update ['+@Baseventa+'].dbo.te_cabecerarecibos  
 Set comprobconta=C.cabcomprobnumero 
 from ['+@Baseventa+'].dbo.te_cabecerarecibos  A, 
       ##tmpgenasientocab'+@Compu+' B,
      ['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' C 
 Where 
       Rtrim(Ltrim(A.cabrec_numreciboegreso))=rtrim(ltrim(B.numprovi)) and 
       ''TES''+Rtrim(Ltrim(A.cabrec_numreciboegreso))=Ltrim(rtrim(C.cabcomprobnprovi)) and 
       a.cabrec_transferenciaautomatico=1 and c.cabcomprobmes=' +@mes
execute(@SqlCad)

--Actualizar Correlativos de Asientos 
Set @SqlCad=''+
'Update ['+@BaseConta+'].dbo.ct_asientocorre 
 Set asientonumcorr'+@Mes+'= B.Ultimo
 From  
 ['+@BaseConta+'].dbo.ct_asientocorre A,
 [##tmpcorrela'+@Compu+'] B
 Where a.empresacodigo='''+@empresa+''' and A.asientocodigo  =B.Asiento2  and 
       A.asientoanno='''+@Ano+''''  
Exec(@SqlCad) 
--Actualiza correlativo de Libros
Set @SqlCad=''+
'Update  ['+@BaseConta+'].dbo.ct_librocorre
 Set libronumcorr'+@Mes+'=libronumcorr'+@Mes+'+ 
           (Select count(*)  from ##tmpgenasientocab'+@COMPU+') 
 Where empresacodigo='''+@empresa+''' and librocodigo='''+@Libro+''' and  libroanno='''+@Ano+''''
Exec(@SqlCad)
--Generar Automaticos 
--Generando Asientos Automaticos y Calculando el total del comprobante
Declare @Xcabcomprobnumero varchar(10),@Xasientocodigo varchar(3),
        @Xsubasientocodigo varchar(4),@Xtabla varchar(50)
Set @Xtabla='ct_detcomprob'+@Ano
set @Sqlcad='Declare GenAuto Cursor for 
select B.cabcomprobnumero,B.asientocodigo,B.subasientocodigo 
from [##tmpgenasientocab'+@compu+'] A,['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' B
Where a.empresacodigo=b.empresacodigo and 
 ''TES''+rtrim(ltrim(A.numprovi))=rtrim(ltrim(B.cabcomprobnprovi))' 

execute(@Sqlcad)

Open GenAuto
Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo
While @@Fetch_status=0 
Begin
   Exec ct_grabaautomatico_pro @baseconta,@Xtabla,@empresa,@mes,
    @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo                                   
   Exec ct_CalcComprob_pro '',@baseconta,@empresa,@Ano,@mes,
    @Xasientocodigo,@Xsubasientocodigo,@Xcabcomprobnumero   
    Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo	
End
Close GenAuto
Deallocate GenAuto




set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
