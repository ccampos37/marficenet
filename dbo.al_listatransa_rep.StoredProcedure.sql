SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [al_listatransa_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
---declare @c as varchar(2)
---set @c='62'
set @cadena='Select A.TT_TIPMOV,A.TT_CODMOV,A.TT_DESCRI 
             From ['+@base+'].dbo.tabtransa A   
             '
execute(@cadena)
GO
