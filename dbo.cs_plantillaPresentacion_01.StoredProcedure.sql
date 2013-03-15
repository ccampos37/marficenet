SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_plantillaPresentacion_01 'planta_casma'
*/
create proc [cs_plantillaPresentacion_01]
@basedestino varchar(50)
as
declare @sql as varchar(2000)
set @sql ='select n1=left(a.estructuranumerolinea ,2),
grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),
grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),
 a.* from '+@basedestino+'.dbo.cs_estructurapresentacion a where estructuranivel=3 and 
left(a.estructuranumerolinea ,2) in ( ''01'',''02'') '
execute(@sql)
GO
