SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [al_grupos_rpt]
@base as varchar(50)
as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)
SET @cadena =N'Select b.fam_nombre,a.fam_codigo,
             c.lin_nombre,a.lin_codigo,
             a.gru_codigo,gru_nombre
             From ['+@base+'].dbo.grupo A  
             inner join ['+@base+'].dbo.familia b
                   on a.fam_codigo=b.fam_codigo
             inner join ['+@base+'].dbo.lineas c
                   on a.lin_codigo=c.lin_codigo 
             order by a.fam_codigo,a.lin_codigo,a.gru_codigo'
execute(@cadena)
-- EXEC al_grupos_rpt 'acop_centro'
GO
