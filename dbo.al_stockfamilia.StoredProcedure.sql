SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  procedure [al_stockfamilia]
@base as varchar(50),
@almacen as varchar(2)
as
declare @cadena as nvarchar(1000)
declare @a as char(1)
set @a='A'
set @cadena='Select ACodigo,Adescri,Afamilia,b.STSKDIS,c.fam_nombre
             From ['+@base+'].dbo.MAEART A 
             Inner Join ['+@base+'].dbo.STKART B
             on A.ACodigo=B.STCodigo 
             Inner Join ['+@base+'].dbo.FAMILIA C
             on A.Afamilia=c.fam_codigo 
             Where Stalma='''+@almacen+''' and stskdis<>0 Order by Acodigo'
execute(@cadena)
GO
