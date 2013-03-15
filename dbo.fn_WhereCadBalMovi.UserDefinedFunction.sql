SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [fn_WhereCadBalMovi]
(@op int)      
RETURNS varchar(2000)
BEGIN 	
	DECLARE  @sqlcad varchar(500)
	SET @sqlcad=
        Case @op 
			When 0 then ''			
        	When 1 then '(debeAC+ haberAC)>0'
			When 2 then '(debeAC+ haberAC)=0' 					
			When 3 then '(debe)>0'
			When 4 then '(debe)=0'			             
			When 5 then '(haber)>0'
			When 6 then '(haber)=0'       
        End   
	RETURN @sqlcad
END
GO
