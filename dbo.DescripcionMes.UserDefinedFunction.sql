SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [DescripcionMes]
(@valor as sql_variant )      
RETURNS char(10)
BEGIN 	
	declare @num as float,@flag as bit
	set @num=cast(@valor as float)	
	IF (@@ERROR = 8114) or (@@ERROR <> 0)
		set @flag=0
	else 
		set @flag=1
	
	Return @flag
    	
END
GO
