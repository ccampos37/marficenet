SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [al_kardexdetallado_rpt]
@BASE AS NVARCHAR(20)
AS
DECLARE @CADENA AS NVARCHAR(1000)
SET @CADENA=N'SELECT * FROM ['+@BASE+'].dbo.kardexaux a
    inner join ['+@BASE+'].dbo.maeart b on a.c1=b.acodigo '
execute(@CADENA)
-- execute al_kardexdetallado_rpt 'green'
GO
