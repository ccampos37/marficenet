SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [co_generaasientoenlinea_pro]
@BaseConta		Varchar(100),
@BaseCompra 		varchar(100),
@SubAsiento 		varchar(15),
@Libro   			varchar(2),         
@Mes     			varchar(2),
@Ano     			varchar(4),
@ctatotal       varchar(20),
@ctaIGV         varchar(20),
@ctaIES         varchar(20),
@ctaRTA         varchar(20),
@tipanal        varchar(3), 
@Compu   			varchar(50),
@Usuario 			varchar(20),
@Oficina			varchar(3),
@numcomprob     varchar(6)	          
AS

exec co_GeneraTempComprasenlinea_pro @BaseConta,@BaseCompra,@SubAsiento,@Libro,@Mes,@Ano,@ctatotal,@ctaIGV,@ctaIES,@ctaRTA,@tipanal,@Compu,@Usuario,@Oficina,@numcomprob
  
Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000) 
       
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
       A.eqconta =B.asientocodigo         
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
 Where A.documentocodigo  =B.documentocodigo  and  
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
execute(@SqlCad2)
--Se actualizo el numero de comprobante en la cabecera de provisiones
Set @SqlCad=''+
'Update ['+@BaseCompra+'].dbo.co_cabeceraprovisiones 
Set cabprovinconta=C.cabcomprobnumero 
from ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A, 
              ##tmpgenasientocab'+@Compu+' B,
              ['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' C 
Where 
       cast(A.cabprovinumero as varchar(20))=B.numprovi   and 
       cast(A.cabprovinumero as varchar(20))=C.cabcomprobnprovi and
		 c.cabcomprobmes=' +@mes+ ' and a.cabprovimes=' +@mes
exec(@SqlCad)
--Actualizar Correlativos de Asientos 
Set @SqlCad=''+
'Update ['+@BaseConta+'].dbo.ct_asientocorre 
 Set asientonumcorr'+@Mes+'= B.Ultimo
 From  
 ['+@BaseConta+'].dbo.ct_asientocorre A,
 [##tmpcorrela'+@Compu+'] B
 Where A.asientoanno='''+@Ano+''' and 
       A.asientocodigo =B.eqconta          
 ' 
Exec(@SqlCad) 
--Actualiza correlativo de Libros
Set @SqlCad=''+
'Update  ['+@BaseConta+'].dbo.ct_librocorre
 Set libronumcorr'+@Mes+'=libronumcorr'+@Mes+'+ 
           (Select count(*)  from ##tmpgenasientocab'+@COMPU+') 
 Where librocodigo='''+@Libro+''' and  libroanno='''+@Ano+''''
Exec(@SqlCad)
--Actualiza el Número Auxiliar de Compras
Set @SqlCad=''+ 'update ['+@BaseConta+'].dbo.ct_cabcomprob' +@Ano+ ' 
set cabcomprobnumaux=left(a.cabprovinumaux,2)+ ''' +@oficina+ '''+substring(a.cabprovinumaux,3,5)
from
	[' +@BaseCompra+ '].dbo.co_cabprovi' +@Ano+ ' a,
	[' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' b
where 	a.cabprovimes=' +@mes+ ' and b.cabcomprobmes=' +@mes+ ' and
			a.cabprovinconta=b.cabcomprobnumero'
Exec(@SqlCad)
--Generando Asientos Automaticos y Calculando el total del comprobante
Declare @Xcabcomprobnumero varchar(10),@Xasientocodigo varchar(3),
        @Xsubasientocodigo varchar(4),@Xtabla varchar(50)
Set @Xtabla='ct_detcomprob'+@Ano
set @Sqlcad=' Declare GenAuto Cursor for 
select B.cabcomprobnumero,B.asientocodigo,B.subasientocodigo 
from [##tmpgenasientocab'+@compu+'] A,['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' B
Where
  A.numprovi collate Modern_Spanish_CI_AI=B.cabcomprobnprovi collate Modern_Spanish_CI_AI ' 
execute(@Sqlcad)
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
SET QUOTED_IDENTIFIER OFF
GO
