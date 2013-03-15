SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE MARFICE_VENTAS
CREATE  proc [cc_avisocobranzas_rpt]
--Declare 
@Base varchar(100),
@BaseConta varchar(100),
@op   varchar(1),
@cliente varchar(20),
@tipdoc varchar(2),
@dias varchar(5),
@simbo varchar(3)
as
/*  
	Op=1 Documentos Vencidos
    Y diferentes de 1 documentos por vencer
*/
/*Set @Base='ventas_prueba'
Set @BaseConta='contaprueba'
Set @op='0'
Set @cliente='%%'
Set @tipdoc='%%'
Set @dias='17'
Set @simbo='='*/
Declare @SqlCad varchar(4000),
        @SqlVar varchar(4000) 
Set @SqlCad=' 
select A.documentocargo,A.cargonumdoc,A.cargoapefecemi,A.clientecodigo,
       A.cargoapefecvct,A.monedacodigo,A.cargoapeimpape,C.tipocambioventa,
       B.clienteruc,B.clienterazonsocial,Dias=datediff(day,getdate(),A.cargoapefecvct)
        
from 
	 ['+@base+'].dbo.vt_cargo A
     Inner join ['+@base+'].dbo.vt_cliente B   
     on A.clientecodigo=B.clientecodigo
     left outer join ['+@BaseConta+'].dbo.ct_tipocambio C  
     on A.cargoapefecemi=C.tipocambiofecha
Where 	 
    A.clientecodigo like '''+@cliente+''' and 
    A.documentocargo like '''+@tipdoc+'''' 
    --Para documentos vencidos 
if @op='1' 
    Set @SqlVar=' and A.cargoapefecvct < getdate()'
Else
Begin  
	if ltrim(rtrim(isnull(@dias,'')))='' 
		Set @SqlVar=' and A.cargoapefecvct >= getdate() '
    Else
		Set @SqlVar=' and datediff(day,getdate(),A.cargoapefecvct)>=0 and 
                          datediff(day,getdate(),A.cargoapefecvct) '+@simbo+' '+@dias
End 
Exec (@SqlCad+@SqlVar)
GO
