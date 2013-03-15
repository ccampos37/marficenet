SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute co_asientoplanillas 'planta10','planta_casma','03','01/06/2012','30/06/2012','##jmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmck','1'
select * from ##jck_1

*/

CREATE    PROC [co_asientoplanillas]

@baseorigen varchar(50),
@basedestino varchar(50),
@empresa varchar(2),
@fechaini varchar(10),
@fechafin varchar(10),
@computer varchar(60),
@tipo varchar(1)

as
declare  @sql varchar(8000)
declare @anno varchar(4),@mes varchar(2)
set @anno=year(@fechaini)
set @mes =month(@fechaini)

set @sql=' If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
    Drop Table ['+@computer+']'

execute(@sql)

set @sql=' '+' select yyyy=anio+right(''00''+rtrim(mes),2),gasto_codigo=isnull(b.gasto_codigo,''00'')
                 ,b.tipo_concepto,equivalencia=isnull(c.equivalencia,''00''),
          importe=sum(importe) 
         into ['+@computer+']
         from '+@baseorigen+'.dbo.Resumen_Plla_CentroCosto a 
         left join '+@baseorigen+'.dbo.gastos_conceptos b on a.gasto_codigo=b.gasto_codigo 
         left join '+@baseorigen+'.dbo.centro_costo c on a.id_centro_costo=c.id_centro_costo
         WHERE  indicador_mes_sema=''PE'' 
  and mes ='+@mes+'  AND  anio ='+@anno+' and isnull(c.equivalencia,'''')<>''''  and right(rtrim(empresa),2)='''+@empresa+'''  '
if @tipo='2' set @sql=@sql+' and tipo_pago=''03'' ' 
if @tipo='0' set @sql=@sql+' and tipo<>''03'' -- 1 : todo  ' 

set @sql=@sql+' group by anio,mes,b.gasto_codigo,b.tipo_concepto,c.equivalencia '

execute(@sql)
--print @sql

set @sql=' If Exists(Select name from tempdb..sysobjects where name='''+@computer+'_1'') 
    Drop Table ['+@computer+'_1]'

execute(@sql)
set @sql=' select gastoscodigo=gasto_codigo,centrocosto=equivalencia,importe=sum(importe)  
       into ['+@computer+'_1] from
  ( select gasto_codigo,equivalencia,tipo_concepto,
          importe=sum(importe )
          from ['+@computer+'] where tipo_concepto<>''E'' and tipo_concepto=''I''
                group by gasto_codigo,equivalencia,tipo_concepto 
          union all
            select gasto_codigo,'' '',tipo_concepto,
            importe=sum(importe)
            from ['+@computer+'] where tipo_concepto<>''E'' and tipo_concepto=''D''
                group by gasto_codigo,tipo_concepto 
         union all
          select ''6001'','' '',tipo_concepto,importe=sum(importe*-1)
          from ['+@computer+'] where tipo_concepto=''E'' and gasto_codigo=''5016'' 
              group by tipo_concepto
         union all 
          select gasto_codigo,equivalencia,tipo_concepto,sum(importe)
          from ['+@computer+'] where tipo_concepto=''E'' and gasto_codigo=''5016'' 
              group by gasto_codigo,equivalencia,tipo_concepto
   ) as zz
   group by zz.gasto_codigo,zz.equivalencia order by 1,2'

execute(@sql)
--print @sql

/*
set @sql=' insert '+@basedestino+'.dbo.co_cabeceraprovisiones 
 ( select ''33333333333'',''50'',''75'',yyyy,'''+@fechafin+''',total=sum(importes)
*/
GO
