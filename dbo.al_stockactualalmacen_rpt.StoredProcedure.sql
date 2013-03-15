SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from stkart
CREATE     procedure [al_stockactualalmacen_rpt]
@base as varchar(50),
@almacen as varchar(2),
@where as varchar(1),
@order as varchar(1)
as
declare @cadena as nvarchar(4000)
--declare @base as nvarchar(200)
--set @base='planta_casma'
set @cadena=' Select FAM_NOMBRE,ACodigo,Adescri,
            disp= STSKDIS , comp=stskDIS, ultimoprecio=stkprepro
             From ['+@base+'].dbo.MAEART  a
             left Join ['+@base+'].dbo.STKART b on ACodigo=STCodigo
             left Join ['+@base+'].dbo.familia c on afamilia=fam_codigo 
             Where Stalma='''+@almacen+''' and isnull(a.afstock,1)=''1'' '
if @where<>'0' set @cadena=@cadena+ ' and b.stskdis <> 0 '
if @order='1'  set @cadena=@cadena+ ' order by acodigo'
if @order<>'1'  set @cadena=@cadena+ ' order by adescri'
execute(@cadena) 
--execute al_stockactualalmacen_rpt 'planta_casma','01','1',1
GO
