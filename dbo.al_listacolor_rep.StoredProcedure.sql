SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [al_listacolor_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
declare @cod as varchar(2)
set @cod='12'
set @cadena='Select *
             From ['+@base+'].dbo.MAECOLOR  '
execute(@cadena)
GO
