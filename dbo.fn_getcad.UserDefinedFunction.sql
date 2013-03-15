SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [fn_getcad]
(@nmes int,@op int)      
RETURNS varchar(1000)
BEGIN 
	DECLARE  @i int,@sqlcad varchar(1000),@mes varchar(2),@id varchar(50)
	SET @i=1 
	SET @sqlcad=''
	IF @op=1 SET @id='saldohaber'
	IF @op=2 SET @id='saldodebe'
	IF @op=3 SET @id='saldousshaber'
	IF @op=4 SET @id='saldoussdebe'
	WHILE @i <=@nmes
	BEGIN
		SET @mes=replicate('0',2-len(@i))+ rtrim(cast(@i as varchar(2))) 	
		SET @sqlcad=@sqlcad+@id+@mes
    	IF @i<@nmes SET @sqlcad=@sqlcad+'+'    
		SET @i=@i+1
	END
    RETURN @sqlcad
END
GO
