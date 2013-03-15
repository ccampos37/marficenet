SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [cp_DocvenciXvence] 
--Declare 
    @Base varchar(100),
    @Base2 varchar(100),
    @Op   int , 
    @Fecharef varchar(10),
    @Cliente varchar(15), 
    @rango varchar(200)
As
Declare @SqlCad varchar(4000),
        @Simb as varchar(5)   
--si 1 es vencidos <=0 
--si 2 es por vencer >=0
/* Set @Cliente='%%'
  Set @rango='70,80,90,100,1000,'
  Set @Fecharef='37703'
  Set @Base='Ventas_Prueba'
  Set @Op=1 */
        
If @Op=1 Set @Simb='<=0'
If @Op=2 Set @Simb='>=0'
set @SqlCad='
Select A.clientecodigo ,B.clienterazonsocial, A.documentocargo,A.monedacodigo,
       DescrDoc=isnull(C.tdocumentodesccorta,''No existe Descripcion''), 
       A.cargonumdoc,A.cargoapefecemi,
       cargoapefecvct=isnull(A.cargoapefecvct,A.cargoapefecemi),A.cargoapeimpape,A.cargoapeimppag,
       dias= 
	    datediff(day,'+@Fecharef+',floor(cast(isnull(A.cargoapefecvct,A.cargoapefecemi) as real))),
       rango=
       ['+@Base2+'].dbo.fn_ubicarango(
       abs(datediff(day,'+@Fecharef+', floor(cast(isnull(A.cargoapefecvct,A.cargoapefecemi) as real)))),'''+@rango+'''),
       DesRango=D.DESCRIP 
from ['+@Base+'].dbo.cp_cargo A
Inner Join ['+@Base+'].dbo.cp_proveedor B 
on A.clientecodigo=B.clientecodigo  
Left Outer Join  ['+@Base+'].dbo.cp_tipodocumento C
on  A.documentocargo=C.tdocumentocodigo
Inner join ['+@Base+'].dbo.cp_rangovcto D on 
['+@Base2+'].dbo.fn_ubicarango(
       abs(datediff(day,'+@Fecharef+', floor(cast(isnull(A.cargoapefecvct,A.cargoapefecemi) as real)))),'''+@rango+''')
       =D.COD
where
	A.cargoapeflgreg is null and 
    isnull(A.cargoapeflgcan,0) <>1 and 
    datediff(day,'+@Fecharef+' ,  floor(cast(isnull(A.cargoapefecvct,A.cargoapefecemi) as real)))'+@Simb+' and 
    ['+@Base2+'].dbo.fn_ubicarango(
    abs(datediff(day,'+@Fecharef+' , floor(cast(isnull(A.cargoapefecvct,A.cargoapefecemi) as real)))),'''+@rango+''')  <> -1 and 
    A.clientecodigo like '''+@Cliente+''''    
exec(@SqlCad)
--exec cp_DocvenciXvence 'acuaplayacasma','marfice','1','39703','%','15,30,45,60,75,'
GO
