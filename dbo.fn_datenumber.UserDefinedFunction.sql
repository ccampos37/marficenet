SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  function [fn_datenumber](@dia int,@mes int,@año int) 
returns int
as
Begin
declare @fechavar datetime,@numfecha int
set @fechavar=cast(0 as datetime)
	
	Select @numfecha=Cast(	
	(dateadd(day,@dia- day(@fechavar),
	dateadd(month,@mes  - month(@fechavar),	
        dateadd(year,@año-(year(@fechavar)),cast(0 as datetime))))) as int)
return @numfecha
end
/*
EXEC('
select cargoapefecemi,*  from vt_cargo
where 
floOr(CAST (cargoapefecemi AS float))  between  dbo.datenumber(19,9,2002) and  dbo.datenumber(19,9,2002)')
*/
GO
