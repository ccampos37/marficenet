SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [fn_ArmaCriterio]
(@cad varchar(500),@car varchar(10),@campocrit varchar(1000)='')      
RETURNS varchar(2000)
BEGIN
Declare 
	@pos int,
    @criterio varchar(2000),
    @valor varchar(2000),
    @Cadena varchar(2000)   
	Set @criterio=''   
    While 1=1
	Begin
        Set @pos = CHARINDEX(@car,@cad)
        If @pos = 0  Break 
        If (@campocrit ='')  Or (RTrim(@car) = ',') 
            Set @valor = ''''+Left(@cad, @pos - 1)+ ''''
        Else
            Set @valor = ''''+Left(@cad, @pos) + ''''
        
        Set @cad = Right(@cad, (Len(@cad) - @pos))
        If @campocrit <> ''
           Set @criterio = @criterio + @campocrit + ' like ' + @valor + ' or '
        Else
           Set @criterio = @criterio + @valor + @car
    End 
    If @campocrit <> ''
       Set @Cadena = Left(@criterio, Len(@criterio) - 3)
    Else
       Set @Cadena = Left(@criterio, Len(@criterio) - 1)
    
	RETURN @Cadena
END
GO
