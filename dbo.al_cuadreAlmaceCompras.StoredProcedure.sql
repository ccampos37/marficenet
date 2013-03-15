SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [al_cuadreAlmaceCompras]
as
select b.clienterazonsocial,z.cacodpro,z.carftdoc,z.carfndoc,z.cacodmon,
almacen=sum(z.almacen),
provisiones=sum(z.provisiones)
from (
select tipo='AL',cacodpro,carftdoc='04',carfndoc=left(carfndoc,3)+'-'+right(carfndoc,8),
cacodmon,almacen=round(sum(decantid*deprecio),2),provisiones=00.00
from movalmcab inner join movalmdet
on caalma+catd+canumdoc=dealma+detd+denumdoc
where carftdoc='NC' and cafecdoc>='01/01/2007' 
and cafecdoc<='31/01/2007' and casitgui<>'A'
group by cacodpro,carftdoc,carfndoc,cacodmon 
union all
select tipo='CO',proveedorcodigo,documetocodigo,cabprovinumdoc,
monedacodigo,00.00,round(cabprovitotbru,2)
from co_cabprovi2007
where cabprovimes=1 and documetocodigo='04'
) as z
left join cp_proveedor b on z.cacodpro=b.clientecodigo
group by z.cacodpro,z.carftdoc,z.carfndoc,z.cacodmon,b.clienterazonsocial
having  sum(z.almacen)-sum(z.provisiones)<> 0
order by 1,4
GO
