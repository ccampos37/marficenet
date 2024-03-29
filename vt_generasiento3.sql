SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
exec vt_generaasiento1_pro 'DEMO','DEMO','DEMO','12','01','07','2008','1211','4011','001','##Desarrollo3','sa'
SELECT * FROM GREMCO.dbo.CT_CUENTA ORDER BY 2
SELECT * FROM demo.dbo.CT_cabcOMPROB2008 WHERE ASIENTOCODIGO='001' AND CABCOMPROBMES=7 and empresacodigo='12'
SELECT * FROM GREMCO.dbo.CT_ASIENTO
SELECT * FROM GREMCO.DBO.MAEART

*/
---  x familia

create PROC [vt_generaasiento3_pro]

--Declare
  @BaseConta	Varchar(100),
  @BaseVenta 	varchar(100),  
  @BaseParam	varchar(100),
  @empresa      varchar(2),
  @Libro   		varchar(2),         
  @Mes     		varchar(2),
  @Ano     		varchar(4),
  @ctasoles     varchar(20),
  @ctadolares   varchar(20),
  @ctaIGV       varchar(20),  
  @tipanal      varchar(3), 
  @Compu   		varchar(50),
  @Usuario 		varchar(20)          
AS
-- Crear los SubAsiento por familia 

Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000) 


