SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [al_listagiroproveedor_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
declare @c as varchar(2)
set @c='62'
set @cadena='Select *  
             From ['+@base+'].dbo.TABAYU A   
             where A.TCOD='''+@c+''' '
execute(@cadena)
GO
