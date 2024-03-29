SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from planta_casma.dbo.ct_gastos2008
drop  proc ct_listacentrocostosresumen_rpt
execute ct_listacentrocostosresumen_rpt 'ziyaz','03','2009','07'
*/
ALTER       proc [ct_listacentrocostosresumen_rpt]
@Base varchar(50),
@empresa varchar(2),
@anno varchar(4), 
@mes varchar(2)

as

Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 'select descr=left(a.cuentacodigo,2)+'' - ''+a.cuentadescripcion,
     z.cuentacodigo,z.cuentadescripcion ,
     adm=sum(adm),admacum=sum(admacum),
     vtas=sum(vtas),vtasacum=sum(vtasacum),
     prod=sum(prod),prodacum=sum(prodacum)
    from
   ( select a.empresacodigo,a.cuentacodigo,B.CuentaDescripcion,
     adm=case when left(a.centrocostocodigo,1)=''1'' then sum(gastos'+@mes+') else 0 end,
     admacum=case when left(a.centrocostocodigo,1)=''1'' then sum(gastosacum'+@mes+') else 0 end,
     vtas=case when left(a.centrocostocodigo,1)=''2'' then sum(gastos'+@mes+') else 0 end,
     vtasacum=case when left(a.centrocostocodigo,1)=''2'' then sum(gastosacum'+@mes+') else 0 end,
     prod=case when left(a.centrocostocodigo,1)=''3'' then sum(gastos'+@mes+') else 0 end,
     prodacum=case when left(a.centrocostocodigo,1)=''3'' then sum(gastosacum'+@mes+') else 0 end
     from ['+@base+'].dbo.ct_gastos'+@anno+' a
     inner join ['+@base+'].dbo.[ct_cuenta] B 
            on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
     where a.empresacodigo='''+@empresa+'''  and gastosacum'+@mes+' <> 0
     group by a.empresacodigo,a.cuentacodigo,b.cuentadescripcion,a.centrocostocodigo
   ) as z
   inner join ['+@base+'].dbo.[ct_cuenta] a
            on z.empresacodigo=a.empresacodigo and left(z.cuentacodigo,2) = a.cuentacodigo 
     group by a.cuentacodigo,a.cuentadescripcion,z.cuentacodigo,z.cuentadescripcion '

execute(@sqlcad)












































set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
