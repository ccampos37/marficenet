SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc [co_RegComprasNoIncluyen_pro]
execute [co_RegComprasNoIncluyen_pro] 'planta_casma','planta_casma','081','01','2008'
*/
CREATE  procedure [co_RegComprasNoIncluyen_pro]
(
	@basecompra		varchar(50),
	@baseconta		varchar(50),
	@asiento			varchar(3),
	@mes				varchar(2),
	@ano				varchar(4)
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
			isnull(b.modoproviregcom,0)=0  )'	
print(@cadsql)
--exec marfice.dbo.co_RegComprasNoIncluyen_pro 'camtex_tinto','contaprueba','081','05','2003'
GO
