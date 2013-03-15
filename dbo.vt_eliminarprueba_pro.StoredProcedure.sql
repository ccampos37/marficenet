SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [vt_eliminarprueba_pro]
@bdatos nvarchar (50),
@tabla nvarchar(50),
@where nvarchar(50)
as
DECLARE @SQLString NVARCHAR(500)
DECLARE @errores int  
SET @SQLString = N'Delete FROM ' +
		 '['+ @bdatos +'].dbo.'+                  
                 @tabla + ' ' + @where 	                 
EXEC(@SQLString)
if (@@error <> 0 )
     	begin
	RAISERROR (13000,16,1,'Conflicto')
	return (99)
	end
GO
