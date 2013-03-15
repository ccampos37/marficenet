SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [al_listalote]
--Declare
@base varchar(100),
@Alma varchar(10),
@flagpro varchar(1),
@ini  varchar(15)=null,
@fin  varchar(15)=null
as
/*Set @base='bdcom_tejeduria'
Set @Alma='%%'
set @flagpro='1'
set @ini='091ATAO'
set @fin='10034TP'*/
Declare
@SqlCad Varchar(8000),
@Sqlvar varchar(500)
set @SqlCad='
select A.*,C.ADESCRI, CCODCLI=B.PRVCCODIGO,CNOMCLI=B.PRVCNOMBRE,CNUMRUC=b.PRVCRUC 
from ['+@base+'].dbo.stklote A 
left join ['+@base+'].dbo.MAEPROV b on A.stscodprov=B.PRVCCODIGO
inner join ['+@base+'].dbo.maeart C on A.STSCODIGO=C.ACODIGO
Where STSALMA like '''+@Alma+'''    
 ' 
SET @Sqlvar=''
if @flagpro='1' 
	set @Sqlvar=' and A.STSCODIGO BETWEEN '''+@ini+''' AND '''+@fin+''''   
Exec(@SqlCad+@Sqlvar)
GO
