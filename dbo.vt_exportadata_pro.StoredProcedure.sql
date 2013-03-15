SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    proc [vt_exportadata_pro]
--Declare 
@Basetransfer varchar(50),
@BaseVenta    varchar(50),
@FechaIni	  varchar(10),		  
@FechaFin     varchar(10),
@PtoVta       varchar(2)
AS
Declare @SqlCad Varchar(4000),@NombTabla varchar(50)
/*Set @Basetransfer='transfer'
Set @BaseVenta='ventas_prueba'
Set @FechaIni='37620'
Set @FechaFin='37636'*/
--Select cast(cast('01/01/2003' as datetime) as bigint)
--Select cast(cast('17/01/2003' as datetime) as bigint)
Set @SqlCad='Declare Borratabla cursor for 
         Select name From ['+@Basetransfer+'].dbo.sysobjects where xtype=''U'''
Exec(@SqlCad)
Open Borratabla
Fetch next from Borratabla into  @NombTabla
While @@Fetch_Status=0 
Begin 
	Exec('Drop Table ['+@Basetransfer+'].dbo.'+@NombTabla)
	Fetch next from Borratabla into  @NombTabla
End  
Close Borratabla
Deallocate  Borratabla
Set @SqlCad='
Select A.* into ['+@Basetransfer+'].dbo.vt_pedido
From ['+@BaseVenta+'].dbo.vt_pedido A
Where floor(cast(A.pedidofecha as real)) between '+ @FechaIni+' and '+@FechaFin+' 
      And A.puntovtacodigo='''+@PtoVta+'''' 
Exec(@SqlCad)
Set @SqlCad='
Select B.* into ['+@Basetransfer+'].dbo.vt_detallepedido
From ['+@BaseVenta+'].dbo.vt_pedido A,
     ['+@BaseVenta+'].dbo.vt_detallepedido B 
Where A.pedidonumero=B.pedidonumero and 
	 floor(cast(A.pedidofecha as real)) between '+@FechaIni+' and '+@FechaFin+'
     And A.puntovtacodigo='''+@PtoVta+'''' 
Exec(@SqlCad)
Set @SqlCad='
Select * into ['+@Basetransfer+'].dbo.vt_cliente
from ['+@BaseVenta+'].dbo.vt_cliente 
Where 
clientecodigo in (
Select Distinct clientecodigo 
From ['+@BaseVenta+'].dbo.vt_pedido A
Where floor(cast(A.pedidofecha as real)) between '+@FechaIni+' and '+@FechaFin+' 
      And A.puntovtacodigo='''+@PtoVta+''')'
Exec(@SqlCad)
Set @SqlCad='
Select B.* into ['+@Basetransfer+'].dbo.vt_abono
From ['+@BaseVenta+'].dbo.vt_pedido A,
     ['+@BaseVenta+'].dbo.vt_abono B 
Where
	   A.pedidotipofac=B.documentoabono	and 
       A.pedidonrofact=B.abononumdoc and  
	 floor(cast(A.pedidofecha as real)) between '+@FechaIni+' and '+@FechaFin+'
     And A.puntovtacodigo='''+@PtoVta+'''' 
Exec(@SqlCad)
Set @SqlCad='
Select B.* into ['+@Basetransfer+'].dbo.vt_cargo
From ['+@BaseVenta+'].dbo.vt_pedido A,
     ['+@BaseVenta+'].dbo.vt_cargo B 
Where
	 A.pedidotipofac=B.documentocargo and 	
     A.pedidonrofact=B.cargonumdoc and  
	 floor(cast(A.pedidofecha as real)) between '+@FechaIni+' and '+@FechaFin+'
     And A.puntovtacodigo='''+@PtoVta+'''' 
Exec(@SqlCad)
GO
