SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [vt_impresionboletas_rpt]
@base as varchar(50)
--@tipo as varchar(1)
--@filtro as varchar(100)
as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)
--SET @BASE ='FOX'
--set @cadena2 = ' Order by Adescri'
--if @tipo='1' 
--   Begin
--        set @cadena2 = ' Order by Acodigo'  
--   End
--
SET @cadena =N'Select codigo= (CASE C.lin_facturaconsolidada when 1 then c.lin_codigo else b.acodigo end),
             descripcion= (CASE C.lin_facturaconsolidada when 1 then c.lin_nombre else b.adescri end),
             lin_nombre,productocodigo,productodescripcion,
             afamilia,alinea,detpedcantpedida,
             detpedmontoprecvta,detpedimpbruto
             From ['+@base+'].dbo.tempfile a
             inner join ['+@base+'].dbo.maeart b
                   on productocodigo=acodigo
             inner join ['+@base+'].dbo.lineas c
             on b.afamilia = c.fam_codigo and b.alinea=c.lin_codigo '
--print(@cadena)
execute(@cadena)
-- EXEC vt_impresionboletas_rpt 'foxPRUEBAS'
GO
