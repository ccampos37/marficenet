SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [al_inventarioFisico_rpt]
@base as varchar(50),
@filtro as varchar(100)
as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)
SET @cadena =N'Select a.*,b.*,c.acodigo2,c.adescri,c.afamilia ,d.fam_nombre
             From ['+@base+'].dbo.al_invenfisicoCab A  
             inner join ['+@base+'].dbo.al_invenFisicoDet b
                   on a.auxnuminve=b.auxnuminve
             inner join ['+@base+'].dbo.maeart c
                   on b.auxcodart=c.acodigo 
             inner join ['+@base+'].dbo.familia d
                   on c.afamilia=d.fam_codigo '
If @filtro<>'' set @cadena=@cadena +' where '+@filtro
set @cadena=@cadena +' order by c.afamilia,b.auxcodart'
EXECUTE(@cadena)
-- EXEC al_inventarioFisico_rpt 'acuaplayacasma',' B.AUXNUMINVE=''11000002'' AND B.AUXALMA=''01'''
GO
