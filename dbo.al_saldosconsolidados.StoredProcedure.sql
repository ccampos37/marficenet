SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [al_saldosconsolidados] 'agro2000','%%','101842','##70554751'

drop proc al_saldosconsolidados

*/
CREATE     PROC  [al_saldosconsolidados]
@base varchar(50),
@almacen  varchar(2),
@producto varchar(20),
@computer varchar(50)='xx_ARMADO'
as
declare @sql as varchar(5000)

set @sql='select zz.*,
        Faltante=case when (zz.Stock-zz.Pedido)> 0 then 
          0 else abs((zz.Stock-zz.Pedido)) end ,
        Requerido=case when (zz.stock-zz.Pedido+zz.Receta) > 0 then 0 
                    else  abs((zz.stock-zz.Pedido+zz.Receta)) end,
        Disponible=case when (zz.stock-zz.Pedido+zz.Receta) <0 then 0
                    else (zz.stock-zz.Pedido+zz.Receta) end 
from( select a.stalma as Cod_alm,t.tadescri as Almacen,a.stcodigo as Codigo,a.stskdis as Stock,
	sum(isnull(detpedcantpedida,0)) as Pedido,floor(isnull(c.stskdis,0)) as Receta
	from '+@base+'.dbo.stkart a 
	left join '+@computer+'_1  b on a.stcodigo=b.productocodigo and a.stalma=b.almacencodigo   
	left join (select stalma,codkit,stskdis=min(stskdis)
	from (select stalma,codkit,
	codart,stskdis=case when isnull(stskdis,0)=0 then 0 else (isnull(stskdis,0))/canart end
	from  '+@base+'.dbo.kits b  
	left join  '+@base+'.dbo.stkart c on codart=stcodigo ) z 
	group by stalma,codkit) c on a.stalma=c.stalma and a.stcodigo=c.codkit
	inner join '+@base+'.dbo.tabalm t on a.stalma=t.taalma		
where a.stcodigo like '''+@producto+''' and  a.stalma like '''+@almacen+''' and t.consolidado=(''1'')
group by a.stcodigo,a.stalma,t.tadescri,c.stskdis,a.stskdis

union all
select ''ZZ'','''',''TOTAL --> '',sum(a.stock),sum(a.Pedido),sum(a.Receta)
from   (select a.stalma as Almacen,a.stcodigo as Codigo,a.stskdis as stock,
sum(isnull(detpedcantpedida,0)) as Pedido,
floor(isnull(c.stskdis,0)) as Receta
from '+@base+'.dbo.stkart a 
left join '+@computer +'_1  b on a.stcodigo=b.productocodigo and a.stalma=b.almacencodigo 
left join (select stalma,codkit,stskdis=min(stskdis)
from 
	(select stalma,codkit,codart,stskdis=(stskdis)/canart from  '+@base+'.dbo.kits b inner join  '+@base+'.dbo.stkart c on codart=stcodigo) z 
group by stalma,codkit) c on a.stalma=c.stalma and a.stcodigo=c.codkit
inner join '+@base+'.dbo.tabalm on a.stalma=taalma
where a.stcodigo like '''+@producto+''' and a.stalma like '''+@almacen+''' and  consolidado=(''1'')
group by a.stcodigo,a.stalma,c.stskdis,a.stskdis) a 
group by a.codigo ) zz  order by cod_alm  '

execute(@sql)
GO
