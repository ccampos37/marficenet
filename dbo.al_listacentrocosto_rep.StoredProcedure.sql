SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [al_listacentrocosto_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
declare @cod as varchar(2)
set @cod='12'
set @cadena='Select A.cencost_codigo,A.cencost_descripcion
             From ['+@base+'].dbo.centro_costos A '
execute(@cadena)
GO
