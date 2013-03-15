SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Objeto:  procedimiento almacenado dbo.al_RelacionRequerimientos_pro    fecha de la secuencia de comandos: 08/03/2007 06:12:12 p.m. ******/
CREATE     procedure [in_CaracteristicasInmueble_pro]
@base varchar(50),
@proyecto varchar(2),
@tipoinmueble varchar(2),
@tabla varchar(30)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'
SELECT *  into tempdb.dbo.['+@tabla+'] 
 From ['+@base+'].dbo.in_caracteristicasinmueblexproyecto
     where proyectocodigo LIKE ('''+@proyecto+''')
           and tipoinmueblecodigo like (''' +@tipoinmueble+''')  '
set @ncadena=@ncadena+' ORDER BY 1,2,3 '
execute(@NCADENA)
-- execute in_CaracteristicasInmueble_pro 'gremco','05','05','##xx1'
--select * from ##xx1
-- drop table ##xx1
GO
