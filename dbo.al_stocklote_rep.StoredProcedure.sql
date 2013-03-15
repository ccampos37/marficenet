SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [al_stocklote_rep]
@base as varchar(50),
@almacen as varchar(2)
as
declare @cadena as nvarchar(1000)
declare @a as char(1)
set @a='A'
set @cadena='Select ACodigo,Adescri,b.STSKDIS  
             From ['+@base+'].dbo.MAEART A 
             Inner Join ['+@base+'].dbo.STKLOTE B
             on A.ACodigo=B.STSCodigo 
             Where Stsalma='''+@almacen+''' and stslkdis<>0 Order by Acodigo'
execute(@cadena)
GO
