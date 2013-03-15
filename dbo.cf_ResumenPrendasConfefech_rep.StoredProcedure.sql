SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [cf_ResumenPrendasConfefech_rep] 
--Declare
@Base varchar(50),
@Fechaini varchar(10),
@FechaFin varchar(10)
as
/*
Set @Base='Produccion'
Set @Fechaini='01/01/2003'
Set @FechaFin='15/06/2003'*/
Declare 
	@fechatextini varchar(10),	
    @fechatextfin varchar(10)
Set @fechatextini=Cast(Cast(@FechaIni as Datetime) as real)
Set @fechatextfin=Cast(Cast(@FechaFin as Datetime) as real)
Declare @SqlCad varchar(8000)
Set @SqlCad='
Select 
	A.habilitadofechaaconfeccion,
	A.ordennumero,	
    B.modelocodigo,
	  sum(a.habilitadocantidaddeprendasxpqte) as habilitadocantidaddeprendasxpqte 
From ['+@Base+'].dbo.cf_hojadehabilitado A
Inner Join  ['+@Base+'].dbo.cf_cabeceraordendefabricacion B 
on A.ordennumero=B.ordennumero
Where habilitadofechaaconfeccion between '+@fechatextini+' and '+@fechatextfin+'   
Group By habilitadofechaaconfeccion,A.ordennumero,B.modelocodigo '
Exec(@SqlCad)
GO
