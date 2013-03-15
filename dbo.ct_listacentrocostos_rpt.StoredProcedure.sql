SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop  proc ct_listacentrocostos_rpt
execute ct_listacentrocostos_rpt 'planta_casma','01','2008','01',1
*/
CREATE       proc [ct_listacentrocostos_rpt]
@Base varchar(50),
@empresa varchar(2),
@anno varchar(4), 
@mes varchar(2),
@tipo varchar(1)='0'
as
Declare @sqlcad varchar(5000)
if @tipo='0' Set @sqlcad=''+ 
    'Select a.centrocostocodigo,c.centrocostodescripcion, A.cuentacodigo,B.CuentaDescripcion,
            a.asientocodigo,subasientocodigo,cabcomprobnumero,detcomprobitem,
            detcomprobnumdocumento,detcomprobglosa,A.detcomprobdebe,A.detcomprobhaber,
            left(A.cuentacodigo,2) as cod2
    From ['+@base+'].dbo.[ct_detcomprob'+@anno+'] A
         inner join ['+@base+'].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
         left join ['+@base+'].dbo.[ct_centrocosto] C 
                on a.empresacodigo=c.empresacodigo and A.centrocostocodigo=C.centrocostocodigo 
    Where a.empresacodigo='''+@empresa+''' and a.centrocostocodigo<>''00'' and 
          A.cabcomprobmes=''' + @mes + ''' '
if @tipo='1'  Set @sqlcad=''+ ' select gastosacum=gastosacum'+@mes+',z.mes,a.centrocostocodigo,
	   c.centrocostodescripcion,a.cuentacodigo,
           B.CuentaDescripcion,cuenta=left(a.cuentacodigo,2),centro=left(a.centrocostocodigo,2)
          from ['+@base+'].dbo.ct_gastos'+@anno+' a
           left join 
          ( select a.empresacodigo, a.centrocostocodigo, A.cuentacodigo,
               mes=sum(A.detcomprobdebe -A.detcomprobhaber) 
            From ['+@base+'].dbo.[ct_detcomprob'+@anno+'] A
            Where a.empresacodigo='''+@empresa+''' and a.centrocostocodigo<>''00'' and A.cabcomprobmes=''' + @mes + '''
            group by a.empresacodigo,a.centrocostocodigo, A.cuentacodigo 
          ) as z 
            on a.empresacodigo=z.empresacodigo and a.cuentacodigo=z.cuentacodigo and a.centrocostocodigo=z.centrocostocodigo 
        inner join ['+@base+'].dbo.[ct_cuenta] B 
              on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo and b.cuentaestadoccostos =1
         left join ['+@base+'].dbo.[ct_centrocosto] C 
              on a.empresacodigo=c.empresacodigo and A.centrocostocodigo=C.centrocostocodigo
         where z.mes > 0 or (gastosacum'+@mes+'-z.mes) > 0 ' 

execute(@sqlcad)
GO
