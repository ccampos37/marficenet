SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [vt_ExpoBorraTablas] 
@Base varchar(50)
--exec vt_ExpoBorraTablas 'Transferencia'
As 
Declare @SqlCad Varchar(4000),@NombTabla varchar(50)
Set @SqlCad='Declare Borratabla cursor for 
         Select name From ['+@Base+'].dbo.sysobjects where xtype=''U'''
Exec(@SqlCad)
Open Borratabla
Fetch next from Borratabla into  @NombTabla
While @@Fetch_Status=0 
Begin 
	Exec('Drop Table ['+@Base+'].dbo.'+@NombTabla)
	Fetch next from Borratabla into  @NombTabla
End  
Close Borratabla
Deallocate  Borratabla
select *  into transferencia.dbo.stkart from fox.dbo.stkart
GO
