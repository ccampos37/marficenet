SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [al_listakits_rpt]
(
@base varchar(50),
@kits varchar(20),
@alma varchar(2)
)
as
Declare @ncadena nvarchar(2000)
Set @ncadena=N'SELECT a.CODkit,
    descrkit= (select top 1 b.adescri from [fox].dbo.kits a 
              inner join [fox].dbo.maeart b on a.codkit=b.acodigo ),
    a.codart,b.adescri,d.stalma,d.stskdis, a.canart
    from ['+@base+'].dbo.kits a inner join ['+@base+'].dbo.maeart b 
           on a.codart=b.acodigo
         inner join ['+@base+'].dbo.stkart d on a.codart=d.stcodigo and stalma='+ @alma +'  
    where a.codkit like '''+ @kits +''''
exec(@NCADENA)
--EXECute al_listakits_rpt 'fox','001010001','02',100
--select * from camtex_tj.dbo.al_kardex_val
GO
