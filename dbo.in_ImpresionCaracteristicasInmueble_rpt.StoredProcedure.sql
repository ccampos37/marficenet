SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE     procedure [in_ImpresionCaracteristicasInmueble_rpt]
@base varchar(50),
@proyecto varchar(2),
@tipoinmueble varchar(2),
@inmueble varchar(20)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'
SELECT *,descripcion=e.caracteristicadetalledescripcion From ['+@base+'].dbo.in_inmuebles a
    inner join ['+@base+'].dbo.in_proyectos b
         on b.proyectocodigo=a.proyectocodigo
    inner join ['+@base+'].dbo.in_detalleinmuebles c
         on a.proyectocodigo+a.inmueblecodigo=c.proyectocodigo+c.inmueblecodigo
    inner join ['+@base+'].dbo.in_tiposinmueble d
         on a.tipoinmueblecodigo=d.tipoinmueblecodigo
    left join ['+@base+'].dbo.in_caracteristicasinmueblexproyecto e
         on c.tipoinmueblecodigo+c.caracteristicacodigo+c.caracteristicadetalleitem=
            e.tipoinmueblecodigo+e.caracteristicacodigo+e.caracteristicadetalleitem
     where a.proyectocodigo LIKE ('''+@proyecto+''')
           and a.tipoinmueblecodigo like (''' +@tipoinmueble+''')
           and a.inmueblecodigo like  (''' +@inmueble+''') '
set @ncadena=@ncadena+' ORDER BY 1,2,3 '
execute(@NCADENA)
-- execute in_ImpresionCaracteristicasInmueble_rpt 'montereal','01','06','%%'
--select * from ##xxx
GO
