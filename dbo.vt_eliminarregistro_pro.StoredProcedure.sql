SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [vt_eliminarregistro_pro]
@base varchar(50),
@tabla varchar(50),
@campo varchar(50),
@valor varchar(100)
as
declare @cadena varchar(200)
declare @parame nvarchar(100)
declare @errores int
  set @errores = 0	
  set @cadena='Delete From ['+@base +'].dbo.'+@tabla +' where '+@campo+ '='+ @valor+''
  set @parame=N'@condi varchar(100)'
  
  
   execute @cadena  
  if (@@error <> 0 )
     begin
     	set @errores = @@error
     	print 'Se produjo un error'	
     end	
return (0)
GO
