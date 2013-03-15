SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [al_kits_rpt]
as
Declare @ncadena nvarchar(2000)
Set @ncadena=N'SELECT a.CODkit,
    descrkit= (select b.adescri from fox.dbo.maeart b where 
               b.acodigo =a.codkit),
    a.codart,b.adescri
    from fox.dbo.kits a inner join fox.dbo.maeart b 
           on a.codart=b.acodigo order by 2'
exec(@NCADENA)
--EXECute al_kits_rpt 
--select * from camtex_tj.dbo.al_kardex_val
GO
