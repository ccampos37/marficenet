SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--- DROP PROC al_ConsumoCentroCostosArticulos_rpt
CREATE      procedure [al_ConsumoCentroCostosArticulos_rpt]
@base varchar(50),
@costo1  varchar(10),
@costo2  varchar(10),
@fechaini varchar(10),
@fechafin varchar(10)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'select a.catd,a.caalma,a.catd,a.canumdoc,a.cafecdoc,b.decodigo,
c.adescri,
ingresos=case when catipmov=''I'' then decantid else 0 end,
salidas=case when catipmov=''S'' then decantid else 0 end,
deprecio=case when deprecio > 0 then deprecio 
              else (case when catipmov=''I'' then deprecio 
                         else (select stkprepro from ['+@base+'].dbo.stkart st
                               where st.stalma+st.stcodigo=b.dealma+b.decodigo)
                    end)
              end ,        
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
          b.decencos >='''+@costo1+''' and b.decencos <='''+@costo2+''' and
          a.cafecdoc>='''+ @fechaini+''' and a.cafecdoc<='''+@fechafin+'''
    order by adescri  '
execute(@NCADENA)
--EXEC al_ConsumoCentroCostosArticulos_rpt 'acuaplayacasma','10110','40110','11/12/2006','31/12/2006'
GO
