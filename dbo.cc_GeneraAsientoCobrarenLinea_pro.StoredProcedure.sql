SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute cc_GeneraAsientoCobrarenLinea_pro 'ziyaz','ziyaz','02','045','0099','05','02','2010','002','xx','sa','77777','8888'

select * from aliterm.dbo.ct_detcomprob2008 where asientocodigo='040'

*/

CREATE        proc [cc_GeneraAsientoCobrarenLinea_pro] 
--Declare 
  @Baseconta 	varchar(100),
  @Baseventa   varchar(100),
  @empresa     varchar(2),
  @Asiento	   varchar(15), 
  @SubAsiento 	varchar(15),
  @Libro   		varchar(2),         
  @Mes     		varchar(2),
  @Ano     		varchar(4),        
  @tipanal     varchar(3), 
  @Compu   	varchar(50),
  @Usuario 	varchar(20),
  @ajustedebe  varchar(20),
  @ajustehaber varchar(20)

as    
exec cc_GeneraTempAsientoCobrarenLinea_pro @Baseventa,@empresa,@Mes,@Ano,'%',@Baseconta,@ajustehaber,@ajustedebe,@Compu
Declare @SqlCad varchar(8000),@SqlCad2 varchar(8000)
Set @SqlCad=
'If Exists(Select name from tempdb..sysobjects where name=''##tmpcobasientocab'+@compu+''') 
    Drop Table [##tmpcobasientocab'+@compu+'] 
 Select correlibro=IDENTITY(bigint,1,1),z.*   Into [##tmpcobasientocab'+@Compu+']
from
   ( select distinct empresacodigo,numprovi=A.numide,
        cabcomprobmes='+@Mes+',
        cabcomprobnumero=cast(''0'' as bigint),
        cabcomprobfeccontable=A.FecCanAbono,
        subasientocodigo='''+@SubAsiento+''',usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo='''+@Asiento+'''   ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''P. de Aplicaciones ''+A.PlanillaAbono,
        cabcomprobtotdebe=0,
        cabcomprobtothaber=0,
        cabcomprobtotussdebe=0,
        cabcomprobtotusshaber=0,cabcomprobgrabada=0,cabcomprobnref='' '',
        cabcomprobnlibro=0  
    From   [##tmp_conta'+@Compu+'] A
    Group by a.empresacodigo,A.numide,A.FecCanAbono, A.PlanillaAbono ) z '

execute(@SqlCad) 

Set @SqlCad='
 --Seleccion del Detalle
 If Exists(Select name from tempdb..sysobjects where name=''##tmpcobasientodet'+@compu+''') 
    Drop Table [##tmpcobasientodet'+@compu+']  
  
 Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpcobasientodet'+@Compu+'] From 
 (select empresacodigo,numprovi=A.numide,
       cabcomprobmes='+@Mes+',
       cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=A.CodCliente,                      
       asientocodigo='''+@Asiento+''',detcomprobitem=Replicate(''0'',5-len(A.Item))+rtrim(ltrim(cast(A.Item as varchar(10)))),monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',
       documentocodigo=A.DocCargo,operacioncodigo=''01'',cuentacodigo=A.cuenta,
       detcomprobnumdocumento=A.NumDocCargo,
		 detcomprobfechaemision=case when A.Item=''1'' then A.FecEmisionCargo else A.FecCanAbono end,
       detcomprobfechavencimiento=A.FecEmisionCargo,detcomprobglosa=''P. de Cobranza ''+A.PlanillaAbono,            
       detcomprobdebe=isnull(A.cargo ,0),
       detcomprobhaber=isnull(A.abono,0),
       detcomprobussdebe=case when isnull(A.cargo,0) > 0 then
                  isnull(Case when A.monedacodigo=''02'' then importeabono else A.abono /tccancela end,0) else 0 end ,
       detcomprobusshaber=case when isnull(A.abono  ,0) > 0 then 
                          isnull(Case when A.monedacodigo=''02'' then importeabono else A.cargo /tccancela end,0) else 0 end ,
       detcomprobtipocambio=1 , detcomprobruc=space(11),
       detcomprobauto=0, detcomprobformacambio=''01'', 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=space(2), detcomprobnumref=space(11),
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=null,cabprovinconta=A.PlanillaAbono
from  [##tmp_conta'+@compu+']  A
     ) as XX '     

execute(@SqlCad) 

exec cc_insertanalitico_pro @Baseconta,@Baseventa,@Compu  
Declare @CtaReg BigInt
Exec('
Declare CuentaReg Cursor for 
Select CtaReg=Count(*) From [##tmpcobasientocab'+@compu+']')
Open CuentaReg
Fetch Next from CuentaReg into @CtaReg
Close CuentaReg
Deallocate CuentaReg
If @CtaReg=0 
Begin
   Print 'No Existen Registros para generar a contabilidad '	
-- Return 0
End
--El correlativo es por libros 
--se tiene generar un temporal por cada asiento y su correlativo
--para cada correlativo de cada libro
--collate  Modern_Spanish_CI_AI
SET @SqlCad='
 If Exists(Select name from tempdb..sysobjects where name=''##tmpcorrela'+@compu+''') 
    Drop Table [##tmpcorrela'+@compu+']  
 
 select MaxAsi=asientonumcorr'+@MES+',asiento2=asientocodigo,Ultimo=asientonumcorr'+@MES+' 
 Into [##tmpcorrela'+@compu+'] from ['+@BaseConta+'].dbo.ct_asientocorre 
 where  empresacodigo='''+@empresa+''' and asientoanno='''+@Ano+''' ' 
EXEC(@SqlCad)
SET @SqlCad='  
Declare @Asiento varchar(3),@Numprovi bigint
Declare Correla cursor for 
select asientocodigo,numprovi from [##tmpcobasientocab'+@compu+']
order by asientocodigo
Open Correla
fetch next from Correla into @Asiento,@Numprovi
While @@Fetch_Status=0 
Begin 
   update [##tmpcobasientocab'+@compu+']
   set cabcomprobnumero=isnull(B.Ultimo,0) +1
   From  [##tmpcobasientocab'+@compu+'] A,
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
--exec(@SqlCad)
Set @SqlCad2=' '+ 
'Update [##tmpcobasientodet'+@compu+']
 Set
     detcomprobtipocambio=tipocambioventa,
     detcomprobformacambio=''02'',
     detcomprobdebe=isnull(case when A.monedacodigo =''01''     then  A.detcomprobdebe else Case when left(A.cuentacodigo,2) in (''77'',''97'') then 0 else round(A.detcomprobussdebe*tipocambioventa,2) end end  ,0)   ,
     detcomprobussdebe=isnull(case when A.monedacodigo =''02''  then  A.detcomprobussdebe else Case when left(A.cuentacodigo,2) in (''77'',''97'') then  0 else round(A.detcomprobdebe/tipocambioventa,2) end end ,0) , 
     detcomprobhaber=isnull(case when A.monedacodigo =''01''    then  A.detcomprobhaber else Case when left(A.cuentacodigo,2) in (''77'',''97'') then  0 else round(A.detcomprobusshaber*tipocambioventa,2) end end,0), 
     detcomprobusshaber=isnull(case when A.monedacodigo =''02'' then  A.detcomprobusshaber else Case when left(A.cuentacodigo,2) in (''77'',''97'') then 0 else round(A.detcomprobhaber/tipocambioventa,2) end end,0)  
 From [##tmpcobasientodet'+@compu+'] A,
              ['+@baseconta+'].dbo.gr_documento B,
              ['+@baseconta+'].dbo.ct_tipocambio C
 Where A.documentocodigo  =B.documentocodigo  and  
      (Case When B.documentonotacredito=0 then A.detcomprobfechaemision 
       Else A.detcomprobfecharef end) =C.tipocambiofecha ' 
--exec(@SqlCad2)
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
        ''CBR''+rtrim(ltrim(cast(numprovi as varchar (50) ) ) ) 
 from [##tmpcobasientocab'+@compu+'] A 
     
Insert Into ['+@BaseConta+'].dbo.ct_detcomprob'+@Ano+'
(empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
 detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,
 cuentacodigo, detcomprobnumdocumento, detcomprobfechaemision, detcomprobfechavencimiento,
 detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe,
 detcomprobtipocambio, detcomprobruc, detcomprobauto, detcomprobformacambio,
 detcomprobajusteuser, plantillaasientoinafecto, tipdocref,
 detcomprobnumref, detcomprobconci, detcomprobnlibro, detcomprobfecharef)
Select Distinct a.empresacodigo,
       A.cabcomprobmes, 
       comprobnumero='''+@mes+'''+A.asientocodigo+replicate(''0'',5-len(B.cabcomprobnumero))+ltrim(rtrim(cast(B.cabcomprobnumero as varchar(20)))),
       A.subasientocodigo,
       analitico=case when left(A.cuentacodigo,2)=''12'' then 
                         case Rtrim(ltrim(isnull(cli.clienteruc,''''))) 
                         when ''00000000000'' then cli.clientecodigo 
                         When '''' Then cli.clientecodigo
                         else  cli.clienteruc end + ''002''
                   Else ''00'' end,
       A.asientocodigo,
       A.detcomprobitem, A.monedacodigo, A.centrocostocodigo, A.documentocodigo, A.operacioncodigo,
       A.cuentacodigo, A.detcomprobnumdocumento, A.detcomprobfechaemision, A.detcomprobfechavencimiento,
       A.detcomprobglosa, A.detcomprobdebe, A.detcomprobhaber, A.detcomprobusshaber, A.detcomprobussdebe,
       A.detcomprobtipocambio, A.detcomprobruc, A.detcomprobauto, A.detcomprobformacambio,
       A.detcomprobajusteuser, A.plantillaasientoinafecto,
       tipdocref= case when rtrim(isnull(A.tipdocref,''00''))='''' then ''00'' else isnull(A.tipdocref,''00'') end,
       A.detcomprobnumref, A.detcomprobconci, 
       comprobnlibro='''+@mes+'''+'''+@libro+'''+replicate(''0'',6-len(@MaxLibro+B.correlibro))+ltrim(rtrim(cast(@MaxLibro+B.correlibro as varchar(20))))
       , A.detcomprobfecharef
from [##tmpcobasientodet'+@compu+'] A, 
     [##tmpcobasientocab'+@compu+'] B,['+@Baseventa+'].dbo.vt_cliente cli      
Where ltrim(rtrim(A.numprovi))=rtrim(ltrim(B.numprovi)) 
      and A.analiticocodigo=Cli.clientecodigo  '

EXECUTE (@SqlCad2)

--Exec(@SqlCad2)
--Generar Automaticos 
--Generando Asientos Automaticos y Calculando el total del comprobante
Declare @Xcabcomprobnumero varchar(10),@Xasientocodigo varchar(3),
        @Xsubasientocodigo varchar(4),@Xtabla varchar(50)
Set @Xtabla='ct_detcomprob'+@Ano

set @Sqlcad='Declare GenAuto Cursor for 
select B.cabcomprobnumero,B.asientocodigo,B.subasientocodigo 
from [##tmpcobasientocab'+@compu+'] A,['+@BaseConta+'].dbo.ct_cabcomprob'+@Ano+' B
Where
 ''COB''+rtrim(ltrim(cast(A.numprovi as varchar(50)))) =B.cabcomprobnprovi ' 

Exec(@Sqlcad)

Open GenAuto
Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo
While @@Fetch_status=0 
Begin
    Exec ct_grabaautomatico_pro @baseconta,@Xtabla,@empresa,@mes,
    @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo                                   
   	
   /* Exec ct_CalcComprob_pro '',@baseconta,@Ano,@mes,
    @Xasientocodigo,@Xsubasientocodigo,@Xcabcomprobnumero   
    --Print  @Xasientocodigo +' '+@Xsubasientocodigo+' '+@Xcabcomprobnumero */
    Fetch next from GenAuto into @Xcabcomprobnumero,@Xasientocodigo,@Xsubasientocodigo	
End
Close GenAuto
Deallocate GenAuto
--Actualizar Correlativos de Asientos 
Set @SqlCad=''+
'Update ['+@BaseConta+'].dbo.ct_asientocorre 
 Set asientonumcorr'+@Mes+'= B.Ultimo
 From  
 ['+@BaseConta+'].dbo.ct_asientocorre A,
 [##tmpcorrela'+@Compu+'] B
 Where a.empresacodigo='''+@empresa+''' and A.asientocodigo  =B.Asiento2  and 
       A.asientoanno='''+@Ano+'''  
  '  
Exec(@SqlCad) 
--Actualiza correlativo de Libros
Set @SqlCad=''+
'Update  ['+@BaseConta+'].dbo.ct_librocorre
 Set libronumcorr'+@Mes+'=libronumcorr'+@Mes+'+ 
           (Select count(*)  from ##tmpcobasientocab'+@COMPU+') 
 Where empresacodigo='''+@empresa+''' and librocodigo='''+@Libro+''' and  libroanno='''+@Ano+''''
Exec(@SqlCad)
Exec cc_actualizacab @Baseconta,@Ano,@Mes,@Asiento
GO
