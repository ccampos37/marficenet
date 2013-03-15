SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   procedure [al_saldopendientekits_rpt]
(
@base varchar(50),
@kits varchar(20),
@alma varchar(2),
@cantidad NVARCHAR(10)
)
as
Declare @ncadena nvarchar(2000)
Set @ncadena=N'SELECT a.CODkit,
    descrkit= (select b.adescri from [fox].dbo.maeart b where a.codkit=b.acodigo ),
    a.codart,b.adescri,d.stalma,d.stskdis, a.canart,'+@cantidad+' as requerimiento
    from ['+@base+'].dbo.kits a inner join ['+@base+'].dbo.maeart b 
           on a.codart=b.acodigo
         left join ['+@base+'].dbo.stkart d on a.codart=d.stcodigo and stalma='+ @alma +'  
    where a.codkit like '''+ @kits +''' order by a.codart '
exec(@NCADENA)
--EXECute al_saldopendientekits_rpt 'foxpruebas','%%','02',100
--select * from camtex_tj.dbo.al_kardex_val
GO
