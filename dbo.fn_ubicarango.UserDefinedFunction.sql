SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.fn_ubicarango('7*15*30*45*60*',20) 
--select 5
CREATE  function [fn_ubicarango](@cad varchar(50),@ntope int )--,@ntotal int) 
returns int
as
Begin
declare @i as int
declare @num as int
declare @rmin as int
Set @rmin=0
set @i=1
while @i<=@ntope
	begin
		set @num=left(@cad,patindex('%*%',@cad)-1)
		set @cad=right(@cad,len(@cad)-patindex('%*%',@cad))
		set @i=@i+1
		If @rmin<@ntope And @num>=@ntope
			Begin break end
		Else
			Begin
				Set @rmin=@num
			End
	end
return @num
end
/*
declare @fechavar datetime,@numfecha int
set @fechavar=cast(0 as datetime)
	
	Select @numfecha=Cast(	
	(dateadd(day,@dia- day(@fechavar),
	dateadd(month,@mes  - month(@fechavar),	
        dateadd(year,@año-(year(@fechavar)),cast(0 as datetime))))) as int)
return @numfecha
*/
GO
