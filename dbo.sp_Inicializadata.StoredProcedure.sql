SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
use marficenet
execute sp_Inicializadata 'agro2000'

*/
create proc [sp_Inicializadata]
(
@base varchar(50)
)
as
declare @sql varchar(4000)
set @sql='
delete '+@base+'.dbo.stkart 
delete '+@base+'.dbo.movalmcab
delete '+@base+'.dbo.listapre1 
delete '+@base+'.dbo.listapre2
delete '+@base+'.dbo.vt_pedido
delete '+@base+'.dbo.vt_abono
delete '+@base+'.dbo.vt_cargo 
delete '+@base+'.dbo.vt_cliente
delete '+@base+'.dbo.cp_abono
delete '+@base+'.dbo.cp_cargo 
delete '+@base+'.dbo.cp_proveedor
delete '+@base+'.dbo.co_cabeceraprovisiones
delete '+@base+'.dbo.co_cabordcompra 
delete '+@base+'.dbo.maeart ' 

execute ( @sql)
GO
