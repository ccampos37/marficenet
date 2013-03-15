SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_plantillaPresentacion 'planta_casma'
*/
CREATE proc [cs_plantillaPresentacion]
@basedestino varchar(50)
as
declare @sql as varchar(2000)
set @sql ='select n1=left(a.estructuranumerolinea ,2),
grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),
grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),
 a.* from '+@basedestino+'.dbo.cs_estructurapresentacion a where estructuranivel=3'
execute(@sql)
GO
