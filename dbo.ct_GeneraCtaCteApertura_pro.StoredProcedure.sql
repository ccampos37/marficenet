SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_GeneraCtaCteApertura_pro
execute ct_GeneraCtaCteApertura_pro 'migra2008','30','2009','2008'
*/
CREATE           proc [ct_GeneraCtaCteApertura_pro]
(	
	@base	varchar(50),
	@empresa varchar(2),
	@annoact varchar(4),
	@annopas	varchar(4),
	@NombrePC	Varchar(50)='jck01'
	
)
as
Declare @cadsql varchar(8000)
--Eliminando asientos de apertura
Set @cadsql='Delete From [' +@base+ '].dbo.ct_ctacteanalitico' +@annoact+ ' Where empresacodigo like ''' +@empresa+  ''' And cabcomprobmes=0 '
Execute(@cadsql)
--Generando asientos de apertura
if exists (select name from tempdb.dbo.sysobjects where name='##_AsientoApertura' +@NombrePC) 
  exec('DROP TABLE ##_AsientoApertura' +@NombrePC)

set @cadsql='select Distinct b.empresacodigo,cabcomprobmes=0,detcomprobitem=Identity(Bigint,1,1),cabcomprobnumero=''00''+''000''+''00001'',subasientocodigo=''0099'',
		asientocodigo=''000'',b.documentocodigo,operacioncodigo=''01'',b.cuentacodigo,ctacteanaliticofechaconta=''31/12/'+@annopas+''',b.analiticocodigo,
		b.ctacteanaliticonumdocumento,ctacteanaliticofechadoc=Isnull(a.ctacteanaliticofechadoc,c.ctacteanaliticofechadoc),
		ctacteanaliticoglosa=''ASIENTO DE APERTURA - EJERCICIO '+@annoact+' '',
		ctacteanaliticodebe=Case When b.SSoles>0 Then b.SSoles Else 0 End,
 		ctacteanaliticoussdebe=Case When b.SDolares>0 Then b.SDolares Else 0 End,
		ctacteanaliticohaber=Case When b.SSoles<0 Then b.SSoles*-1 Else 0 End,
		ctacteanaliticousshaber=Case When b.SDolares<0 Then b.SDolares*-1 Else 0 End,
		ctacteanaliticocancel=''0'',ctacteanaliticofechaven=Isnull(Isnull(a.ctacteanaliticofechaven,c.ctacteanaliticofechaven),''01/01/'+@annoact+'''),
		monedacodigo=Isnull(a.monedacodigo,c.monedacodigo)
	Into	##_AsientoApertura' +@NombrePC+' 
	from	 (Select a.empresacodigo,a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.ctacteanaliticonumdocumento,
			SSoles=Sum(Round(a.ctacteanaliticodebe,2))-Sum(Round(a.ctacteanaliticohaber,2)),
			SDolares=Sum(Round(a.ctacteanaliticoussdebe,2))-Sum(Round(a.ctacteanaliticousshaber,2))
			From [' +@base+ '].dbo.ct_ctacteanalitico'+@annopas+' a
			Inner Join [' +@base+ '].dbo.ct_cuenta c On a.empresacodigo=c.empresacodigo And a.cuentacodigo=c.cuentacodigo And c.cuentaestadoanalitico=''1''
			Where a.empresacodigo=''' +@empresa+  '''
			Group by a.empresacodigo,a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.ctacteanaliticonumdocumento
			Having Sum(Round(a.ctacteanaliticodebe,2))-Sum(Round(a.ctacteanaliticohaber,2))<>0 ) b
	Left Join ( Select Distinct empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,
			ctacteanaliticofechadoc=Min(ctacteanaliticofechadoc),ctacteanaliticofechaven=Max(ctacteanaliticofechaven),monedacodigo 
			From [' +@base+ '].dbo.ct_ctacteanalitico'+@annopas+' Where operacioncodigo=''01'' And empresacodigo=''' +@empresa+  ''' And asientocodigo<>''050'' 
			Group by empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,monedacodigo ) a
		On b.empresacodigo=a.empresacodigo And b.cuentacodigo=a.cuentacodigo And b.analiticocodigo=a.analiticocodigo 
			And b.documentocodigo=a.documentocodigo And b.ctacteanaliticonumdocumento=a.ctacteanaliticonumdocumento
	Left Join ( Select Distinct empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,
			ctacteanaliticofechadoc=Min(ctacteanaliticofechadoc),ctacteanaliticofechaven=Max(ctacteanaliticofechaven),monedacodigo 
			From [' +@base+ '].dbo.ct_ctacteanalitico'+@annopas+' Where empresacodigo=''' +@empresa+  ''' And asientocodigo<>''050''
			Group by empresacodigo,cuentacodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento,monedacodigo ) c
		On b.empresacodigo=c.empresacodigo And b.cuentacodigo=c.cuentacodigo And b.analiticocodigo=c.analiticocodigo 
			And b.documentocodigo=c.documentocodigo And b.ctacteanaliticonumdocumento=c.ctacteanaliticonumdocumento
	 Where b.empresacodigo like ''' +@empresa+  '''
	Order by b.analiticocodigo,b.documentocodigo,b.ctacteanaliticonumdocumento '
