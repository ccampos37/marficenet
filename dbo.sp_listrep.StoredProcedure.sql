SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute sp_listrep 'planta_casma','af_TEMPREPAJUS',''

*/


CREATE           PROCEDURE [sp_listrep]
@BASE AS VARCHAR(50),
@TABLA AS VARCHAR(50),
@where as varchar(200)=' '
AS
DECLARE @CADENA AS NVARCHAR(1000)
SET @CADENA='SELECT * FROM ['+@BASE+'].dbo.'+@tabla+' '
if @where<>' ' set @cadena=@cadena+' where '+ @where
execute(@CADENA)
--execute sp_listrep 'planta_casma','cp_proveedor','isnull(proveedorcontribuyente,0)=1'
GO
