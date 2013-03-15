SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec [vt_generaasiento_pro] 'ziyaz','ziyaz','ziyaz','02','01','05','2011','121100','401110','002','##Desarrollo3','sa'
SELECT * FROM ziyaz.dbo.vt_pedido
planta_casma.dbo.ct_cabcomprob2008

*/


CREATE                             PROC [vt_generaasiento_pro]
--Declare
  @BaseConta	Varchar(100),
  @BaseVenta 	varchar(100),  
  @BaseParam	varchar(100),
  @empresa      varchar(2),
  @Libro   		varchar(2),         
  @Mes     		varchar(2),
  @Ano     		varchar(4),
  @ctatotal     varchar(20),
  @ctaIGV       varchar(20),  
  @tipanal      varchar(3), 
  @Compu   		varchar(50),
  @Usuario 		varchar(20)          
AS
--Crear los SubAsiento por Serie

Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000) 

--Elimino los asientos existente

Set @SqlCad='
Delete ['+@BaseConta+'].dbo.ct_cabcomprob'+@ano+' 
Where right(rtrim(cabcomprobnprovi),len(rtrim(cabcomprobnprovi))-3) in ( select pedidonumero from ['+@BaseVenta+'].dbo.vt_pedido A  
     Where  empresacodigo='''+@empresa+''' and  Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano+' ) '
     
execute(@SqlCad)

--actualizo RUC 

Set @SqlCad='
update ['+@BaseVenta +'].dbo.vt_pedido set clienteruc=b.clienteruc
from ['+@BaseVenta +'].dbo.vt_pedido a , ['+@BaseVenta +'].dbo.vt_cliente b Where a.clientecodigo=b.clientecodigo   
     and  a.empresacodigo='''+@empresa+''' and  Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano+' '
execute (@SqlCad)


Set @SqlCad=''+
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select a.empresacodigo,numprovi=A.pedidonumero,cabcomprobmes='''+@MES+''' ,cabcomprobnumero=cast(''0'' as bigint) ,
        correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=A.pedidofechafact,
        subasientocodigo=D.subasiento,usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo=co.Asiento ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Nro de Pedido ''+rtrim(A.pedidonumero),
        cabcomprobtotdebe=0,
        cabcomprobtothaber=0,
        cabcomprobtotussdebe=0,
        cabcomprobtotusshaber=0,cabcomprobgrabada=0,cabcomprobnref='' '',
        cabcomprobnlibro=0 Into [##tmpgenasientocab'+@Compu+'] 
  From  ['+@BaseVenta+'].dbo.vt_pedido A
  inner join ['+@BaseVenta+'].dbo.vt_pasientocab co on  A.pedidotipofac=co.Tipodoc and a.empresacodigo=co.empresacodigo 
  inner join ['+@BaseVenta+'].dbo.vt_pasientodet D on a.empresacodigo=d.empresacodigo and A.pedidotipofac=D.tipodoc and Left(A.pedidonrofact,3)=D.serie 
        where a.empresacodigo='''+@empresa+''' and Month(A.pedidofechafact)='+@Mes+' and Year(A.pedidofechafact)='+@Ano

execute (@SqlCad) 
--Que fecha de referencia es grabarla al final
Set @SqlCad='
 --Item del Importe Bruto Armando las cuenta 70
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
  
Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 (select b.empresacodigo,  numprovi=B.pedidonumero,cabcomprobmes='''+@MES+''',cabcomprobnumero='' '',
       subasientocodigo=d.subasiento,analiticocodigo=''00'',asientocodigo=Co.Asiento,detcomprobitem=''00001'',monedacodigo=B.PedidoMoneda,
       centrocostocodigo=''00'',
       documentocodigo=case when isnull(gd.tdocumentosunat,'''')<>'''' then gd.tdocumentosunat 
                       else B.pedidotipofac end ,
       operacioncodigo=case when isnull(pedidocondicionfactura,0)=1 then ''19'' else ''01'' end,
       cuentacodigo=D.cuenta,detcomprobnumdocumento=B.pedidonrofact,detcomprobfechaemision=B.pedidofechafact ,
       detcomprobfechavencimiento=B.pedidofechafact ,detcomprobglosa=''Nro de Pedido''+rtrim(B.pedidonumero),         
       detcomprobdebe=Case When  isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''01'' then round(B.pedidototneto-b.pedidototimpuesto,2) else 0 end else 0 end  end,
       detcomprobhaber=Case When isnull(pedidocondicionfactura,0)=1  then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''01'' then round(B.pedidototneto-b.pedidototimpuesto,2) else 0 end else 0 end  end,
       detcomprobusshaber=Case When isnull(pedidocondicionfactura,0)=1  then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''02'' then round(B.pedidototneto-b.pedidototimpuesto,2) else 0 end else 0 end end,
       detcomprobussdebe=Case When isnull(pedidocondicionfactura,0)=1  then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''02'' then round(B.pedidototneto-b.pedidototimpuesto,2) else 0 end else 0 end end,        
       detcomprobtipocambio=cast(0 as numeric(20,4)), detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0, tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' , detcomprobfecharef=B.pedidofechasunat,detcomprobruc=''''            
  From  ['+@BaseVenta+'].dbo.vt_pedido b
  inner join ['+@BaseVenta+'].dbo.vt_pasientocab co on  b.pedidotipofac=co.Tipodoc and b.empresacodigo=co.empresacodigo 
  inner join ['+@BaseVenta+'].dbo.vt_pasientodet D on b.empresacodigo=d.empresacodigo 
     and b.pedidotipofac=D.tipodoc and Left(b.pedidonrofact,3)=D.serie 
  inner join ['+@BaseConta+'].dbo.cc_tipodocumento gd on b.pedidotipofac=gd.tdocumentocodigo   
 Where b.empresacodigo='''+@empresa+''' and Month(b.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano     
Set @SqlCad=@SqlCad+'
  Union all 
--Registro del IGV
Select b.empresacodigo,numprovi=B.pedidonumero,cabcomprobmes='''+@MES+''',cabcomprobnumero='' '', subasientocodigo=d.subasiento,
       analiticocodigo=''00'',asientocodigo=Co.Asiento,detcomprobitem=''00002'',monedacodigo=B.PedidoMoneda,centrocostocodigo=''00'',
       documentocodigo=case when isnull(gd.tdocumentosunat,'''')<>'''' then gd.tdocumentosunat 
                       else B.pedidotipofac end ,
       operacioncodigo=case when isnull(pedidocondicionfactura,0)=1 then ''19'' else ''01'' end,
       cuentacodigo='''+@ctaIGV+''',detcomprobnumdocumento=B.pedidonrofact,detcomprobfechaemision=B.pedidofechafact ,
       detcomprobfechavencimiento=B.pedidofechafact ,detcomprobglosa=''Nro de Pedido''+rtrim(B.pedidonumero),        
       detcomprobdebe=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''01'' then B.pedidototimpuesto else 0 end else 0 end  end,
       detcomprobhaber=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''01'' then B.pedidototimpuesto else 0 end else 0 end end,
       detcomprobusshaber=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''02'' then B.pedidototimpuesto else 0 end else 0 end end,
       detcomprobussdebe=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''02'' then B.pedidototimpuesto else 0 end else 0 end end,                  
       detcomprobtipocambio=cast(0 as numeric(20,4)),  detcomprobauto=0, detcomprobformacambio=''02'', detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,detcomprobconci=0, detcomprobnlibro='' '' , detcomprobfecharef=B.pedidofechasunat, detcomprobruc=''''           
  From  ['+@BaseVenta+'].dbo.vt_pedido b
  inner join ['+@BaseVenta+'].dbo.vt_pasientocab co on  b.pedidotipofac=co.Tipodoc and b.empresacodigo=co.empresacodigo 
  inner join ['+@BaseVenta+'].dbo.vt_pasientodet D on b.empresacodigo=d.empresacodigo 
     and b.pedidotipofac=D.tipodoc and Left(b.pedidonrofact,3)=D.serie 
  inner join ['+@BaseConta+'].dbo.cc_tipodocumento gd on b.pedidotipofac=gd.tdocumentocodigo   
Where    b.empresacodigo='''+@EMPRESA+''' AND  Month(b.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano 
Set @SqlCad=@SqlCad+'
Union All
Select b.empresacodigo,numprovi=B.pedidonumero,cabcomprobmes='''+@MES+''',cabcomprobnumero='' '', subasientocodigo=d.subasiento,
       analiticocodigo=case when isnull(rtrim(ltrim(B.clienteruc)),'''') ='''' then rtrim(B.clientecodigo) else rtrim(B.clienteruc) end+'''+@tipanal+''',
       asientocodigo=Co.Asiento,detcomprobitem=''00003'',monedacodigo=B.PedidoMoneda, centrocostocodigo=''00'',
       documentocodigo=case when isnull(gd.tdocumentosunat,'''')<>'''' then gd.tdocumentosunat else B.pedidotipofac end ,
       operacioncodigo=case when isnull(pedidocondicionfactura,0)=1 then ''19'' else ''01'' end,
       cuentacodigo=case when b.pedidomoneda=''02'' then gd.tdocumentocuentadolares else tdocumentocuentasoles end, 
       detcomprobnumdocumento=B.pedidonrofact,detcomprobfechaemision=B.pedidofechafact , detcomprobfechavencimiento=B.pedidofechafact ,
       detcomprobglosa=case when isnull(pedidocondicionfactura,0)=1 then '' A N U L A D O '' else B.clienterazonsocial end,                 
	    detcomprobdebe=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''01'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobhaber=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''01'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobusshaber=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)<>0 then  Case when B.PedidoMoneda=''02'' then B.pedidototneto else 0 end else 0 end end,
       detcomprobussdebe=Case When isnull(pedidocondicionfactura,0)=1 then 0 else case when isnull(gd.tdocumentonotaconta,0)=0 then  Case when B.PedidoMoneda=''02'' then B.pedidototneto else 0 end else 0 end end,                         
       detcomprobtipocambio=cast(0 as numeric(20,4)), detcomprobauto=0, detcomprobformacambio=''02'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,tipdocref=B.pedidotiporefe, detcomprobnumref=B.pedidonrorefe,
       detcomprobconci=0, detcomprobnlibro='' '' , detcomprobfecharef=B.pedidofechasunat,detcomprobruc=B.clienteruc            
  From  ['+@BaseVenta+'].dbo.vt_pedido b
  inner join ['+@BaseVenta+'].dbo.vt_pasientocab co on b.empresacodigo=co.empresacodigo and b.pedidotipofac=co.Tipodoc   
  inner join ['+@BaseVenta+'].dbo.vt_pasientodet D on b.empresacodigo=d.empresacodigo and b.pedidotipofac=D.tipodoc and Left(b.pedidonrofact,3)=D.serie 
  inner join ['+@BaseConta+'].dbo.cc_tipodocumento gd on b.pedidotipofac=gd.tdocumentocodigo    
Where   b.empresacodigo='''+@EMPRESA+''' AND  Month(B.pedidofechafact)='+@Mes+' and Year(B.pedidofechafact)='+@Ano+')  As XX  ' 

execute (@SqlCad) 
/*
--Actualiza las Facturas Inafectas
set @SqlCad='
	update ##tmpgenasientodet' +@compu+ ' set plantillaasientoinafecto=1
		where cabcomprobnumero in 
			(select cabcomprobnumero from ##tmpgenasientodet'+@compu+ ' 
				where asientocodigo like ''07%'' and 
					and cuentacodigo=' +@ctaIGV+ ' and detcomprobhaber=0)
		and cuentacodigo like ''70%'' and detcomprobhaber>0
order by detcomprobnumdocumento'
Exec (@SqlCad)
*/
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

execute(@SqlCad)     

--exec(@SqlCad)
--Poner el tipo de Cambio
Set @SqlCad2=' '+ 
'Update [##tmpgenasientodet'+@compu+']
 Set
     detcomprobtipocambio=C.tipocambioventa,
     detcomprobformacambio=''02'',
     detcomprobdebe=isnull(case when A.monedacodigo =''01'' then  A.detcomprobdebe else round(A.detcomprobussdebe* C.tipocambioventa,2) end,0) ,
     detcomprobhaber=isnull(case when A.monedacodigo =''01'' then  A.detcomprobhaber else round(A.detcomprobusshaber*C.tipocambioventa,2) end,0), 
     detcomprobussdebe=isnull(case when A.monedacodigo =''02'' then  A.detcomprobussdebe else round(A.detcomprobdebe/C.tipocambioventa,2) end,0), 
     detcomprobusshaber=isnull(case when A.monedacodigo =''02'' then  A.detcomprobusshaber else round(A.detcomprobhaber/C.tipocambioventa,2) end,0)   
 From [##tmpgenasientodet'+@compu+'] A,
              ['+@baseconta+'].dbo.gr_documento B,
              ['+@baseconta+'].dbo.ct_tipocambio C
 Where A.documentocodigo =B.documentocodigo and  
      (Case When B.documentonotacredito=0 then A.detcomprobfechaemision 
       Else A.detcomprobfecharef end) =C.tipocambiofecha ' 
execute(@SqlCad2)



--- ajuste x diferencia de error en conversion de moneda

Set @SqlCad2='Update [##tmpgenasientodet'+@compu+']
 Set detcomprobhaber =case when detcomprobhaber > 0 then detcomprobhaber - b.saldo
                    else detcomprobhaber end,
     detcomprobdebe =case when detcomprobdebe  > 0 then detcomprobdebe +b.saldo
                     else detcomprobdebe  end
 from [##tmpgenasientodet'+@compu+'] a , ( select empresacodigo,numprovi,saldo=round(sum(detcomprobhaber),2)-round(sum(detcomprobdebe),2)
       from [##tmpgenasientodet'+@compu+'] group by empresacodigo , numprovi
             having round(sum(detcomprobhaber),2)-round(sum(detcomprobdebe),2) <> 0 ) b
 Where left( a.cuentacodigo,2)=''40'' and a.empresacodigo=b.empresacodigo and a.numprovi=b.numprovi '

execute(@SqlCad2)

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
        ''FAC''+numprovi  
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
GO