Set @SqlCad='
Delete ['+@BaseConta+'].dbo.ct_cabcomprob'+@ano+' 
Where empresacodigo+cabcomprobnprovi in ( select EMPRESACODIGO+pedidonumero from ['+@BaseVenta+'].dbo.vt_pedido A  
     Where  empresacodigo='''+@empresa+''' and  Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano+')
     and empresacodigo='''+@empresa+''' and subasientocodigo=''0099'' and cabcomprobmes='''+@mes+''' '

EXECUTE(@SqlCad)

Set @SqlCad=''+
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select a.empresacodigo,numprovi=A.pedidonumero,
        cabcomprobmes='''+@MES+''' ,
        cabcomprobnumero=cast(''0'' as bigint) ,
        correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=A.pedidofechafact,
        subasientocodigo=''0099'',usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo=''001'' ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Nro de Pedido''+rtrim(A.pedidonumero),
        cabcomprobtotdebe=0,
        cabcomprobtothaber=0,
        cabcomprobtotussdebe=0,
        cabcomprobtotusshaber=0,cabcomprobgrabada=0,cabcomprobnref='' '',
        cabcomprobnlibro=0 Into [##tmpgenasientocab'+@Compu+'] 
 From   ['+@BaseVenta+'].dbo.vt_pedido A
        inner join ['+@Baseventa+'].dbo.vt_detallepedido b 
		on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero 
        inner join ['+@Baseventa+'].dbo.maeart c on b.productocodigo=c.acodigo 
        left join 
 where a.empresacodigo='''+@empresa+''' and A.pedidotipofac <>''80'' and Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano

EXECUTE(@SqlCad) 
--Que fecha de referencia es grabarla al final
Set @SqlCad='
 --Item del Importe Bruto Armando las cuenta 70
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
  
Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 (select A.empresacodigo,
	   numprovi=A.pedidonumero,	
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero=cast(''0'' as bigint),
       subasientocodigo=''0099'',
       analiticocodigo=''00'',
       asientocodigo=''001'',detcomprobitem=''00001'',monedacodigo=A.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=A.pedidotipofac,operacioncodigo=''01'',
       cuentacodigo=case when isnull(gd.documentonotacredito,0)=0 then fa.fam_haber else fa.fam_haber end ,
       detcomprobnumdocumento=A.pedidonrofact,
       detcomprobfechaemision=A.pedidofechafact ,
       detcomprobfechavencimiento=A.pedidofechafact ,detcomprobglosa=''Nro de Pedido ''+rtrim(A.pedidonumero),         
       detcomprobdebe=Case When  NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''01'' then A.pedidototbruto else 0 end else 0 end  end,
       detcomprobhaber=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''01'' then A.pedidototbruto else 0 end else 0 end  end,
       detcomprobusshaber=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''02'' then A.pedidototbruto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT  A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''02'' then A.pedidototbruto else 0 end else 0 end end,        
       detcomprobtipocambio=cast(0 as numeric(20,4)), detcomprobauto=0, detcomprobformacambio=''02'',detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.pedidotiporefe, detcomprobnumref=A.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,detcomprobfecharef=A.pedidofechasunat,
       detcomprobruc=''''            
 From   ['+@BaseVenta+'].dbo.vt_pedido A
        inner join ['+@Baseventa+'].dbo.vt_detallepedido b on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero 
        inner join ['+@Baseventa+'].dbo.maeart c on b.productocodigo=c.acodigo 
        left join ['+@Baseventa+'].dbo.familia fa on c.afamilia=fa.fam_codigo
        inner join ['+@Baseventa+'].dbo.gr_documento gd  on A.pedidotipofac=gd.documentocodigo    
Where A.empresacodigo='''+@empresa+''' and A.pedidotipofac <> ''80'' and  
     Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano     
Set @SqlCad=@SqlCad+'
  Union all 
--Registro del IGV
Select A.empresacodigo,
       numprovi=A.pedidonumero,	
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero='' '',
       subasientocodigo=''0099'',
       analiticocodigo=''00'',
       asientocodigo=''001'',detcomprobitem=''00002'',monedacodigo=A.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=A.pedidotipofac,operacioncodigo=''01'',cuentacodigo='''+@ctaIGV+''',
       detcomprobnumdocumento=A.pedidonrofact,
       detcomprobfechaemision=A.pedidofechafact ,
       detcomprobfechavencimiento=A.pedidofechafact ,detcomprobglosa=''Nro de Pedido ''+rtrim(A.pedidonumero),        
       detcomprobdebe=Case When NOT  A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''01'' then A.pedidototimpuesto else 0 end else 0 end  end,
       detcomprobhaber=Case When NOT  A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''01'' then A.pedidototimpuesto else 0 end else 0 end end,
       detcomprobusshaber=Case When NOT  A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''02'' then A.pedidototimpuesto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT  A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''02'' then A.pedidototimpuesto else 0 end else 0 end end,                  
       detcomprobtipocambio=cast(0 as numeric(20,4)), 
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.pedidotiporefe, detcomprobnumref=A.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.pedidofechasunat,
       detcomprobruc=''''           
 From   ['+@BaseVenta+'].dbo.vt_pedido A
        inner join ['+@Baseventa+'].dbo.vt_detallepedido b on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero 
        inner join ['+@Baseventa+'].dbo.maeart c on b.productocodigo=c.acodigo 
        inner join ['+@Baseventa+'].dbo.gr_documento gd  on A.pedidotipofac=gd.documentocodigo    
Where    A.empresacodigo='''+@EMPRESA+''' and A.pedidotipofac <> ''80'' and 
    Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano 
Set @SqlCad=@SqlCad+'
Union All
Select A.empresacodigo,
       numprovi=A.pedidonumero,
       cabcomprobmes='''+@MES+''',
       cabcomprobnumero='' '',
       subasientocodigo=''0099'',
       analiticocodigo=Left(case when A.pedidotipofac=''01'' 
      	   then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
         	else A.clientecodigo End,11)+'''+@tipanal+''',
       asientocodigo=''001'',detcomprobitem=''00002'',monedacodigo=A.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=A.pedidotipofac,operacioncodigo=''01'',
       cuentacodigo=case when a.pedidomoneda=''01'' then '''+@ctasoles+''' else '''+@ctadolares+''' end ,
       detcomprobnumdocumento=A.pedidonrofact,
       detcomprobfechaemision=A.pedidofechafact ,
       detcomprobfechavencimiento=A.pedidofechafact ,
       detcomprobglosa=A.clienterazonsocial,                 
	    detcomprobdebe=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''01'' then A.pedidototneto else 0 end else 0 end end,
       detcomprobhaber=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''01'' then A.pedidototneto else 0 end else 0 end end,
       detcomprobusshaber=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)<>0 then  Case when A.PedidoMoneda=''02'' then A.pedidototneto else 0 end else 0 end end,
       detcomprobussdebe=Case When NOT A.pedidofechaanu is null then 0 else case when isnull(gd.documentonotacredito,0)=0 then  Case when A.PedidoMoneda=''02'' then A.pedidototneto else 0 end else 0 end end,                         
       detcomprobtipocambio=cast(0 as numeric(20,4)), 
       detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, 
		 plantillaasientoinafecto=0,
       tipdocref=A.pedidotiporefe, detcomprobnumref=A.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.pedidofechasunat,
       detcomprobruc=A.clienteruc            
 From   ['+@BaseVenta+'].dbo.vt_pedido A
        inner join ['+@Baseventa+'].dbo.vt_detallepedido b on a.empresacodigo=b.empresacodigo and a.pedidonumero=b.pedidonumero 
        inner join ['+@Baseventa+'].dbo.maeart c on b.productocodigo=c.acodigo 
        inner join ['+@Baseventa+'].dbo.gr_documento gd  on A.pedidotipofac=gd.documentocodigo    
Where   A.empresacodigo='''+@EMPRESA+''' AND A.pedidotipofac <> ''80'' and   
         Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano+')  As XX  ' 

EXECUTE (@SqlCad) 

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
 
 select MaxAsi=asientonumcorr'+@MES+',Asiento=asientocodigo,Ultimo=asientonumcorr'+@MES+' 
 Into [##tmpcorrela'+@compu+']
 from ['+@BaseConta+'].dbo.ct_asientocorre 
 where empresacodigo='''+@empresa+''' and asientoanno='''+@Ano+''' and 	
      Asientocodigo = ''001'' ' 
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

execute(@SqlCad2)

--Exec(@SqlCad2)

Set @SqlCad2='
 Declare @MaxLibro Bigint
 Select @MaxLibro=libronumcorr'+@mes+' from '+@BaseConta+'.dbo.ct_librocorre 
 where  empresacodigo='''+@empresa+''' and librocodigo='''+@Libro+''' and libroanno='''+@Ano+''' 
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
        cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber, cabcomprobtotussdebe, 
        cabcomprobtotusshaber, cabcomprobgrabada, cabcomprobnref,
        comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+correlibro))+ltrim(rtrim(cast(@MaxLibro+correlibro as varchar(20)))),
        numprovi  
 from [##tmpgenasientocab'+@compu+'] A 
     
Insert Into ['+@BaseConta+'].dbo.ct_detcomprob'+@Ano+'
(empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
 detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,
 cuentacodigo, detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
 detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe,
 detcomprobtipocambio, detcomprobruc, detcomprobauto, detcomprobformacambio,
 detcomprobajusteuser, plantillaasientoinafecto, tipdocref,
 detcomprobnumref, detcomprobconci, detcomprobnlibro, detcomprobfecharef)
Select a.empresacodigo,A.cabcomprobmes, 
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
execute(@SqlCad2)

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
    Exec ct_grabaautomatico_pro @baseconta,@Xtabla,@empresa,@mes,
    @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo                                   
   	
    Exec ct_CalcComprob_pro '',@baseconta,@empresa,@Ano,@mes,
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
