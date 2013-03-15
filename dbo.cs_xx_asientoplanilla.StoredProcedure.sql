SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_asientoplanilla 'planta10','planta_casma', '01','2008','1'
*/
CREATE  proc [cs_xx_asientoplanilla]
@baseorigen varchar(50),
@basedestino varchar(50),
@empresa varchar(2),
@anno varchar(4),
@mes  varchar(2)
as
declare @sql varchar(4000)
set @sql = 'select  empresadescripcion,Tipo_contrato=Case tipo_contrato when ''O'' then
                         ''OBREROS '' else '' EMPLEADOS ''  end,
           aa=case tipo_contrato when ''O'' then
                           tipo_contrato+''-''+anio+''-M'' +mes+''-SEM''+str(nro_sema,2)
               else  tipo_contrato+''-''+anio+''-M'' +mes end,
            b.equivalencia,
            gastos =a.gasto_codigo+'' -  ''+ d.gastosdescripcion,mes_proceso,tipo_contrato,importe from 
            '+@baseorigen+'.dbo.resumen_plla_centrocosto a
            left join '+@baseorigen+'.dbo.centro_costo b on a.id_centro_costo=b.id_centro_costo 
            left join '+@basedestino+'.dbo.co_multiempresas c on right(a.empresa,2)=c.empresacodigo   
            left join '+@basedestino+'.dbo.co_gastos d on a.gasto_codigo=d.gastoscodigo 
             where anio='''+@anno+''' and mes='''+@mes+''' '
execute(@sql)
GO
