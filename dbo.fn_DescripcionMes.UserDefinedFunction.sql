SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  función definida por el usuario dbo.fn_cadBalance    Fecha de la secuencia de comandos: 01/01/2008 08:18:11 p.m. ******/
/*
drop  FUNCTION dbo.fn_cadBalance
*/
CREATE   FUNCTION [fn_DescripcionMes] (@nmes int )      
RETURNS char(12)
begin
declare @mes as varchar(12) 	
set @Mes=case @nmes
	      when 1 then 'ENERO' 
	      when 2 then 'FEBRERO'
	      when 3 then 'MARZO'
	      when 4 then 'ABRIL'
	      when 5 then 'MAYO'
	      when 6 then 'JUNIO'
	      when 7 then 'JULIO'
	      when 8 then 'AGOSTO'
	      when 9 then 'SETIEMBRE'
              when 10 then 'OCTUBRE'
	      when 11 then 'NOVIEMBRE'
	      when 12 then 'DICIEMBRE'
        end
RETURN @mes
end
GO
