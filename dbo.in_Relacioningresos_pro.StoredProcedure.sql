SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Objeto:  procedimiento almacenado dbo.al_RelacionRequerimientos_pro    fecha de la secuencia de comandos: 08/03/2007 06:12:12 p.m. ******/
CREATE     procedure [in_Relacioningresos_pro]
@base varchar(50),
@proyecto varchar(2),
@tipoinmueble varchar(2),
@tabla varchar(30)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'
SELECT * into ['+@base+'].dbo.'+@tabla+' 
 From ['+@base+'].dbo.dbo.in_caracteristicasinmueblexproyecto
     where proyectocodigo LIKE ('''+@proyecto+''')
           and tipoinmueble like (''' +@tipoinmueble+''')'  
set @ncadena=@ncadena+' ORDER BY 1,2,3 '
execute(@NCADENA)
--EXEC in_Relacioningresos_pro 'montereal','01','%%','##xxx'
--select * from ##xxx
--select * from montereal.dbo.in_proyectos
--execute sp_addlinkedserver montereal
GO
