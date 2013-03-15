SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      procedure [vt_impresionguias_rpt]
@base as varchar(50)

as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)

SET @cadena =N'Select b.aunidad,a.*,c.* From ['+@base+'].dbo.gtempfile a
             inner join ['+@base+'].dbo.maeart b
                   on productocodigo=acodigo 
             left join ['+@base+'].dbo.al_transporte c
                    on a.transportecodigo=c.tracodigo '

execute(@cadena)
-- EXEC vt_impresionguias_rpt 'ziyaz'
GO
