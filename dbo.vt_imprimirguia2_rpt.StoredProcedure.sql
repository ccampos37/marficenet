SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* execute vt_imprimirguia2_rpt 'ziyaz' */
CREATE procedure [vt_imprimirguia2_rpt]
@base varchar(50)
--@Destino as varchar(50)
as
declare @cadena as nvarchar(2000)

SET @cadena =N'select a.*,b.tranombre,b.traplaca from ['+@base+'].dbo.gtempfile a 
inner join ['+@base+'].dbo.al_transporte b
on a.transportecodigo=b.tracodigo'
execute(@cadena)
GO
