SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---DROP PROC al_listaautorizado_rep
CREATE  procedure [al_listaautorizado_rep]
@base as varchar(50),
@cODIGO AS VARCHAR(2)
as
declare @cadena as nvarchar(1000)
---declare @c as varchar(2)
----set @c='13'
set @cadena='Select *  
             From ['+@base+'].dbo.TABAYU A 
             where tcod='+@codigo+''
execute(@cadena)
GO
