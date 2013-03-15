SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE function [fn_ubicacolumna](@cad varchar(50),@numdia int )--,@ntotal int) 
returns int
as
Begin
declare @i as int
declare @num as int
set @i=1
while @i<=5
	begin
		set @num=left(@cad,patindex('%*%',@cad)-1)
		set @cad=right(@cad,len(@cad)-patindex('%*%',@cad))
		if @num>=@numdia 
			break
		set @i=@i+1
	end
return @i
end
GO
