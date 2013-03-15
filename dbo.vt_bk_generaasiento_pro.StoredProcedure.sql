SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE                       PROC [vt_bk_generaasiento_pro]
--Declare
  @BaseConta	Varchar(100),
  @BaseVenta 	varchar(100),  
  @BaseParam	varchar(100),
  @Libro   		varchar(2),         
  @Mes     		varchar(2),
  @Ano     		varchar(4),
  @ctatotal     varchar(20),
  @ctaIGV       varchar(20),  
  @tipanal      varchar(3), 
  @Compu   		varchar(50),
  @Usuario 		varchar(20)          
AS
/*
  Set @BaseConta='CONTAPRUEBA'
  Set @BaseVenta='VENTAS_PRUEBA'
  Set @BaseParam='VENTAS_PRUEBA'
  SET @Libro='03'
  Set @Mes='01'
  Set @Ano='2003'
  set @ctatotal='121101' 
  set @ctaIGV='401110'  
  set @tipanal='002'
  Set @Compu='DESARROLLO4'
  Set @Usuario='Sys' */
--Los Listados son Internos Para camtex y no se imprime en el formato de factura.
--Libro Ventas= 03  
/*Create Table vt_pasientocab(Tipodoc varchar(2),Asiento varchar(3))
Create Table ctventas_prueba.dbo.vt_pasientodet(tipodoc varchar(2),Serie varchar(3),subasiento varchar(4),cuenta varchar(20))*/
/*CREATE TABLE 
ct_pimpodata(BaseOrigen varchar(100),tipanal varchar(3),BaseVenta varchar(100),
             libro varchar(2),ctatotal varchar(20),ctaigv varchar(20)) */
