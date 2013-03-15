SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc [co_GrabaGlosasProvision_pro]
*/
create proc [co_GrabaGlosasProvision_pro]
(	
	@BaseConta		varchar(50),
	@BaseCompra		varchar(50),
	@Mes				varchar(2),
	@ano	 			varchar(4)
)
as
 Declare @SqlCad varchar(3000)
--Actualiza la Glosa en el Detalle del Comprobante-Glosa de la Cabecera
set @SqlCad='
update ['+@BaseConta+'].dbo.ct_detcomprob' +@Ano+ ' set detcomprobglosa=isnull(left(ltrim(rtrim(zz.detproviglosa)),50),'''')
from 
	[' +@BaseConta+ '].dbo.ct_detcomprob' +@Ano+ ' a,
	(select b.cabcomprobnumero,a.cabprovinumero,a.detproviglosa
	from 
		[' +@BaseCompra+ '].dbo.co_detalleprovisiones a,
		[' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' b
	where 
		a.cabprovimes=' +@Mes+ ' and b.cabcomprobmes=''' +@Mes+ ''' and
		cast(a.cabprovinumero as varchar(20))=cast(b.cabcomprobnprovi as varchar(20)) ) as ZZ
where 
	a.cabcomprobnumero=zz.cabcomprobnumero and 
	( a.asientocodigo like ''06%'' or a.asientocodigo like ''05%'' ) and a.cabcomprobmes=''' +@Mes+ '''
update [' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' 
set cabcomprobglosa=left(''Provision '' + cast(b.cabprovinumero as varchar(5)) + '' NºAux.'' + cast(b.cabprovinumaux as varchar),30)
from 
	[' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' a,
	[' +@BaseCompra+ '].dbo.co_cabprovisiones b
where a.cabcomprobmes=''' +@Mes+ ''' and
		a.cabcomprobnumero collate Modern_Spanish_CI_AI = b.cabprovinconta collate Modern_Spanish_CI_AI'
exec(@SqlCad)
--exec co_GrabaGlosasProvision_pro 'Contaprueba','camtex_tinto','05','2003'
GO
