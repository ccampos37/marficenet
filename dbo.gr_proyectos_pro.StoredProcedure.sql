SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute gr_proyectos_pro 'aliterm2012',4,'01','%%','%%','%%',1,1,'aaaaaaaa','xxddddx','1234567891','01',333.33,'01/01/2012','013','sa'


*/


CREATE proc [gr_proyectos_pro]
(
@base varchar(50),
@tipo integer,
@empresa  varchar(2),
@familia varchar(10),
@linea varchar(10),
@grupo varchar(10),
@proyectotipo varchar(1)='',
@periodo varchar(4)='',
@correlativo varchar(10)='' ,
@todos varchar(1)='0',
@cierre varchar(1) ='0',
@proyectocodigo varchar(11)='',
@proyectodescripcion varchar(40)='',
@clientecodigo varchar(11)='',
@monedacodigo varchar(2)='',
@proyectoimporte varchar(20)='0',
@proyectofechainicio varchar(10)='',
@tipoanalitico varchar(3)='',
@usuariocodigo varchar(8)=''
)
as
declare @sql as varchar(4000)
if @tipo=1
begin
    set @sql=' INSERT INTO '+@base+'.[dbo].[gr_proyectos]
           ([empresacodigo],
           proyectotipo,
           proyectoperiodo,
           proyectocorrelativo,
           [fam_codigo],
           [lin_codigo],
           [gru_codigo],
           [proyectocodigo],
           [proyectodescripcion],
           [clientecodigo],
           [monedacodigo],
           [proyectoimporte],
           [proyectofechainicio],
           [tipoanaliticocodigo],
           [proyectocierre],
           [usuariocodigo],
           [fechaact])
     VALUES ('''+@empresa+''',
             '''+@proyectotipo+''',
             '+@periodo +',
             '+@correlativo +',
             '''+@familia+''',
             '''+@linea+''',
             '''+@grupo+''',
             '''+@proyectocodigo+''',
             '''+@proyectodescripcion+''',
             '''+@clientecodigo+''',
             '''+@monedacodigo+''',
             '+@proyectoimporte+',
             '''+@proyectofechainicio+''',
             '''+@tipoanalitico+''',
             '+@cierre+',
             '''+@usuariocodigo+''',
             getdate()
             ) '
end
if @tipo=2
begin
    set @sql=' UPDATE '+@base+'.[dbo].[gr_proyectos] set 
           [proyectodescripcion]='''+@proyectodescripcion+''',
           [clientecodigo]='''+@clientecodigo+''',
           [monedacodigo]='''+@monedacodigo+''',
           [proyectoimporte]='+@proyectoimporte+',
           [proyectofechainicio]='''+@proyectofechainicio+''',
           [usuariocodigo]='''+@usuariocodigo+''', 
           [proyectocierre]='+@cierre+', 
           [fechaact]=getdate() 
           where [empresacodigo]='''+@empresa+''' and 
                 [fam_codigo]='''+@familia+''' and
                 [lin_codigo]='''+@linea+''' and 
                 [gru_codigo]='''+@grupo+''' and
                 [proyectocodigo]='''+@proyectocodigo+''' ' 
 End 
if @tipo=3
begin
    set @sql=' DELETE '+@base+'.[dbo].[gr_proyectos] 
           where [empresacodigo]='''+@empresa+''' and
                 [fam_codigo]='''+@familia+''' and
                 [lin_codigo]='''+@linea+''' and 
                 [gru_codigo]='''+@grupo+''' and
                 [proyectocodigo]='''+@proyectocodigo+''' ' 
End 
if @tipo=4
begin
    set @sql=' select  proyectocodigo,[proyectodescripcion],aa.clientecodigo,clienterazonsocial,monedadescripcion,[proyectoimporte], 
                     aa.empresacodigo, aa.fam_codigo, aa.lin_codigo, aa.gru_codigo , aa.monedacodigo, aa.proyectofechainicio,
                     aa.proyectocierre,dd.lin_nombre, ee.gru_nombre
                      from '+@base+'.[dbo].[gr_proyectos] aa
                      left join '+@base+'.[dbo].[vt_cliente] bb on aa.clientecodigo=bb.clientecodigo
                      left join '+@base+'.[dbo].[gr_moneda] cc on aa.monedacodigo=cc.monedacodigo 
                      left join '+@base+'.[dbo].lineas dd on aa.fam_codigo+aa.lin_codigo=dd.fam_codigo+dd.lin_codigo 
                      left join '+@base+'.[dbo].grupo ee on aa.fam_codigo+aa.lin_codigo+aa.lin_codigo=ee.fam_codigo+ee.lin_codigo+ee.gru_codigo 
          where empresacodigo='''+@empresa+''' and 
                 aa.fam_codigo like '''+@familia+''' and
                 aa.lin_codigo like '''+@linea+''' and 
                 aa.gru_codigo like '''+@grupo+''' '
 if @todos='0' set @sql=@sql +' and aa.proyectocierre=0   '
 set @sql=@sql + ' order by empresacodigo,proyectotipo,proyectoperiodo, proyectocorrelativo desc '
                 
 End 
execute(@sql)
GO
