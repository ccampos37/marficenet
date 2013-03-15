SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [al_documentosalmacen_rep]
@base as varchar(50),
@almacen as varchar(2),
@fechaini as varchar(12),
@fechafin as varchar(12),
@tipodocu as varchar(2)
as
declare @cadena as nvarchar(1000)
declare @a as char(1)
set @a='A'
set @cadena='SELECT * FROM ['+@base+'].dbo.MOVALMCAB 
	     WHERE CAALMA='+@almacen + ' and 
		   CAFECDOC>=CONVERT(char(12),'''+@fechaini+''', 3) and
		   CAFECDOC<=convert(char(12),'''+@fechafin+''',3) and
		   catd='''+@tipodocu+''' And CASITGUI <>'''+@a +''''
execute(@cadena)
GO
