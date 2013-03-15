SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE [al_articulos_sin_movimientos_rpt] 'ZIYAZ','01','01/05/2009',1,1
DROP PROC [dbo].[al_stockactual_rep]
update ziyaz.dbo.stkart set stkultfechavta=b.fecha
from ziyaz.dbo.stkart a , (
select almacencodigo,productocodigo,fecha=max(pedidofechasunat) from ziyaz.dbo.vt_pedido a
inner join ziyaz.dbo.vt_detallepedido b on a.empresacodigo+a.pedidonumero=b.empresacodigo+b.pedidonumero
group by almacencodigo,productocodigo )b
where a.stalma=b.almacencodigo and a.stcodigo=b.productocodigo


*/

CREATE  procedure [al_articulos_sin_movimientos_rpt]

@base as varchar(50),
@empresa as varchar(2),
@fecha as varchar(10)='0',
@tipo as int,  -- 0: ventas , 1: movimientos
@orden as char(1)  -- 0: ventas , 1: movimientos

as
declare @cadena as nvarchar(4000)
if @tipo=0
begin
set @cadena=' Select FAM_NOMBRE,ACodigo,Adescri ,fecha,saldo=sum(stskdis)
             From ['+@base+'].dbo.MAEART  a
             left Join ['+@base+'].dbo.familia b on a.afamilia=b.fam_codigo
             inner join 
                ( select stcodigo , fecha=max(isnull(a.stkultfechavta,'''+@fecha+''') ) 
                  from ['+@base+'].dbo.STKART a inner join ['+@base+'].dbo.tabalm b on a.stalma=b.taalma
                      where isnull(a.stkultfechavta,'''+@fecha+''') <='''+@fecha+''' and b.empresacodigo like '''+@empresa+''' 
                            and stskdis <> 0  group by stcodigo 
                 ) c on a.acodigo=c.stcodigo
             inner join ['+@base+'].dbo.stkart d on c.stcodigo=d.stcodigo 
             Where a.afstock=''1'' 
             group by FAM_NOMBRE,ACodigo,Adescri ,fecha '

end 
if @tipo=1
begin
set @cadena=' Select FAM_NOMBRE,ACodigo,Adescri ,fecha,saldo=sum(stskdis)
             From ['+@base+'].dbo.MAEART  a
             left Join ['+@base+'].dbo.familia b on a.afamilia=b.fam_codigo
             inner join 
                ( select stcodigo , fecha=max(isnull(a.stkfecult,'''+@fecha+''') ) 
                  from ['+@base+'].dbo.STKART a inner join ['+@base+'].dbo.tabalm b on a.stalma=b.taalma
                      where isnull(a.stkfecult,'''+@fecha+''') <='''+@fecha+''' and b.empresacodigo like '''+@empresa+''' 
                            and stskdis <> 0  group by stcodigo 
                 ) c on a.acodigo=c.stcodigo
             inner join ['+@base+'].dbo.stkart d on c.stcodigo=d.stcodigo 
             Where a.afstock=''1'' 
             group by FAM_NOMBRE,ACodigo,Adescri ,fecha '

end 
set @cadena=@cadena + ' order by 1,'+@orden+'+2 '

execute(@cadena)
GO
