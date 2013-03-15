SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [fn_getcad_gastos]
(@nmes int,
@op int)      
RETURNS varchar(1000)
BEGIN 
  DECLARE  @i int,
  @sqlcad varchar(1000),
  @mes varchar(2),
  @id varchar(50)
  SET @i=1 
  SET @sqlcad=''
	IF @op=1 SET @id='gastos'
	IF @op=2 SET @id='gastosuss'
--	IF @op=3 SET @id='gastos'
--	IF @op=4 SET @id='gastosuss'
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
