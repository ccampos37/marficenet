SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [al_listatransportista_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)

set @cadena='Select TRACODIGO,TRANOMBRE,traplaca,TRATELEF,TRAbreve
             From ['+@base+'].dbo.al_transporte A   
             '
execute(@cadena)
GO
