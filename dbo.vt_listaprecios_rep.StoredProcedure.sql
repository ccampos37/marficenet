SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [vt_listaprecios_rep]
@base varchar(50),
@tabla varchar(50)
as
declare @ncadena nvarchar(1000)
set @ncadena=N'Select * from ['+@base+'].dbo.'+@tabla +' Order by productodescripcion'
execute(@ncadena)
GO
