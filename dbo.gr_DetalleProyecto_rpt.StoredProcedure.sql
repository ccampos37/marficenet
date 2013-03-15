SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute gr_DetalleProyecto_rpt  'aliterm2012','%%'
select * from aliterm2012.dbo.gr_proyectos


*/

CREATE proc [gr_DetalleProyecto_rpt]
(
@base varchar(50),
@proyecto  varchar(11)
)
as

declare @sql varchar(4000)

set @sql=' SELECT  a.proyectocodigo, a.proyectodescripcion, a.clientecodigo, b.clienterazonsocial, proyectoimporte,
                   tipogastosdescripcion,  z.*
   from '+@base+'.dbo.GR_PROYECTOS a 
   inner join '+@base+'.dbo.vt_cliente b on a.clientecodigo=b.clientecodigo 
   inner join (  SELECT tipo=''PROVISIONES'', a.empresacodigo, b.cabprovinumero, a.proyectocodigo, b.gastoscodigo, c.gastosdescripcion,
                d.cabprovifchdoc, d.cabprovinumdoc,proveedorcodigo,cabprovirznsoc,c.tipogastoscodigo,
                monto=sum(case when d.monedacodigo =''01'' then (b.detprovitotal-b.detproviigv)/ISNULL(e.tipocambioventa,1) 
                                 else (b.detprovitotal-b.detproviigv) end )
                FROM '+@base+'.dbo.GR_PROYECTOS a
                inner join '+@base+'.dbo.co_detalleprovisiones b on a.proyectocodigo =b.entidadcodigo 
                inner join '+@base+'.dbo.co_cabeceraprovisiones d on b.empresacodigo=d.empresacodigo and b.cabprovinumero=d.cabprovinumero  
                left join '+@base+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo 
                inner join '+@base+'.dbo.ct_tipocambio e on d.cabprovifchdoc =e.tipocambiofecha 
                WHERE proyectocodigo like ('''+@PROYECTO+''')
                group by a.empresacodigo,b.cabprovinumero,a.proyectocodigo,b.gastoscodigo, c.gastosdescripcion,
                         d.cabprovifchdoc, d.cabprovinumdoc,proveedorcodigo,cabprovirznsoc,c.tipogastoscodigo


                union all

                SELECT tipo=''TESORERIA'', a.empresacodigo,b.cabrec_numrecibo,a.proyectocodigo,b.detrec_gastos ,gastosdescripcion,
                detrec_fechacancela, b.detrec_numdocumento,b.clientecodigo,cabprovirznsoc='''',tipogastoscodigo,
                monto=sum(b.detrec_importedolares)
                FROM '+@base+'.dbo.GR_PROYECTOS a
                inner join '+@base+'.dbo.te_detallerecibos b on a.proyectocodigo =b.entidadcodigo 
                inner join '+@base+'.dbo.te_cabecerarecibos c on b.cabrec_numrecibo=c.cabrec_numrecibo
                left join '+@base+'.dbo.co_gastos d on b.detrec_gastos=d.gastoscodigo 
                inner join '+@base+'.dbo.ct_tipocambio e on b.detrec_fechacancela =e.tipocambiofecha 
                WHERE proyectocodigo like ('''+@PROYECTO+''')
                group by  a.empresacodigo,b.cabrec_numrecibo,a.proyectocodigo,b.detrec_gastos ,gastosdescripcion,
                          detrec_fechacancela, b.detrec_numdocumento,b.clientecodigo, tipogastoscodigo
             ) Z ON A.proyectocodigo=z.proyectocodigo 
             left join '+@base+'.dbo.co_tipogastos z1 on z.tipogastoscodigo=z1.tipogastoscodigo  '
             

execute (@sql)
GO
