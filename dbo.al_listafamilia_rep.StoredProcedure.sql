SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [al_listafamilia_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
---declare @c as varchar(2)
----set @c='13'
set @cadena='Select *  
             From ['+@base+'].dbo.FAMILIA A   
             '
execute(@cadena)
GO
