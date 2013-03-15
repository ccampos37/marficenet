SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
***** Objeto:  procedimiento almacenado dbo.ct_CalcComprob_pro    fecha de la secuencia de comandos: 03/01/2008 09:48:12 p.m. *****
actualiza totales en cabecera

*/
CREATE        Proc [ct_CalcComprob_pro]
(
@Servidor	varchar(50),
@Base	 	varchar(50),
@empresa        varchar(2),
@Ano      	varchar(4),
@Mes      	varchar(2),
@Asiento  	varchar(3),
@SubAsiento varchar(4),
@Comprob   	varchar(20))
AS
Declare @SqlCad1 varchar(8000)
Set @SqlCad1='
Declare @Sdebe    Numeric(20,2),@Shaber    Numeric(20,2),
        @Sdebeuss Numeric(20,2),@Shaberuss Numeric(20,2)  
Select 
@Sdebe=Sum(detcomprobdebe),@Shaber=Sum(detcomprobhaber),
@Sdebeuss=Sum(detcomprobussdebe),@Shaberuss=Sum(detcomprobusshaber)
from '+'['+@Base+'].dbo.ct_detcomprob'+@Ano+'
Where 
empresacodigo='''+@empresa+''' and 
cabcomprobmes='+@mes+' And
cabcomprobnumero='''+@Comprob+''' And 
asientocodigo='''+@Asiento+''' And 
subasientocodigo='''+@SubAsiento+'''
Update '+'['+@Base+'].dbo.ct_cabcomprob'+@Ano+'
	Set cabcomprobtotdebe=@Sdebe,
		cabcomprobtothaber=@Shaber,
		cabcomprobtotussdebe=@Sdebeuss,
		cabcomprobtotusshaber=@Shaberuss
Where 
empresacodigo='''+@empresa+''' and 
cabcomprobmes='+@mes+' And
cabcomprobnumero='''+@Comprob+''' And 
asientocodigo='''+@Asiento+''' And 
subasientocodigo='''+@SubAsiento+''''

execute (@SqlCad1)
GO
