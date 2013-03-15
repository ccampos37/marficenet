SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Objeto:  procedimiento almacenado dbo.al_ConsumoArticulosCentroCostos_rpt    fecha de la secuencia de comandos: 30/01/2007 10:41:03 a.m. ******/
/****** Objeto:  procedimiento almacenado dbo.al_ConsumoArticulosCentroCostos_rpt    fecha de la secuencia de comandos: 30/12/2006 01:52:31 p.m. ******/
/****** Objeto:  procedimiento almacenado dbo.al_RelacionRequerimientos_rpt    fecha de la secuencia de comandos: 30/12/2006 01:10:57 p.m. ******/
CREATE      procedure [al_ConsumoArticulosCentroCostos_rpt]
@base varchar(50),
@costo1  varchar(10),
@costo2  varchar(10),
@fechaini varchar(10),
@fechafin varchar(10)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'select a.catd,a.caalma,a.catd,a.canumdoc,a.cafecdoc,b.decodigo,
c.adescri,deprecio,
ingresos=case when catipmov=''I'' then decantid else 0 end,
salidas=case when catipmov=''S'' then decantid else 0 end,
c.aunidad,decencos,d.centrocostodescripcion,dequipo,e.entidadrazonsocial
From ['+@base+'].dbo.movalmcab a
    inner join ['+@base+'].dbo.movalmdet b
       on a.caalma+a.catd+a.canumdoc=b.dealma+b.detd+b.denumdoc
    INNER JOIN ['+@base+'].dbo.maeart c
       on b.decodigo= c.acodigo
    left join ['+@base+'].dbo.ct_centrocosto d 
       on b.decencos=d.centrocostocodigo
    left join ['+@base+'].dbo.ct_entidad e
       ON b.dequipo=e.entidadcodigo
    Where casitgui<>''A'' and 
          b.decodigo >='''+@costo1+''' and b.decodigo <='''+@costo2+''' and
          a.cafecdoc>='''+ @fechaini+''' and a.cafecdoc<='''+@fechafin+'''  '
execute(@NCADENA)
--EXEC al_ConsumoArticulosCentroCostos_rpt 'acuaplayacasma','10110','40110','11/12/2006','31/12/2006'
GO
