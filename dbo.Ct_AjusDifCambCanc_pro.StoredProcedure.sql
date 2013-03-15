SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop    Proc Ct_AjusDifCambCanc_pro
EXEC Ct_AjusDifCambCanc_pro 'gremco','40','2008','12','050','0099','977601','7761','31/12/2008','jotace','AJ01','3.14','0004'
*/

create            Proc [Ct_AjusDifCambCanc_pro]
@Base			Varchar(50), 
@empresa		Varchar(2),
@Ano			Varchar(4),
@Mes			Varchar(2),
@Asiento		Varchar(3),
@SubAsiento		Varchar(4),
@AjusteDebe		Varchar(10),
@AjusteHaber	Varchar(10),
@Fecha		Varchar(10),
@Usuario		Varchar(50),
@NombrePC		Varchar(50),
@TipoCambio		Varchar(6),
@CCosto		Varchar(10)

AS
Declare @SqlCad1 Varchar(8000),@SqlCad2 varchar(8000)
Declare @Cmes as Varchar(2)
Set @Cmes = Right(('0'+@Mes),2)
--AJUSTE POSITIVO
if exists (select name from tempdb.dbo.sysobjects where name='##_AjustePosi' +@NombrePC) 
  exec('DROP TABLE ##_AjustePosi' +@NombrePC)

Set @SqlCad1='Select z.empresacodigo,z.cuentacodigo,z.analiticocodigo,z.documentocodigo,z.detcomprobnumdocumento,debe=round((z.dolares*'+@TipoCambio+'-z.soles),2),haber=0 
	Into ##_AjustePosi'+@NombrePC+'
