SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

select * frOM PLANTA_CASMA.dbo.co_cabeceraprovisiones WHERE CABPROVINUMERO='15212'


execute co_GeneraTempComprasenLinea_pro 'aliterm2012','aliterm2012','01','0099','02','11','2012','4211100','4011100','4011902','4041200','001','##70554751','sa','001','38486'

*/
CREATE PROC [co_GeneraTempComprasenLinea_pro]
--Declare
        @BaseConta		Varchar(100),
        @BaseCompra 		varchar(100),
        @empresa                varchar(2),
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
--execute co_generatempcomprasenlinea_pro 'migra2008','migra2008','30','0099','02','01','2009','421100','401100','40174','404200','001','ccampos','sa','001','5358'
Declare @Sql1 varchar(8000),@Sql2 varchar(4000) 
       
Set @Sql1=''+
'If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientocab'+@compu+''') 
    Drop Table [##tmpgenasientocab'+@compu+'] 
 Select a.empresacodigo,numprovi=cast(A.cabprovinumero as varchar(20)),
        cabcomprobmes=A.cabprovimes,
        cabcomprobnumero=cast(''0'' as bigint) ,correlibro=IDENTITY(bigint,1,1),
        cabcomprobfeccontable=cabprovifchconta,
        subasientocodigo='''+@SubAsiento+''',usuariocodigo='''+@Usuario+''',estcomprobcodigo=''03'',
        asientocodigo=co.eqconta ,cabcomprobobservaciones='' '',
        fechaact=getdate(),cabcomprobglosa=''Provision  Nº ''+rtrim(cast(A.cabprovinumero as varchar(20))),
        cabcomprobtotdebe=case when  A.monedacodigo=''01'' then A.cabprovitotal Else 0 end ,
        cabcomprobtothaber=case when  A.monedacodigo=''01'' then A.cabprovitotal Else 0 end,
        cabcomprobtotussdebe=case when A.monedacodigo=''02'' then A.cabprovitotal Else 0 end,
        cabcomprobtotusshaber=case when A.monedacodigo=''02'' then A.cabprovitotal Else 0 end,cabcomprobgrabada=A.cabproviopergrab,cabcomprobnref='' '',
        cabcomprobnlibro=rtrim(a.cabprovinumaux)
 Into [##tmpgenasientocab'+@Compu+'] 
 From   ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A
        inner join ['+@BaseCompra+'].dbo.co_tipocompra co 
           on A.tipocompracodigo=co.tipocompracodigo             
        Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and ltrim(rtrim(isnull(A.cabprovinconta,'''')))='''' 
              and a.cabprovinumero like ('''+@numcomprob+''')
 --Item del Importe Bruto
 If Exists(Select name from tempdb..sysobjects where name=''##tmpgenasientodet'+@compu+''') 
    Drop Table [##tmpgenasientodet'+@compu+']  
 If Exists(Select name from tempdb..sysobjects where name=''##tmp1genasientodet'+@compu+''') 
    Drop Table [##tmp1genasientodet'+@compu+']
 
 If Exists(Select name from tempdb..sysobjects where name=''##tmp2genasientodet'+@compu+''') 
    Drop Table [##tmp2genasientodet'+@compu+']
 
If Exists(Select name from tempdb..sysobjects where name=''##tmp3genasientodet'+@compu+''') 
    Drop Table [##tmp3genasientodet'+@compu+']
 
 If Exists(Select name from tempdb..sysobjects where name=''##tmp4genasientodet'+@compu+''') 
    Drop Table [##tmp4genasientodet'+@compu+'] '

execute(@Sql1)

Set @Sql1=
' select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
   analiticocodigo=A.proveedorcodigo, asientocodigo=co.eqconta,detcomprobitem=''00001'',monedacodigo=A.monedacodigo,
   b.centrocostocodigo, documentocodigo=A.documetocodigo,operacioncodigo=''01'',cuentacodigo=cg.cuentacodigo,
   detcomprobnumdocumento=a.cabprovinumdoc'

set @sql1=@sql1+',detcomprobfechaemision=A.cabprovifchdoc,
   detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa=case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
   detcomprobdebe=case when isnull(gd.tdocumentotipo,'' '')=''C'' then  Case when A.monedacodigo=''01'' then B.detproviimpbru else 0 end else 0 end ,
   detcomprobhaber=case when isnull(gd.tdocumentotipo,'' '')<>''C'' then  Case when A.monedacodigo=''01'' then B.detproviimpbru else 0 end else 0 end ,
   detcomprobusshaber=case when isnull(gd.tdocumentotipo,'' '')<>''C'' then  Case when A.monedacodigo=''02'' then B.detproviimpbru else 0 end else 0 end,
   detcomprobussdebe=case when isnull(gd.tdocumentotipo,'' '')=''C'' then  Case when A.monedacodigo=''02'' then B.detproviimpbru else 0 end else 0 end,
   detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
   detcomprobajusteuser=0, plantillaasientoinafecto=0,tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
   detcomprobconci=0, detcomprobnlibro='' '' , detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
  into [##tmp1genasientodet'+@compu+']
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A  on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co   on A.tipocompracodigo=co.tipocompracodigo 
     left join ['+@BaseConta+'].dbo.cp_tipodocumento gd    on A.documetocodigo=gd.tdocumentocodigo
     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' 
and A.cabprovimes='+@Mes+' and a.cabprovinumero like ('''+@numcomprob+''')'

EXECUTE(@sql1)

--Registro del IGV

Set @Sql1='
select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=Case when A.tipocompracodigo <>''64'' then ''00''
                    else A.cabproviruc end, asientocodigo=co.eqconta,detcomprobitem=''00002'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'', documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when A.tipocompracodigo <>''64'' then '''+@ctaIGV+'''  
                    else '''+@ctaIES+''' end,
       detcomprobnumdocumento=a.cabprovinumdoc'
/*
       If @ano='2008' set @sql1=@sql1+'fn_conviertenumdoc(a.cabprovinumdoc)'
       If @ano<>'2008' set @sql1=@sql1+'fn_coviertenumdoc(a.cabprovinumdoc)'
*/
set @sql1=@sql1+',detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,
      detcomprobglosa='' '' , -- case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
       detcomprobdebe=round(case when isnull(gd.tdocumentotipo,'' '')=''C'' then  Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end else 0 end,2),
       detcomprobhaber=round(case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''01'' and A.tipocompracodigo =''64'' then Abs(sum(B.detproviimpigv)) else 0 end  
                       Else Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end End,2) ,
       detcomprobusshaber=round(case when isnull(gd.tdocumentotipo,'' '')=''C'' then  Case when A.monedacodigo=''02'' and A.tipocompracodigo =''64''  then Abs(sum(B.detproviimpigv)) else 0 end
                       Else Case when A.monedacodigo=''02'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end End,2) ,
       detcomprobussdebe=round(case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''02'' and A.tipocompracodigo <>''64'' then Abs(sum(B.detproviimpigv)) else 0 end else 0 end,2),
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
  into [##tmp2genasientodet'+@compu+']
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co on A.tipocompracodigo=co.tipocompracodigo 
     left join ['+@BaseConta+'].dbo.cp_tipodocumento gd on A.documetocodigo=gd.tdocumentocodigo     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and a.cabprovinumero like ('''+@numcomprob+''')
group by b.empresacodigo,B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,A.documetocodigo,A.cabprovinumdoc,
         A.cabprovifchdoc,A.cabprovifchven,B.detprovitipcam,A.cabproviruc,B.detproviformcamb,
         A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.tdocumentotipo '  --,B.detproviglosa,cg.gastosdescripcion '
execute(@sql1)
--Registro Inafecto 
Set @Sql1=''+
'select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=A.cabproviruc, asientocodigo=co.eqconta,detcomprobitem=''00003'',monedacodigo=A.monedacodigo,
       b.centrocostocodigo, documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when A.tipocompracodigo <>''64'' then cg.CUENTACODIGO
                    else '''+@ctaRTA+'''end,
   detcomprobnumdocumento=a.cabprovinumdoc'

set @sql1=@sql1+',detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa=case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
       detcomprobdebe=Case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''01'' and A.tipocompracodigo <>''64'' then 
                           case when B.detproviimpina > 0 then Abs(B.detproviimpina) else 0 end else 0 end else 0 end,
       detcomprobhaber=Case when A.monedacodigo=''01'' and A.tipocompracodigo =''64'' then 
                            Abs(B.detproviimpina) else case when B.detproviimpina < 0 then Abs(B.detproviimpina) 
	else (case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''01'' then B.detproviimpina else 0 end else 0 end) end  end,
       detcomprobusshaber=Case when A.monedacodigo=''02'' and A.tipocompracodigo =''64'' then 
		Abs(B.detproviimpina) else 0 end,
       detcomprobussdebe=Case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''02'' and  A.tipocompracodigo <>''64'' then 
		Abs(B.detproviimpina) else (case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''02'' then B.detproviimpina else 0 end else 0 end) end else 0 end,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=case when A.tipocompracodigo <>''64'' then  1 else 0 End,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,  detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
  into [##tmp3genasientodet'+@compu+']
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co on A.tipocompracodigo=co.tipocompracodigo 
     left join ['+@BaseConta+'].dbo.cp_tipodocumento gd  on A.documetocodigo=gd.tdocumentocodigo
     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and B.detproviimpina <> 0 and a.cabprovinumero like ('''+@numcomprob+''') '
execute (@sql1)
--Registro del Total Compra
Set @Sql1=N'  select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo='''+@SubAsiento+''',
       analiticocodigo=A.cabproviruc,
       asientocodigo=co.eqconta,detcomprobitem=''00004'',monedacodigo=A.monedacodigo,
       centrocostocodigo=''00'',documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when a.monedacodigo=''01'' then gd.tdocumentocuentasoles 
                          else gd.tdocumentocuentadolares end,
   detcomprobnumdocumento=a.cabprovinumdoc'
/*       detcomprobnumdocumento=dbo.'
       If @ano='2008' set @sql1=@sql1+'fn_conviertenumdoc(a.cabprovinumdoc)'
       If @ano<>'2008' set @sql1=@sql1+'fn_coviertenumdoc(a.cabprovinumdoc)'
*/
set @sql1=@sql1+',detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,
       detcomprobglosa=''  '' , ---case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
       detcomprobdebe=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end  else 0 End ,
       detcomprobhaber=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobusshaber=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobussdebe=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End ,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,
       detcomprobauto=0, detcomprobformacambio=B.detproviformcamb, 
       detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,
       detcomprobconci=0, detcomprobnlibro='' '' ,
       detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
   into [##tmp4genasientodet'+@compu+']
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A  on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co   on A.tipocompracodigo=co.tipocompracodigo 
     left join ['+@BaseConta+'].dbo.cp_tipodocumento gd on A.documetocodigo=gd.tdocumentocodigo
     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' 
  and a.cabprovinumero like ('''+@numcomprob+''')
group by b.empresacodigo,B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,
         A.documetocodigo,A.cabprovinumdoc,
         A.cabprovifchdoc,A.cabprovifchven,B.detprovitipcam,A.cabproviruc,B.detproviformcamb,
         A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.tdocumentotipo,
         gd.tdocumentocuentasoles,gd.tdocumentocuentadolares  ' ---,B.detproviglosa,cg.gastosdescripcion  '
Execute(@sql1)

--Provisiones canceladas a cuenta de...
Declare @ACta as bit

if exists (select name from tempdb.dbo.sysobjects where name='##tmpProviAnalitico') 
  exec('DROP TABLE ##tmpProviAnalitico')
Set @sql1='Select Isnull(a.modoprovianalitico,0) as provianalitico Into ##tmpProviAnalitico
From ['+@BaseConta+'].dbo.co_modoprovi a
Inner Join  ['+@BaseConta+'].dbo.co_cabeceraprovisiones b On a.modoprovicod=b.modoprovicod
Where b.empresacodigo='''+@empresa+''' and b.cabproviano='+@ano+' and b.cabprovimes='+@Mes+' and b.cabprovinumero like ('''+@numcomprob+''') '
Execute(@sql1)

Set @ACta=(Select provianalitico From ##tmpProviAnalitico )
exec('Drop Table ##tmpProviAnalitico')
Print @ACta
If @ACta=1
Begin
if exists (select name from tempdb.dbo.sysobjects where name='##tmp5genasientodet'+@compu) 
  exec('DROP TABLE ##tmp5genasientodet'+@compu+'')
Set @sql1='
Select T.* Into [##tmp5genasientodet'+@compu+'] From 
( select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo=''0099'',analiticocodigo=A.cabproviruc,
       asientocodigo=co.eqconta,detcomprobitem=''00005'',monedacodigo=A.monedacodigo,centrocostocodigo=''00'',documentocodigo=A.documetocodigo,operacioncodigo=''01'',
       cuentacodigo=case when a.monedacodigo=''01'' then gd.tdocumentocuentasoles else gd.tdocumentocuentadolares end,
       detcomprobnumdocumento=a.cabprovinumdoc,
/*--dbo.fn_coviertenumdoc(a.cabprovinumdoc), */
detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa=case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
       detcomprobdebe=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end  else 0 End ,
       detcomprobhaber=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobusshaber=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobussdebe=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End ,
       detcomprobtipocambio=B.detprovitipcam , detcomprobruc=A.cabproviruc,detcomprobauto=1, detcomprobformacambio=B.detproviformcamb,detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,detcomprobconci=0, detcomprobnlibro='' '',detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta           
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A  on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co   on A.tipocompracodigo=co.tipocompracodigo 
     left join ['+@BaseConta+'].dbo.cp_tipodocumento gd on A.documetocodigo=gd.tdocumentocodigo
     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and a.cabprovinumero like ('''+@numcomprob+''')
Group by b.empresacodigo,B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,A.cabprovifchven,
      B.detprovitipcam,A.cabproviruc,B.detproviformcamb, A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.tdocumentotipo,
      gd.tdocumentocuentasoles,gd.tdocumentocuentadolares,B.detproviglosa,cg.gastosdescripcion
Union all
select b.empresacodigo,numprovi=B.cabprovinumero, cabcomprobmes=B.cabprovimes,cabcomprobnumero='' '',subasientocodigo=''0099'',analiticocodigo=A.cabprovianalitico,
       asientocodigo=co.eqconta,detcomprobitem=''00006'',monedacodigo=A.monedacodigo,centrocostocodigo=''00'',documentocodigo=a.tipodocacuenta,operacioncodigo=''01'',
       cuentacodigo=case when a.monedacodigo=''01'' then ''4611'' ELSE ''4612'' END, /*gd.tdocumentocuentasoles else gd.tdocumentocuentadolares end,*/
       detcomprobnumdocumento=a.cabprovinumdoc,
/* dbo.fn_coviertenumdoc(a.cabprovinumdoc) */
	   detcomprobfechaemision=A.cabprovifchdoc,
       detcomprobfechavencimiento=A.cabprovifchven,detcomprobglosa=case When B.detproviglosa is null Then cg.gastosdescripcion When ltrim(rtrim(B.detproviglosa))='''' Then cg.gastosdescripcion Else B.detproviglosa end,
       detcomprobdebe=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobhaber=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''01'' then sum(B.detprovitotal) else 0 end  else 0 End ,
       detcomprobusshaber=case when isnull(gd.tdocumentotipo,'' '')=''C'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End ,
       detcomprobussdebe=case when isnull(gd.tdocumentotipo,'' '')=''A'' then Case when A.monedacodigo=''02'' then sum(B.detprovitotal) else 0 end else 0 End,
       detcomprobtipocambio=B.detprovitipcam,detcomprobruc=A.cabprovianalitico,detcomprobauto=1, detcomprobformacambio=B.detproviformcamb,detcomprobajusteuser=0, plantillaasientoinafecto=0,
       tipdocref=A.cabprovitipdocref, detcomprobnumref=A.cabprovinref,detcomprobconci=0, detcomprobnlibro='' '',detcomprobfecharef=A.cabprovifechdocref,cabprovinconta=A.cabprovinconta 
from ['+@BaseCompra+'].dbo.co_detalleprovisiones B
     inner join ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A  on B.cabprovinumero=A.cabprovinumero 
     inner join ['+@BaseCompra+'].dbo.co_tipocompra co   on A.tipocompracodigo=co.tipocompracodigo
     left join ['+@BaseConta+'].dbo.co_gastos cg On B.gastoscodigo=cg.gastoscodigo
     Left Join ['+@BaseConta+'].dbo.cp_proveedor P On A.cabprovianalitico=P.clientecodigo
     left join ['+@BaseCompra+'].dbo.cp_tipodocumento gd on a.tipodocacuenta=gd.tdocumentocodigo
Where a.empresacodigo='''+@empresa+''' and a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and a.cabprovinumero like ('''+@numcomprob+''')
Group by b.empresacodigo,B.cabprovinumero,B.cabprovimes,A.tipocompracodigo,co.eqconta,A.monedacodigo,A.documetocodigo,A.cabprovinumdoc,A.cabprovifchdoc,A.cabprovifchven,
     B.detprovitipcam,A.cabprovianalitico,B.detproviformcamb,A.cabprovitipdocref,A.cabprovinref,A.cabprovifechdocref,A.cabprovinconta,gd.tdocumentotipo,
     gd.tdocumentocuentasoles,gd.tdocumentocuentadolares,a.tipodocacuenta,B.detproviglosa,cg.gastosdescripcion  ) T '

execute(@sql1)

End

Set @Sql2=N' Select *,numfila=IDENTITY(BigInt,1,1) Into [##tmpgenasientodet'+@Compu+'] From 
 ( select * from [##tmp1genasientodet'+@compu+'] where detcomprobdebe+detcomprobhaber +detcomprobusshaber+detcomprobussdebe> 0
 union all
 select * from [##tmp2genasientodet'+@compu+'] where detcomprobdebe+detcomprobhaber +detcomprobusshaber+detcomprobussdebe> 0
 union all
 select * from [##tmp3genasientodet'+@compu+'] where detcomprobdebe+detcomprobhaber +detcomprobusshaber+detcomprobussdebe> 0
 union all
 select * from [##tmp4genasientodet'+@compu+'] where detcomprobdebe+detcomprobhaber +detcomprobusshaber+detcomprobussdebe> 0'

If @ACta=1
Begin
Set @Sql2=@Sql2+' union all
 select * from [##tmp5genasientodet'+@compu+'] where detcomprobdebe+detcomprobhaber +detcomprobusshaber+detcomprobussdebe> 0'
End

Set @Sql2=@Sql2+') as XX 
Where ltrim(rtrim(isnull(XX.cabprovinconta,'''')))='''''  

execute(@Sql2)
GO
