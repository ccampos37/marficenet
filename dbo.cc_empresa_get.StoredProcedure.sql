SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [cc_empresa_get]
as
Select * from desarrollo.dbo.co_multiempresas order by empresacodigo
GO
