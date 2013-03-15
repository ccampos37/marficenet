SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [co_actcorraux_pro] 
 ( @base varchar(30),
   @empresa varchar(2),
   @libro varchar(3),
   @Ano Varchar(4),	
   @mes varchar(2), 	    
   @numero varchar(6)
  )
as
DECLARE @sqlcad nvarchar(4000)
set @sqlcad= 'UPDATE ['+@base+'].dbo.ct_librocorre
     SET libronumcorr'+@mes+'='+@numero+'
WHERE empresacodigo='''+@empresa+''' and librocodigo='''+@libro+''' and libroAnno='''+@Ano+'''  '

execute(@sqlcad)
--EXECUTE co_actcorraux_pro 'gremco','12','009','2009','05',5
GO
