SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_actcorrcomproblibro_pro 
execute ct_actcorrcomproblibro_pro 'mmj2008','2007','12','04',12.00
*/
CREATE    proc [ct_actcorrcomproblibro_pro] 
 (@base varchar(30),
  @empresa varchar(2),
  @anno char(4),	
  @mes char(2), 	
  @libro varchar(20),  
  @numero float
  )
as
DECLARE @sqlcad nvarchar(2000),@sqlparm nvarchar(2000)
set @sqlparm='@empresa varchar(2), @anno char(4),@libro varchar(20),@numero float'
set @sqlcad=''+ 
    'UPDATE ['+@base+'].dbo.ct_librocorre
     SET libronumcorr'+@mes+'=@numero
     WHERE empresacodigo=@empresa and librocodigo=@libro AND libroanno=@anno'
Exec sp_executesql @sqlcad,@sqlparm,@empresa,
                   @anno,@libro,@numero
GO
