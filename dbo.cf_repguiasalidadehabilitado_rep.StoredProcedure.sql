SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [cf_repguiasalidadehabilitado_rep]
@base varchar(50),
@corte varchar(20),
@orden varchar(20),
@fini varchar(10),
@ffin varchar(10),
@linea varchar(10),
@tipodocu varchar(10),
@docu varchar(11)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
Set @ncade=N'select a.habilitadofechaaconfeccion,
					   a.cortenumero,
					   a.lineadeconfeccioncodigo,
					   c.lineadeconfecciondescripcion,	
					   a.habilitadonumerodepqte,
				       a.ordennumero,
					   a.colorcodigo,e.colordescripcion,
					   a.tallascodigo,
					   a.habilitadocantidaddeprendasxpqte,
					   b.modelocodigo,d.modelodescripcion				   	 
				from ['+@base+'].dbo.cf_hojadehabilitado A
					 inner join ['+@base+'].dbo.cf_cabeceraordendefabricacion B
					  on A.ordennumero=B.ordennumero
					 inner join ['+@base+'].dbo.cf_lineasconfeccion C
					  on A.lineadeconfeccioncodigo=C.lineadeconfeccioncodigo
					 inner join ['+@base+'].dbo.cf_modelos D
					  on b.modelocodigo=d.modelocodigo	
					 inner join ['+@base+'].dbo.cf_colores E
					  on a.colorcodigo=e.colorcodigo 
				where a.cortenumero like @corte and 
					  a.ordennumero like @orden and
					  a.habilitadofechaaconfeccion>=@fini and
					  a.habilitadofechaaconfeccion<=@ffin and
					  a.lineadeconfeccioncodigo like @linea and 
					  a.habilitatipodocuhabilitado=@tipodocu and
					  a.habilitadocuhabilitado=@docu and 
					  a.habilitadoestadodelpqte=''1'''
Set @npara=N'@corte varchar(20),
			@orden varchar(20),
			@fini varchar(10),
			@ffin varchar(10),
			@linea varchar(10),
			@tipodocu varchar(10),
			@docu varchar(11)'
execute sp_executesql @ncade,@npara,@corte,
								   @orden,
								   @fini,
								   @ffin,
								   @linea,
								   @tipodocu,
								   @docu
GO
