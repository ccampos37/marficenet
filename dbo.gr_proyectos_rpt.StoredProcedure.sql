SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [gr_proyectos_rpt]
(
@base varchar(50),
@empresa  varchar(2),
@familia varchar(10),
@linea varchar(10),
@grupo varchar(10),
@todos varchar(1)='0'
)
as
declare @sql as varchar(4000)
set @sql=' select  proyectocodigo,[proyectodescripcion],aa.clientecodigo,clienterazonsocial,monedadescripcion,
                    proyectoimporte =case when  aa.monedacodigo=''01'' then proyectoimporte / isnull(tipocambioventa,1) else  proyectoimporte end, 
                     aa.empresacodigo, aa.fam_codigo, aa.lin_codigo, aa.gru_codigo , aa.monedacodigo, aa.proyectofechainicio,
                     aa.proyectocierre,dd.lin_nombre, ee.gru_nombre
                      from '+@base+'.[dbo].[gr_proyectos] aa
                      left join '+@base+'.[dbo].[vt_cliente] bb on aa.clientecodigo=bb.clientecodigo
                      left join '+@base+'.[dbo].[gr_moneda] cc on aa.monedacodigo=cc.monedacodigo 
                      left join '+@base+'.[dbo].lineas dd on aa.fam_codigo+aa.lin_codigo=dd.fam_codigo+dd.lin_codigo 
                      left join '+@base+'.[dbo].grupo ee on aa.fam_codigo+aa.lin_codigo+aa.lin_codigo=ee.fam_codigo+ee.lin_codigo+ee.gru_codigo 
                      left join '+@base+'.[dbo].ct_tipocambio ff on aa.proyectofechainicio=ff.tipocambiofecha 
          where empresacodigo='''+@empresa+''' and 
                 aa.fam_codigo like '''+@familia+''' and
                 aa.lin_codigo like '''+@linea+''' and 
                 aa.gru_codigo like '''+@grupo+''' '
 if @todos='0' set @sql=@sql +' and aa.proyectocierre=0 '

execute(@sql)
GO