/*tipodoc Serie subasiento cuenta               
------- ----- ---------- -------------------- 
01      001   0001       701101
01      004   0004       701108
01      012   0012       701102
01      025   0025       701103
01      444   0444       701110
01      888   0888       701109
03      001   0001       701104
03      012   0012       701105
03      025   0025       701106
07      012   0012       701107 */
--Crear los Asientos
/* Documentos 							 Ventas  Conta Asiento
   Facturas   							    01           070
   Boletas       							03		     071
   Nota de Abono o Nota de Credito			07			 072
   Nota de Cargo o Nota de Debito			08  		 073
*/
--
--Crear los SubAsiento por Serie
Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000) 
/*Select * From Ventas_Prueba.dbo.vt_pedido      
Where Month(pedidofecha)=1 and Year(pedidofecha)=2003*/
--Elimino los asientos existente
Set @SqlCad='
Delete ['+@BaseConta+'].dbo.ct_cabcomprob'+@ano+' 
from   ['+@BaseConta+'].dbo.ct_cabcomprob'+@ano+' A
Where right(A.cabcomprobnprovi,len(A.cabcomprobnprovi)-3) 
in ( select pedidonumero from ['+@BaseVenta+'].dbo.vt_pedido A  
     Where  
     Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano+')'
--Exec(@SqlCad)
Set @SqlCad=''+
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select numprovi=A.pedidonumero,
        cabcomprobmes='''+@MES+''' ,
        cabcomprobnumero=cast(''0'' as bigint) ,
        correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=A.pedidofechafact,
        subasientocodigo=D.subasiento,usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo=co.Asiento ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Nro de Pedido''+rtrim(A.pedidonumero),
        cabcomprobtotdebe=0,
        cabcomprobtothaber=0,
        cabcomprobtotussdebe=0,
        cabcomprobtotusshaber=0,cabcomprobgrabada=0,cabcomprobnref='' '',
        cabcomprobnlibro=0 Into [##tmpgenasientocab'+@Compu+'] 
 From   ['+@BaseVenta+'].dbo.vt_pedido A,['+@BaseParam+'].dbo.vt_pasientocab co,
        ['+@BaseParam+'].dbo.vt_pasientodet D              
        Where A.pedidotipofac=co.Tipodoc and 
              A.pedidotipofac=D.tipodoc and 
              Left(A.pedidonrofact,3)=D.serie and 
              A.pedidotipofac <>''80'' and  
              Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano
Exec (@SqlCad) 
--Que fecha de referencia es grabarla al final
Set @SqlCad='
 --Item del Importe Bruto Armando las cuenta 70
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
  
Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 (select
	   numprovi=B.pedidonumero,	
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero='' '',
       subasientocodigo=d.subasiento,
       analiticocodigo=''00'',
       asientocodigo=C.Asiento,detcomprobitem=''00001'',monedacodigo=B.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=B.pedidotipofac,operacioncodigo=''01'',cuentacodigo=D.cuenta,
       detcomprobnumdocumento=left(B.pedidonrofact,3)+''-''+right(B.pedidonrofact,8),
       detcomprobfechaemision=B.pedidofechafact ,
       detcomprobfechavencimiento=B.pedidofechafact ,detcomprobglosa=''Nro de Pedido''+rtrim(B.pedidonumero),         
       detcomprobdebe=Case When  NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''01'' then B.pedidototbruto else 0 end else 0 end  end,
       detcomprobhaber=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''01'' then B.pedidototbruto else 0 end else 0 end  end,
       detcomprobusshaber=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''02'' then B.pedidototbruto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT  B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''02'' then B.pedidototbruto else 0 end else 0 end end,        
       detcomprobtipocambio=cast(0 as numeric(20,4)),
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=B.pedidofechasunat,
       detcomprobruc=''''            
from ['+@BaseVenta+'].dbo.vt_pedido B,
     ['+@BaseParam+'].dbo.vt_pasientocab C,['+@BaseParam+'].dbo.vt_pasientodet D,
     ['+@BaseConta+'].dbo.gr_documento gd      
Where
      
     B.pedidotipofac=C.tipodoc and 
	 B.pedidotipofac=D.tipodoc and 
     B.pedidotipofac=gd.documentocodigo AND   
     Left(b.pedidonrofact,3)=D.serie and 
     B.pedidotipofac <> ''80'' and  
     Month(B.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano     
Set @SqlCad=@SqlCad+'
  Union all 
--Registro del IGV
Select
	   numprovi=B.pedidonumero,	
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero='' '',
       subasientocodigo=d.subasiento,
       analiticocodigo=''00'',
       asientocodigo=C.Asiento,detcomprobitem=''00002'',monedacodigo=B.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=B.pedidotipofac,operacioncodigo=''01'',cuentacodigo='''+@ctaIGV+''',
       detcomprobnumdocumento=left(B.pedidonrofact,3)+''-''+right(B.pedidonrofact,8),
       detcomprobfechaemision=B.pedidofechafact ,
       detcomprobfechavencimiento=B.pedidofechafact ,detcomprobglosa=''Nro de Pedido''+rtrim(B.pedidonumero),        
	   detcomprobdebe=Case When NOT  B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''01'' then B.pedidototimpuesto else 0 end else 0 end  end,
       detcomprobhaber=Case When NOT  B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''01'' then B.pedidototimpuesto else 0 end else 0 end end,
       detcomprobusshaber=Case When NOT  B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''02'' then B.pedidototimpuesto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT  B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''02'' then B.pedidototimpuesto else 0 end else 0 end end,                  
       detcomprobtipocambio=cast(0 as numeric(20,4)), 
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=B.pedidofechasunat,
       detcomprobruc=''''           
from ['+@BaseVenta+'].dbo.vt_pedido B,
     ['+@BaseParam+'].dbo.vt_pasientocab C,['+@BaseParam+'].dbo.vt_pasientodet D,    
     ['+@BaseConta+'].dbo.gr_documento gd          
Where     
    B.pedidotipofac=C.tipodoc and 
	 B.pedidotipofac=D.tipodoc and 
	 B.pedidotipofac=gd.documentocodigo AND 	
    B.pedidotipofac <> ''80'' and   
    Left(b.pedidonrofact,3)=D.serie and 
    Month(B.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano 
Set @SqlCad=@SqlCad+'
Union All
Select
	   numprovi=B.pedidonumero,
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero='' '',
       subasientocodigo=d.subasiento,
       analiticocodigo=Left(case when B.pedidotipofac=''01'' 
         then case when isnull(rtrim(ltrim(B.clienteruc)),'''') ='''' then B.clientecodigo else B.clienteruc end 
         else B.clientecodigo End,11)+'''+@tipanal+''',
       asientocodigo=C.Asiento,detcomprobitem=''00002'',monedacodigo=B.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=B.pedidotipofac,operacioncodigo=''01'',cuentacodigo='''+@ctatotal+''',
       detcomprobnumdocumento=left(B.pedidonrofact,3)+''-''+right(B.pedidonrofact,8),
       detcomprobfechaemision=B.pedidofechafact ,
       detcomprobfechavencimiento=B.pedidofechafact ,
       detcomprobglosa=B.clienterazonsocial,                 
	   detcomprobdebe=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''01'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobhaber=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''01'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobusshaber=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when B.PedidoMoneda=''02'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT B.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when B.PedidoMoneda=''02'' then B.pedidototneto else 0 end else 0 end end,                         
       detcomprobtipocambio=cast(0 as numeric(20,4)), 
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=B.pedidofechasunat,
       detcomprobruc=B.clienteruc            
from ['+@BaseVenta+'].dbo.vt_pedido B,
     ['+@BaseParam+'].dbo.vt_pasientocab C,['+@BaseParam+'].dbo.vt_pasientodet D,    
     ['+@BaseConta+'].dbo.gr_documento gd     
Where     
     B.pedidotipofac=C.tipodoc and 
	 B.pedidotipofac=D.tipodoc and 
	 B.pedidotipofac=gd.documentocodigo AND 
     B.pedidotipofac <> ''80'' and   
     Left(b.pedidonrofact,3)=D.serie and 
     Month(B.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano+')  As XX  ' 
Exec(@SqlCad) 
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
 
 select MaxAsi=asientonumcorr'+@MES+',A.Asiento,Ultimo=asientonumcorr'+@MES+' 
 Into [##tmpcorrela'+@compu+']
 from ['+@BaseParam+'].dbo.vt_pasientocab A,['+@BaseConta+'].dbo.ct_asientocorre B
 where 
	  B.asientoanno='''+@Ano+''' and 	
      A.Asiento =  B.asientocodigo ' 
EXEC(@SqlCad)
--Exec(@SqlCad)
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
   Where A.Asientocodigo=B.Asiento and 
         ltrim(rtrim(numprovi))=ltrim(rtrim(@Numprovi))
   
   Update  [##tmpcorrela'+@compu+'] 
   Set  Ultimo=ISNULL(Ultimo,0)+1 
   Where  Asiento=@Asiento
   fetch next from Correla into @Asiento,@Numprovi		
End
Close Correla
Deallocate Correla '
EXEC(@SqlCad)     
--exec(@SqlCad)
--Poner el tipo de Cambio
Set @SqlCad2=' '+ 
'Update [##tmpgenasientodet'+@compu+']
 Set
     detcomprobtipocambio=C.tipocambioventa,
     detcomprobformacambio=''02'',
     detcomprobdebe=isnull(case when A.monedacodigo =''01'' then  A.detcomprobdebe else round(A.detcomprobussdebe* C.tipocambioventa,2) end,0) ,
     detcomprobussdebe=isnull(case when A.monedacodigo =''02'' then  A.detcomprobussdebe else round(A.detcomprobdebe/C.tipocambioventa,2) end,0), 
     detcomprobhaber=isnull(case when A.monedacodigo =''01'' then  A.detcomprobhaber else round(A.detcomprobusshaber*C.tipocambioventa,2) end,0), 
     detcomprobusshaber=isnull(case when A.monedacodigo =''02'' then  A.detcomprobusshaber else round(A.detcomprobhaber/C.tipocambioventa,2) end,0)   
 From [##tmpgenasientodet'+@compu+'] A,
              ['+@baseconta+'].dbo.gr_documento B,
              ['+@baseconta+'].dbo.ct_tipocambio C
 Where A.documentocodigo =B.documentocodigo and  
      (Case When B.documentonotacredito=0 then A.detcomprobfechaemision 
       Else A.detcomprobfecharef end) =C.tipocambiofecha ' 
Exec(@SqlCad2)
--Exec(@SqlCad2)
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
Exec(@SqlCad2)
--Exec(@SqlCad2)
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
        ''FAC''+numprovi  
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
       left(ltrim(rtrim(A.detcomprobglosa)),50), A.detcomprobdebe, A.detcomprobhaber, A.detcomprobusshaber, A.detcomprobussdebe,
       A.detcomprobtipocambio, A.detcomprobruc, A.detcomprobauto, A.detcomprobformacambio,
       A.detcomprobajusteuser, A.plantillaasientoinafecto,
       tipdocref= case when rtrim(isnull(A.tipdocref,''00''))='''' then ''00'' else isnull(A.tipdocref,''00'') end,
       A.detcomprobnumref, A.detcomprobconci, 
       comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+B.correlibro))+ltrim(rtrim(cast(@MaxLibro+B.correlibro as varchar(20))))
       , A.detcomprobfecharef
from [##tmpgenasientodet'+@compu+'] A, 
     [##tmpgenasientocab'+@compu+'] B     
Where ltrim(rtrim(A.numprovi))=rtrim(ltrim(B.numprovi))
 '
exec(@SqlCad2)
--Exec(@SqlCad2)
--Generar Automaticos 
--Generando Asientos Automaticos y Calculando el total del comprobante
Declare @Xcabcomprobnumero varchar(10),@Xasientocodigo varchar(3),
        @Xsubasientocodigo varchar(4),@Xtabla varchar(50)
Set @Xtabla='ct_detcomprob'+@Ano
set @Sqlcad='Declare GenAuto Cursor for 
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
    --Print  @Xasientocodigo +' '+@Xsubasientocodigo+' '+@Xcabcomprobnumero
    Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo	
End
Close GenAuto
Deallocate GenAuto
--Se actualizo el numero de comprobante en la cabecera de provisiones
/*Set @SqlCad=''+
'Update ['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' 
Set cabprovinconta=C.cabcomprobnumero 
from ['+@BaseCompra+'].dbo.co_cabprovi'+@Ano+' A, 
              ##tmpgenasientocab'+@COMPU+' B,
              ['+@BaseConta+'].dbo.ct_cabcomprob2002 C 
Where 
       A.cabprovinumero=  B.numprovi as BigInt  and 
       A.cabprovinumero=cast(C.cabcomprobnprovi as BigInt) '
Exec(@SqlCad)*/
--Actualizar Correlativos de Asientos 
Set @SqlCad=''+
'Update ['+@BaseConta+'].dbo.ct_asientocorre 
 Set asientonumcorr'+@Mes+'= B.Ultimo
 From  
 ['+@BaseConta+'].dbo.ct_asientocorre A,
 [##tmpcorrela'+@Compu+'] B
 Where A.asientocodigo   =B.Asiento and 
       A.asientoanno='''+@Ano+'''  
  '  
Exec(@SqlCad) 
--Actualiza correlativo de Libros
Set @SqlCad=''+
'Update  ['+@BaseConta+'].dbo.ct_librocorre
 Set libronumcorr'+@Mes+'=libronumcorr'+@Mes+'+ 
           (Select count(*)  from ##tmpgenasientocab'+@COMPU+') 
 Where librocodigo='''+@Libro+''' and  libroanno='''+@Ano+''''
Exec(@SqlCad)
--exec vt_generaasiento_pro 'Contaprueba','Transfer','camtex_tinto','03','05','2003','121101','401110','002','Desarrollo3','sa'
--exec vt_generaasiento_pro 'Contaprueba','ventas_prueba','VENTAS_PRUEBA','03','03','2003','121101','401110','002','Desarrollo3','sa'
--exec vt_insertacliente 'Contaprueba','Ventas_Prueba','03','2003','002','Desarrollo3'
GO
