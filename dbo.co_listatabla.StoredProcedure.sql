SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [co_listatabla]  @tablatmp varchar(50)
as
exec('select * from '+@tablatmp )
GO
