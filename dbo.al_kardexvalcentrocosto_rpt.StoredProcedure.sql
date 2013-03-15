SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE      procedure [al_kardexvalcentrocosto_rpt]
(
@base varchar(50),
@baseconta varchar(50)
)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT b.centrocostodescripcion,c.adescri,a.*
    FROM ['+@base+'].dbo.al_kardex_cc a
	left JOIN ['+@baseconta+'].dbo.ct_centrocosto b
		ON a.centrocostocodigo=b.centrocostocodigo
        left join ['+@base+'].dbo.maeart c
              on cod_art=acodigo 
      WHERE A.tip_transa<>''NI'''
--Set @nparame=N'@tipo varchar(2),@numero varchar(11)'
execute (@NCADENA)
--EXEC al_kardexvalcentrocosto_rpt 'acuaplayacasma','acuaplayacasma'
GO
