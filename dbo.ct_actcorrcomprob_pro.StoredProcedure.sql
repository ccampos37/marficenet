SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_actcorrcomprob_pro    fecha de la secuencia de comandos: 01/01/2008 01:23:32 p.m. ******/
/*
drop  proc ct_actcorrcomprob_pro 
*/
CREATE   proc [ct_actcorrcomprob_pro] 
 (@base varchar(30),
  @empresa varchar(2),
  @anno char(4),	
  @mes char(2), 	
  @asiento varchar(20),  
  @numero float
  )
as
DECLARE @sqlcad nvarchar(1000),@sqlparm nvarchar(500)
set @sqlparm='@empresa char(2),@anno char(4),@asiento varchar(20),@numero float'
set @sqlcad=''+ 
    'UPDATE ['+@base+'].dbo.ct_asientocorre    
     SET asientonumcorr'+@mes+'=@numero
     WHERE 
	 empresacodigo=@empresa and asientocodigo=@asiento and asientoanno=@anno '
Exec sp_executesql @sqlcad,@sqlparm,
                   @empresa,@anno,@asiento,@numero
GO
