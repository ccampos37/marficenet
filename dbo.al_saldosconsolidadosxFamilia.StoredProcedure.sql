SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [al_saldosconsolidadosxfamilia] 'ziyaz','%%','666','%%'
drop proc al_saldosconsolidados
select * from ziyaz.dbo.maeart


*/
CREATE     PROC  [al_saldosconsolidadosxFamilia]
@base varchar(50),
@tipo varchar(2) ,
@familia  varchar(10),
@linea varchar(10)
as
declare @sql as varchar(5000)
set @sql='select c.fam_nombre,a.adescri,receta=isnull(cc.receta,0),zz.*,
        Faltante=case when (zz.Stock-zz.Pedido)> 0 then 
          0 else abs((zz.Stock-zz.Pedido)) end ,
        Requerido=case when (zz.stock-zz.Pedido+isnull(cc.Receta,0)) > 0 then 0 
                    else  abs((zz.stock-zz.Pedido+isnull(cc.Receta,0))) end,
        Disponible=case when (zz.stock-zz.Pedido+isnull(cc.Receta,0)) <0 then 0
                    else (zz.stock-zz.Pedido+isnull(cc.Receta,0)) end 
from
(
select codigo,stock=sum(a.stock),pedido=sum(a.Pedido)
from 
(  select a.stalma,a.stcodigo as Codigo,a.stskdis as stock,sum(isnull(detpedcantpedida,0)) as Pedido 
   from '+@base+'.dbo.stkart a 
   left join ( SELECT almacencodigo,pedidonumero,productocodigo,detpedcantpedida=detpedcantpedida-sum(decantid)
               from '+@base+'.dbo.v_almacenyventas v
               left join '+@base+'.dbo.vt_modoventa c on v.modovtacodigo=c.modovtacodigo
               inner join '+@base+'.dbo.maeart m on v.productocodigo=m.acodigo
			   inner join '+@base+'.dbo.tabalm t on v.almacencodigo=t.taalma
               where isnull(c.modovtacanje,0)<>1
          			and /*isnull(m.atipo,''00'')='''+@tipo +''' or*/   
                    ( isnull(m.afamilia,'''') like '''+@familia+'''
                    and isnull(m.alinea,'''') like '''+@linea+''' ) and isnull(t.consolidado,0)<>''1''
                group by almacencodigo,pedidonumero,productocodigo,detpedcantpedida 
                having detpedcantpedida-sum(decantid)>0
             ) b on a.stalma+ a.stcodigo=b.almacencodigo+b.productocodigo
    inner join '+@base+'.dbo.tabalm t on a.stalma=t.taalma 
    where t.tipoalmacencodigo=''1'' and t.consolidado<>''1''
    group by a.stalma,a.stcodigo,a.stskdis
) a 
group by a.codigo 
) zz
left join '+@base+'.dbo.maeart a on zz.codigo=a.acodigo 
left join '+@base+'.dbo.tipo_articulo b on a.atipo=b.cod_tipo
left join '+@base+'.dbo.familia c on a.afamilia=c.fam_codigo
left join 
( select codkit,receta=min(saldo) from
  ( select a.codkit,a.codart,saldo=isnull(saldo,0) from '+@base+'.dbo.kits a
    left join ( select codkit,codart,saldo=floor(sum(stskdis/canart)) from '+@base+'.dbo.kits a
                inner join '+@base+'.dbo.stkart b on a.codart=b.stcodigo 
                inner join '+@base+'.dbo.tabalm t on b.stalma=t.taalma 
                where t.tipoalmacencodigo=''1'' and stskdis<>0 and t.consolidado<>''1'' group by codkit,codart
              ) b on a.codkit+a.codart=b.codkit+b.codart
   ) z group by codkit 
) cc on zz.codigo=cc.codkit
where (zz.stock-zz.Pedido+cc.Receta) >0   and isnull(afstock,0)=1
and isnull(a.atipo,''00'')='''+@tipo +''' or ( isnull(a.afamilia,'''') like '''+@familia+''' 
and isnull(a.alinea,'''') like '''+@linea+''' ) '

execute(@sql)
GO
