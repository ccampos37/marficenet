SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [cs_repo2bases_rpt]
--Declare 
@Base varchar(50),
@Baseaux varchar(50),
@op int,
@Criterio varchar(4000)=Null
/*Set @Base='costos'
Set @Baseaux='contaprueba'
Set @op=1
Set @Criterio=''*/
--Exec cs_repo2bases_rpt 'costos','contaprueba',2
As
Declare @sqlcad varchar(8000)
Set @sqlcad=
	case @op 
		when 1 then 
		  '	Select A.costoscodigo,B.costosdescripcion, 
			       A.cuentacodigo,C.cuentadescripcion, A.factorcostos, 
			       A.usuario, A.fechaact
			From ['+@Base+'].dbo.cs_factordectacble A
				inner join ['+@Base+'].dbo.cs_centrodecostos B 
				on A.costoscodigo=B.costoscodigo
				inner join ['+@Baseaux+'].dbo.ct_cuenta C
    				on A.cuentacodigo=C.cuentacodigo ' 
        when 2 then 
		 ' select A.costoscodigo, A.costosdescripcion,
                  A.costosestado, A.costostipo,
                  A.unidadnegociocodigo,B.unidadnegociodescripcion,
                  A.costoprincipal, A.costoauxiliar,
                  A.cuentadebe,ctadescridebe=C.cuentadescripcion,
                  A.cuentahaber,ctadescrihaber=D.cuentadescripcion,
                  A.usuario,A.fechaact
          From  ['+@Base+'].dbo.cs_centrodecostos A
          inner join  ['+@Base+'].dbo.cs_unidaddenegocio B
          on A.unidadnegociocodigo=B.unidadnegociocodigo  
          inner join ['+@Baseaux+'].dbo.ct_cuenta  C
          on A.cuentadebe=c.cuentacodigo 
          inner join ['+@Baseaux+'].dbo.ct_cuenta  D 
          on A.cuentahaber=D.cuentacodigo '
     End
exec(@sqlcad+@Criterio)
GO
