SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [al_lineas_rpt]
@base as varchar(50)
as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)
SET @cadena =N'Select b.fam_nombre,a.fam_codigo,
              a.lin_codigo,A.lin_nombre
             From ['+@base+'].dbo.lineas A  
             inner join ['+@base+'].dbo.familia b
                   on a.fam_codigo=b.fam_codigo
             order by a.fam_codigo,a.lin_codigo'
execute(@cadena)
-- EXEC al_lineas_rpT 'FOX'
GO
