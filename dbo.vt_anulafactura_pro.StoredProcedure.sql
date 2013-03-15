SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [vt_anulafactura_pro]
@base varchar(50),
@docu varchar(15),
@tipo char(2),
@nume varchar(15),
@fanula varchar(10),
@empresa char(2),
@puntovta char(2),
@tesoreria char(1)='1'
as
Declare @cadena nvarchar(2000)
Declare @param nvarchar(200)
Declare @valor2 char(1)
    
Set @cadena='Update ['+@base+'].dbo.vt_pedido Set pedidocondicionfactura=''1'',pedidoestado=''1'',
    estadoreg=''1'',pedidofechaanu='''+@fanula+'''
   Where empresacodigo='''+@empresa+''' and pedidonumero='''+@docu +''' and puntovtacodigo='''+@puntovta+'''
     
   Update ['+@base+'].dbo.vt_detallepedido Set detpedestado=''1'' 
      Where empresacodigo='''+@empresa+'''and pedidonumero='''+@docu+''' '
execute(@cadena)

Set @cadena='Update ['+@base+'].dbo.vt_cargo Set cargoapeflgreg=''1''
       where empresacodigo='''+@empresa+''' and documentocargo='''+@tipo+''' and cargonumdoc='''+@nume+''' '

execute(@cadena)

If @tesoreria='1'
  begin
     set @cadena='Update ['+@base+'].dbo.te_cabecerarecibos Set cabrec_estadoreg=''1'' 
         where empresacodigo='''+@empresa+''' and cabcomprobnumero='''+@docu+'''
         
         Update ['+@base+'].dbo.te_detallerecibos Set detrec_estadoreg=''1'' 
             where cabrec_numrecibo in
         ( select cabrec_numrecibo from ['+@base+'].dbo.te_cabecerarecibos 
             where empresacodigo='''+@empresa+''' and cabcomprobnumero='''+@docu+''' )'
    execute(@cadena)
 end
GO