From (Select  a.empresacodigo, a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.detcomprobnumdocumento,
		soles= sum(a.detcomprobdebe-a.detcomprobhaber),dolares=sum(a.detcomprobussdebe-a.detcomprobusshaber),
		ajuste=sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+'-sum(a.detcomprobdebe-a.detcomprobhaber)
	From (Select empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,detcomprobnumdocumento,detcomprobdebe,detcomprobhaber,detcomprobussdebe,detcomprobusshaber
	From [' +@base+ '].dbo.ct_detcomprob'+@Ano+' Where empresacodigo='''+@empresa+''' 
	Union  All
	Select empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,ctacteanaliticodebe,ctacteanaliticohaber,ctacteanaliticoussdebe,ctacteanaliticousshaber 
	From [' +@base+ '].dbo.ct_ctacteanalitico'+@Ano+' Where cabcomprobmes=0 And empresacodigo='''+@empresa+''' ) a
	Inner Join  [' +@base+ '].dbo.ct_cuenta b On a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo
	Where b.tipoajuste=''01'' And a.empresacodigo='''+@empresa+''' And b.cuentaestadoanalitico=''1''
	Group by a.empresacodigo, a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.detcomprobnumdocumento
	Having (sum(a.detcomprobussdebe-a.detcomprobusshaber)>=0 And round(sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+' -sum(a.detcomprobdebe-a.detcomprobhaber),2)>0)
	Or (sum(a.detcomprobusshaber-a.detcomprobussdebe)>=0 And round(sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe),2)<0 ) ) z 
Union All
Select z.empresacodigo,z.cuentacodigo,''00'',''00'','' '',debe=round((z.dolares*'+@TipoCambio+'-z.soles),2),haber=0 
From (Select  a.empresacodigo, a.cuentacodigo,
		soles= sum(a.detcomprobdebe-a.detcomprobhaber),dolares=sum(a.detcomprobussdebe-a.detcomprobusshaber),
		ajuste=sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+'-sum(a.detcomprobdebe-a.detcomprobhaber)
	From (Select empresacodigo,cuentacodigo,detcomprobdebe,detcomprobhaber,detcomprobussdebe,detcomprobusshaber
	From [' +@base+ '].dbo.ct_detcomprob'+@Ano+' Where empresacodigo='''+@empresa+''' 
	Union  All
	Select empresacodigo,cuentacodigo,saldodebe00,saldohaber00,saldoussdebe00,saldousshaber00 
	From [' +@base+ '].dbo.ct_saldos'+@Ano+' Where empresacodigo='''+@empresa+''' ) a
	Inner Join  [' +@base+ '].dbo.ct_cuenta b On a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo
	Where b.tipoajuste=''01'' And a.empresacodigo='''+@empresa+''' And b.cuentaestadoanalitico=''0'' 
	Group by a.empresacodigo, a.cuentacodigo
	Having (sum(a.detcomprobussdebe-a.detcomprobusshaber)>=0 And round(sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+' -sum(a.detcomprobdebe-a.detcomprobhaber),2)>0)
	Or (sum(a.detcomprobusshaber-a.detcomprobussdebe)>=0 And round(sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe),2)<0 ) ) z'
Execute(@SqlCad1)

if exists (select name from tempdb.dbo.sysobjects where name='##_AjusteGanancia' +@NombrePC) 
  exec('DROP TABLE ##_AjusteGanancia' +@NombrePC)

Set @SqlCad1='Select detcomprobitem= IDENTITY ( Int  ,1 ,1 ) , AJ.* 
	Into ##_AjusteGanancia'+@NombrePC+'
From (Select asiento='''+@Asiento+''',subasiento='''+@SubAsiento+''',cabcomprobnumero='''+@Cmes+@Asiento+'00001'',* From ##_AjustePosi'+@NombrePC+'
	Union All
	Select asiento='''+@Asiento+''',subasiento='''+@SubAsiento+''',cabcomprobnumero='''+@Cmes+@Asiento+'00001'',empresacodigo,cuentacodigo='''+@AjusteHaber+''',
	''00'',''00'','' '',
	debe=sum(haber),haber=sum(debe) 
	From ##_AjustePosi'+@NombrePC+'  
	Group by empresacodigo) AJ '
Execute(@SqlCad1)

--AJUSTE NEGATIVO
if exists (select name from tempdb.dbo.sysobjects where name='##_AjusteNeg' +@NombrePC) 
  exec('DROP TABLE ##_AjusteNeg' +@NombrePC)

Set @SqlCad1='Select z.empresacodigo,z.cuentacodigo,z.analiticocodigo,z.documentocodigo,z.detcomprobnumdocumento,debe=0,haber=round((z.dolares*'+@TipoCambio+'-z.soles),2) 
	Into ##_AjusteNeg' +@NombrePC+'
From (Select  a.empresacodigo, a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.detcomprobnumdocumento,
		soles= sum(a.detcomprobhaber-a.detcomprobdebe),dolares=sum(a.detcomprobusshaber-a.detcomprobussdebe),
		ajuste=sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe)
	From  (Select empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,detcomprobnumdocumento,detcomprobdebe,detcomprobhaber,detcomprobussdebe,detcomprobusshaber
	From [' +@base+ '].dbo.ct_detcomprob'+@Ano+' Where empresacodigo='''+@empresa+''' 
	Union  All
	Select empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,ctacteanaliticodebe,ctacteanaliticohaber,ctacteanaliticoussdebe,ctacteanaliticousshaber 
	From [' +@base+ '].dbo.ct_ctacteanalitico'+@Ano+' Where cabcomprobmes=0 And empresacodigo='''+@empresa+''' ) a
	Inner Join  [' +@base+ '].dbo.ct_cuenta b On a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo
	Where b.tipoajuste=''01''  And a.empresacodigo='''+@empresa+''' And b.cuentaestadoanalitico=''1'' 
	Group by a.empresacodigo,a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.detcomprobnumdocumento
	Having (sum(a.detcomprobusshaber-a.detcomprobussdebe)>=0 And round(sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe),2)>0 )
	Or (sum(a.detcomprobussdebe-a.detcomprobusshaber)>=0 And round(sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+' -sum(a.detcomprobdebe-a.detcomprobhaber),2)<0) ) z 
Union All
Select z.empresacodigo,z.cuentacodigo,''00'',''00'','' '',debe=0,haber=round((z.dolares*'+@TipoCambio+'-z.soles),2) 
From (Select  a.empresacodigo, a.cuentacodigo,
		soles= sum(a.detcomprobhaber-a.detcomprobdebe),dolares=sum(a.detcomprobusshaber-a.detcomprobussdebe),
		ajuste=sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe)
	From  (Select empresacodigo,cuentacodigo,detcomprobdebe,detcomprobhaber,detcomprobussdebe,detcomprobusshaber
	From [' +@base+ '].dbo.ct_detcomprob'+@Ano+' Where empresacodigo='''+@empresa+''' 
	Union  All
	Select empresacodigo,cuentacodigo,saldodebe00,saldohaber00,saldoussdebe00,saldousshaber00 
	From [' +@base+ '].dbo.ct_saldos'+@Ano+' Where empresacodigo='''+@empresa+''' ) a
	Inner Join  [' +@base+ '].dbo.ct_cuenta b On a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo
	Where b.tipoajuste=''01''  And a.empresacodigo='''+@empresa+''' And b.cuentaestadoanalitico=''0'' 
	Group by a.empresacodigo,a.cuentacodigo
	Having (sum(a.detcomprobusshaber-a.detcomprobussdebe)>=0 And round(sum(a.detcomprobusshaber-a.detcomprobussdebe)*'+@TipoCambio+' -sum(a.detcomprobhaber-a.detcomprobdebe),2)>0 )
	Or (sum(a.detcomprobussdebe-a.detcomprobusshaber)>=0 And round(sum(a.detcomprobussdebe-a.detcomprobusshaber)*'+@TipoCambio+' -sum(a.detcomprobdebe-a.detcomprobhaber),2)<0) ) z'
Execute(@SqlCad1)

if exists (select name from tempdb.dbo.sysobjects where name='##_AjustePerdida' +@NombrePC) 
  exec('DROP TABLE ##_AjustePerdida' +@NombrePC)

Set @SqlCad1='Select detcomprobitem= IDENTITY ( Int  ,1 ,1 ) , AJ.* 
	Into ##_AjustePerdida'+@NombrePC+'
From(Select asiento='''+@Asiento+''',subasiento='''+@SubAsiento+''',cabcomprobnumero='''+@Cmes+@Asiento+'00002'',centrocostocodigo='''+@CCosto+''',*  
	From ##_AjusteNeg'+@NombrePC+'
	Union All
	Select asiento='''+@Asiento+''',subasiento='''+@SubAsiento+''',cabcomprobnumero='''+@Cmes+@Asiento+'00002'',centrocostocodigo='''+@CCosto+''',
		empresacodigo,'''+@AjusteDebe+''',''00'',''00'','' '',debe=sum(haber),haber=sum(debe)
	From ##_AjusteNeg' +@NombrePC+' 
	Group by empresacodigo) AJ '
Execute(@SqlCad1)

--GENERA ASIENTO CONTABLE
--GANANCIA
--Cabecera
Set @SqlCad1='Insert Into [' +@base+ '].dbo.ct_cabcomprob'+@Ano+'(empresacodigo,cabcomprobmes, cabcomprobnumero , cabcomprobfeccontable, subasientocodigo, 
	usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones,fechaact, cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber,cabcomprobtotussdebe,
	cabcomprobtotusshaber, cabcomprobgrabada)
Select empresacodigo,'+@Mes+',cabcomprobnumero,'''+@Fecha+''',subasiento,'''+@Usuario+''',''00'',asiento,'''','''+@Fecha+''',''AJUSTE DIFERENCIA DE CAMBIO'',
	Sum(debe),Sum(haber),0,0,''0''
From ##_AjusteGanancia'+@NombrePC+'  Group by empresacodigo,cabcomprobnumero,asiento,subasiento  '
--Detalle
Set @SqlCad2='
Insert Into ['+@base+'].dbo.ct_detcomprob'+@Ano+'(empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
	detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,cuentacodigo, detcomprobnumdocumento,detcomprobfechaemision,
	detcomprobfechavencimiento,detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobussdebe, detcomprobusshaber,detcomprobtipocambio,detcomprobruc,
	detcomprobauto,detcomprobajustedifcambio)
Select empresacodigo,'+@Mes+',cabcomprobnumero,subasiento,analiticocodigo,asiento,detcomprobitem=Right(''0000''+Cast(detcomprobitem as varchar),5),''02'',''00'',
	documentocodigo,''01'',cuentacodigo,detcomprobnumdocumento,'''+@Fecha+''','''+@Fecha+''',''AJUSTE GANANCIA POR DIFERENCIA DE CAMBIO'',debe,haber,0,0,'+@TipoCambio+','''',''1'',''1''
From ##_AjusteGanancia'+@NombrePC
Execute (@SqlCad1+@SqlCad2)
--PERDIDA
--Cabecera
Set @SqlCad1='Insert Into [' +@base+ '].dbo.ct_cabcomprob'+@Ano+'(empresacodigo,cabcomprobmes, cabcomprobnumero , cabcomprobfeccontable, subasientocodigo, 
	usuariocodigo, estcomprobcodigo, asientocodigo, cabcomprobobservaciones,fechaact, cabcomprobglosa, cabcomprobtotdebe, cabcomprobtothaber,cabcomprobtotussdebe,
	cabcomprobtotusshaber, cabcomprobgrabada)
Select empresacodigo,'+@Mes+',cabcomprobnumero,'''+@Fecha+''',subasiento,'''+@Usuario+''',''00'',asiento,'''','''+@Fecha+''',''AJUSTE DIFERENCIA DE CAMBIO'',
	Sum(debe),Sum(haber),0,0,''0''
From ##_AjustePerdida'+@NombrePC+'  Group by empresacodigo,cabcomprobnumero,asiento,subasiento  '
--Detalle
Set @SqlCad2='
Insert Into ['+@base+'].dbo.ct_detcomprob'+@Ano+'(empresacodigo,cabcomprobmes, cabcomprobnumero, subasientocodigo, analiticocodigo, asientocodigo,
	detcomprobitem, monedacodigo, centrocostocodigo, documentocodigo, operacioncodigo,cuentacodigo, detcomprobnumdocumento,detcomprobfechaemision,
	detcomprobfechavencimiento,detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobussdebe, detcomprobusshaber,detcomprobtipocambio,detcomprobruc,
	detcomprobauto,detcomprobajustedifcambio)
Select empresacodigo,'+@Mes+',cabcomprobnumero,subasiento,analiticocodigo,asiento,detcomprobitem=Right(''0000''+Cast(detcomprobitem as varchar),5),''02'',
	centrocostocodigo,documentocodigo,''01'',cuentacodigo,detcomprobnumdocumento,'''+@Fecha+''','''+@Fecha+''',''AJUSTE PERDIDA POR DIFERENCIA DE CAMBIO'',debe,haber,0,0,'+@TipoCambio+','''',''1'',''1''
From ##_AjustePerdida'+@NombrePC+' 

execute ct_grabaautomatico_pro '''+@base+''',''ct_detcomprob'+@Ano+''','''+@empresa+''','''+@Mes+''','''+@Cmes+@Asiento+'00002'','''+@Asiento+''','''+@SubAsiento+''' '
Execute (@SqlCad1+@SqlCad2)
GO