Execute(@cadsql)
--Guardando asiento de apertura
set @cadsql='
	Insert [' +@base+ '].dbo.ct_ctacteanalitico' +@annoact+ '
		(empresacodigo,cabcomprobmes, detcomprobitem, cabcomprobnumero, subasientocodigo, asientocodigo, documentocodigo, operacioncodigo, cuentacodigo, 
		 ctacteanaliticofechaconta, analiticocodigo, ctacteanaliticonumdocumento, ctacteanaliticofechadoc, ctacteanaliticoglosa, ctacteanaliticodebe, 
		ctacteanaliticoussdebe, ctacteanaliticohaber, ctacteanaliticousshaber, ctacteanaliticocancel, ctacteanaliticofechaven,monedacodigo)
	select 	empresacodigo,cabcomprobmes,detcomprobitem=Right(''00000''+Cast(detcomprobitem As varchar),5),cabcomprobnumero,subasientocodigo,asientocodigo,
		documentocodigo,operacioncodigo,cuentacodigo,ctacteanaliticofechaconta,analiticocodigo,ctacteanaliticonumdocumento,
		ctacteanaliticofechadoc,ctacteanaliticoglosa,	ctacteanaliticodebe,ctacteanaliticoussdebe,ctacteanaliticohaber,ctacteanaliticousshaber,
		ctacteanaliticocancel,ctacteanaliticofechaven,monedacodigo
	From	##_AsientoApertura' +@NombrePC+' 
	Order by 3  '	
Execute(@cadsql)

--Actualizando Saldos
Set @cadsql='Update [' +@base+ '].dbo.ct_saldos'+@annoact+' Set Saldodebe00=b.SDebe,Saldohaber00=b.SHaber,Saldoussdebe00=b.DDebe,saldousshaber00=b.DHaber
From [' +@base+ '].dbo.ct_saldos'+@annoact+' a,
(Select b.empresacodigo,b.cuentacodigo,
SDebe=Case When sum(b.SSoles)>0 Then Sum(b.SSoles) Else 0 End,
SHaber=Case When sum(b.SSoles)<0 Then (Sum(b.SSoles)*-1) Else 0 End,
DDebe=Case When sum(b.SDolares)>0 Then Sum(b.SDolares) Else 0 End,
DHaber=Case When sum(b.SDolares)<0 Then (Sum(b.SDolares)*-1) Else 0 End
From (Select a.empresacodigo,a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.ctacteanaliticonumdocumento,
SSoles=sum(round(a.ctacteanaliticodebe,2))-sum(Round(a.ctacteanaliticohaber,2)),SDolares=Sum(Round(a.ctacteanaliticoussdebe,2))-Sum(Round(a.ctacteanaliticousshaber,2))
From [' +@base+ '].dbo.ct_ctacteanalitico'+@annopas+' a
Inner Join [' +@base+ '].dbo.ct_cuenta c On a.empresacodigo=c.empresacodigo And a.cuentacodigo=c.cuentacodigo And c.cuentaestadoanalitico=''1''
Group by a.empresacodigo,a.cuentacodigo,a.analiticocodigo,a.documentocodigo,a.ctacteanaliticonumdocumento) b
Where b.empresacodigo='''+@empresa+''' And b.SSoles<>0
Group by b.empresacodigo,b.cuentacodigo) b
Where a.cuentacodigo=b.cuentacodigo And a.empresacodigo=b.empresacodigo And a.empresacodigo='''+@empresa+''' '

Execute(@cadsql)
GO
