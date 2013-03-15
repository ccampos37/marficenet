SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       procedure [al_listaarticulo_rep]
@base as varchar(50)

as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)

SET @cadena =N'Select acodigo,adescri,acodigo2,adescri2,afamilia,acuenta,
             fam_nombre,aunidad
             From ['+@base+'].dbo.MAEART A  
             left join ['+@base+'].dbo.familia b
             on afamilia = fam_codigo '

execute(@cadena)
-- EXEC al_listaarticulo_rep 'ziyaz'
GO
