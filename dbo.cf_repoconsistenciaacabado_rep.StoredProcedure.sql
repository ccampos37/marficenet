SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cf_repoconsistenciaacabado_rep]
@base varchar(50),
@fini varchar(10),
@ffin varchar(10),
@orden varchar(20)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
	Set @ncade=N'Select 
							a.ordennumero,
							a.cortenumero,
							a.habilitadonumerodepqte,
							a.habilitadoestadodelpqte,
							a.colorcodigo,
							b.colordescripcion,
							a.tallascodigo,
							a.detalleconfeccionprendasprimera,
							a.detalleconfeccionprendassegunda,
							a.detalleconfeccionprendasinconfeccion
						from ['+@base+'].dbo.cf_hojadehabilitado a
						inner join ['+@base+'].dbo.cf_colores b
						on a.colorcodigo=b.colorcodigo
						where a.habiltadofecharecepcionacabado>=@fini and 
									a.habiltadofecharecepcionacabado<=@ffin and 
									a.ordennumero like @orden'
						
				
	set @npara=N'@fini varchar(10),@ffin varchar(10),@orden varchar(20)'
	
	execute sp_executesql @ncade,@npara,@fini,@ffin,@orden
GO
