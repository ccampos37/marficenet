SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute te_gastosdeproyectos 'aliterm2012','01','013'

*/

CREATE proc [te_gastosdeproyectos]
@base varchar(50),
@empresa varchar (20),
@tipoanalitico varchar(10)='%%',
@proyecto varchar(11)='%%',
@moneda varchar(2)='02'
as

declare @sql varchar(4000)

set @sql =' select dd.proyectocodigo, proyectodescripcion,  aa.tipogastoscodigo, cc.tipogastosdescripcion, aa.gastoscodigo, aa.gastosdescripcion
                   from  '+@base+'.dbo.co_gastos aa
                   left join '+@base+'.dbo.v_provisiones bb on aa.gastoscodigo=bb.gastoscodigo 
                   left join '+@base+'.dbo.co_tipogastos cc on bb.tipogastoscodigo=cc.tipogastoscodigo
                   left join '+@base+'.dbo.gr_proyectos dd on bb.entidadcodigo=dd.proyectocodigo
                   where  aa.tipoanaliticocodigo='''+@tipoanalitico+''' and bb.entidadcodigo like '''+@proyecto +''' 
                          '
execute(@sql)
GO
