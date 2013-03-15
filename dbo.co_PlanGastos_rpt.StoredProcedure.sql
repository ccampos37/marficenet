SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
--drop proc co_PlanGastos_rpt
CREATE       proc [co_PlanGastos_rpt]
@Base varchar(50),
@BaseConta varchar(50),
@gastoscodigo as varchar(20)
as
Declare @sqlcad varchar(5000)
Set @sqlcad=''+ 
    'Select distinct L1=left(a.gastoscodigo,2),
     l2=left(a.gastoscodigo,4),
     a.gastosnivel,a.gastoscodigo,a.gastosdescripcion,a.cuentacodigo,d.cuentadescripcion,
     gastosctrlcostos= case when  a.gastosctrlcostos=''1''
                           then ''SI'' else ''NO'' end,
     a.gastoscostos,b.sistemaconfiguragastos,
     c.tipoanaliticodescripcion,
     habilitadodetraccion= case when  a.habilitadodetraccion=''1''
                           then ''SI'' else ''NO'' end,
     a.gastosequivalente,
     estado=case when a.gastosestado=''0''
                   then  ''ANULADO''
                 else '' ''
                 End
    From [' +@base+'].dbo.co_gastos a left join [' +@base+'].dbo.co_sistema b on a.gastoscodigo=b.sistemaconfiguragastos
         left join [' +@baseConta+'].dbo.ct_tipoanalitico c on a.tipoanaliticocodigo=c.tipoanaliticocodigo 
         left join [' +@baseConta+'].dbo.ct_cuenta d on a.cuentacodigo=d.cuentacodigo 
         Where a.gastoscodigo like '''+@gastoscodigo+''' 
          order by a.L1,a.L2,a.cuentacodigo'
execute (@sqlcad)
--select * from fox.dbo.co_gastos
--exec co_PlanGastos_rpt 'mmj2008','mmj2008','%%'
GO
