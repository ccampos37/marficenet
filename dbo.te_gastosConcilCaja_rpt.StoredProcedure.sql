SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [te_gastosConcilCaja_rpt]
--Declare 
@Base   varchar(50), 
@caja varchar(2),
@Moneda varchar(2),
@rendicion  varchar(20)
as 
Declare @Sqlcad varchar(4000)
Set @Sqlcad='
Select z.detrec_gastos,z.gastosdescripcion,z.cabrec_ingsal,
       importe = case when z.cabrec_ingsal=''I'' then
           z.importe else z.importe* -1 end 
from 
(
select  a.detrec_gastos,c.gastosdescripcion,b.cabrec_ingsal,
        importe =sum( case when '''+@moneda+'''=''01'' then 
                A.detrec_importesoles else  A.detrec_importedolares end)
from ['+@Base+'].dbo.te_detallerecibos A 
     Inner join  ['+@Base+'].dbo.te_cabecerarecibos  B  
           on  A.cabrec_numrecibo=B.cabrec_numrecibo 
     left join ['+@Base+'].dbo.co_gastos  c  
           on  a.detrec_gastos=c.gastoscodigo 
Where B.cabrec_estadoreg <> 1 and isnull(detalle_no_saldos,0)<>1 
      and rtrim(A.detrec_cajabanco1)='''+@caja+'''
      and rtrim(b.monedacodigo)='''+@moneda+''' 
      and A.chkconcil=1 and a.rendicionnumero='''+@rendicion +'''
group by a.detrec_gastos,c.gastosdescripcion,b.cabrec_ingsal 
) as z '
execute(@Sqlcad)
---execute te_gastosConcilCaja_rpt 'acuaplayacasma','02','01','000149'
GO
