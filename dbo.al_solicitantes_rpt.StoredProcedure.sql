SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- exec al_solicitantes_rpt 'ziyaz'
CREATE  procedure [al_solicitantes_rpt]
@base varchar(15)
as
Declare @ncadena nvarchar(2000)

Set @ncadena=N'select * from ['+@base+'].dbo.co_solicitantes'

exec(@NCADENA)
GO
