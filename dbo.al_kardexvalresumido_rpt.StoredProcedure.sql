SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Execute al_kardexvalresumido_rpt 'ziyaz','02','201001'
select * from dbo.AL_MOVRESMES

*/


CREATE  procedure [al_kardexvalresumido_rpt]
(
@base varchar(50),
@almacen varchar(2),
@mes varchar(6)
)
as
Declare @cadena nvarchar(2000)
Declare @nparame nvarchar(2000)

SET @cadena=' SELECT a.*,b.acodigo,b.adescri,b.aunidad,tadescri,fam_nombre
                    from ['+@base+'].dbo.MOresMES a 
                   inner JOIN ['+@base+'].dbo.maeart b ON a.smcodigo=b.ACODIGO
                   inner join ['+@base+'].dbo.tabalm c ON a.smalma=c.taalma
                   left join ['+@base+'].dbo.familia d ON b.afamilia=d.fam_codigo WHERE a.smalma like '''+@ALMACEN+''' 
                      and a.smmespro='''+@mes+''' and 
                     (isnull(SMCANENT,0)+isnull(SMCANSAL,0)+ isnull(SMANTCAN,0)) > 0  order by 1,2,3,5 '
execute(@CADENA)
GO
