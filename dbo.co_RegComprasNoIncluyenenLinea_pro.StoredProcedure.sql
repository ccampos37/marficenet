SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [co_RegComprasNoIncluyenenLinea_pro]
(
	@basecompra		varchar(50),
	@baseconta		varchar(50),
	@asiento 		varchar(3),
	@mes			varchar(2),
	@ano			varchar(4),
    @Nprovi  		varchar(10)
     
)
as
Declare @cadsql varchar(3000)
set @cadsql='update [' +@baseconta+ '].dbo.ct_cabcomprob' +@ano+ '  
	set asientocodigo=''' +@asiento+ '''
from [' +@baseconta+ '].dbo.ct_cabcomprob' +@ano+ ' 
where cabcomprobnumero in
	(select cabprovinconta from [' +@basecompra+ '].dbo.co_cabeceraprovisiones a,
		[' +@basecompra+ '].dbo.co_modoprovi b 
		where cabprovimes=' +@mes+ ' and 
			a.modoprovicod=b.modoprovicod and
			isnull(b.modoproviregcom,0)=0 and a.cabprovinumero='+@Nprovi+' )'	
exec(@cadsql)
--exec marfice.dbo.co_RegComprasNoIncluyenenLinea_pro 'camtex_tinto','contaprueba','081','05','2003','5692'
GO
