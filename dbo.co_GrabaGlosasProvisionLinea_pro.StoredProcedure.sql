SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.co_GrabaGlosasProvisionLinea_pro    fecha de la secuencia de comandos: 03/01/2008 06:38:21 p.m. ******/
/*
drop proc co_GrabaGlosasProvisionLinea_pro 
*/
CREATE    proc [co_GrabaGlosasProvisionLinea_pro]
(	
	@BaseConta		varchar(50),
	@BaseCompra		varchar(50),
	@Mes			varchar(2),
	@ano			varchar(4),
    @Nprovi         varchar(10)
)
as
 Declare @SqlCad varchar(3000)
--Actualiza la Glosa en el Detalle del Comprobante-Glosa de la Cabecera
set @SqlCad='
update ['+@BaseConta+'].dbo.ct_detcomprob' +@Ano+ ' 
set detcomprobglosa=isnull(left(ltrim(rtrim(zz.detproviglosa)),50),'''')
from 
	[' +@BaseConta+ '].dbo.ct_detcomprob' +@Ano+ ' a,
	(select b.cabcomprobnumero,a.cabprovinumero,a.detproviglosa
	from 
		[' +@BaseCompra+ '].dbo.co_detalleprovisiones a,
		[' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' b
	where 
		a.cabproviano='''+@ano+''' and a.cabprovimes=' +@Mes+ ' and b.cabcomprobmes=''' +@Mes+ ''' and
		cast(a.cabprovinumero as varchar(20))=cast(b.cabcomprobnprovi as varchar(20)) ) as ZZ
where 
	a.cabcomprobnumero=zz.cabcomprobnumero and 
	a.asientocodigo like ''06%'' and a.cabcomprobmes=''' +@Mes+ ''' and 
    zz.cabprovinumero='+@Nprovi+' 
  
update [' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' 
set cabcomprobglosa=left(''Prov.Compra '' + cast(b.cabprovinumero as varchar(5)) + '' NºAux.'' + cast(b.cabprovinumaux as varchar),30)
from 
	[' +@BaseConta+ '].dbo.ct_cabcomprob' +@Ano+ ' a,
	[' +@BaseCompra+ '].dbo.co_cabeceraprovisiones b
where a.cabcomprobmes=''' +@Mes+ ''' and b.cabproviano='''+@ano+''' and b.cabprovinumero='+@Nprovi+' and 
	  a.cabcomprobnumero collate Modern_Spanish_CI_AI = b.cabprovinconta collate Modern_Spanish_CI_AI '
       
Exec(@SqlCad)
--exec co_GrabaGlosasProvisionLinea_pro 'Contaprueba','camtex_tinto','06','2003','5692'
GO
