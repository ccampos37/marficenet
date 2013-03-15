SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [al_stockactual1_rep]
@base as nvarchar(50),
@almacen as char(2)
as
declare @cadena as nvarchar(4000)
set @cadena='select yy.*,
              vendido=case when isnull(detpedmontoimpto,0)=0 then '''' else ''V'' end,
                precio1=0
 from 
  (    Select FAM_NOMBRE,ACodigo,Adescri,
            disp= STSKDIS ,
             comp=stskdis,
             zz.detpedmontoimpto,precio=0
             From ['+@base+'].dbo.MAEART  a
             Inner Join ['+@base+'].dbo.STKART b on ACodigo=STCodigo
             Inner Join ['+@base+'].dbo.familia c on afamilia=fam_codigo
             left Join ( select w.* from ['+@base+'].dbo.vt_detallepedido w 
                         inner join ['+@base+'].dbo.vt_pedido y 
                         on w.pedidonumero=y.pedidonumero
                         where y.almacencodigo='''+@almacen+''' and y.pedidocondicionfactura<> 1 ) as zz
                  on a.acodigo=zz.productocodigo
             Where Stalma='''+@almacen+''' and b.stskdis> 0 ) as yy '
---if @where<>'0' set @cadena=@cadena+ ' and b.stskdis > 0 '
---set @cadena=@cadena+ '  ) as yy '
execute(@cadena) 
--execute al_stockactual1_rep 'aliterm','01','1',0
GO
