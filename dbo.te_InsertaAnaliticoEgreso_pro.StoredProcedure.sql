SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Proc [te_InsertaAnaliticoEgreso_pro]
--Declare
 @BaseConta varchar(50),
 @BaseVenta varchar(50), 
 @Compu     varchar(50),
 @TipoAna   varchar(3)	
As
/*Set @BaseConta='contaprueba'
  Set @BaseVenta='ventas_prueba' 
  Set @Compu='PC06'*/
Declare @SqlCad varchar(8000)
/*Insertar Entidad*/
Set @SqlCad='
Insert into ['+@BaseConta+'].dbo.ct_entidad 
Select entidadcodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
                     when ''00000000000'' then A.clientecodigo 
                     When '''' Then A.clientecodigo
                      else  A.clienteruc end,
       entidadrazonsocial=left(A.clienterazonsocial,40), 
       entidaddireccion=left(A.clientedireccion,25), 
       entidadruc=A.clienteruc, 
       entidadtelefono=A.clientetelefono, 
       entidadtipocontri=''00'',
       usuariocodigo=''Sys25'', 
       fechaact=Getdate()     
from ['+@BaseVenta+'].dbo.cp_proveedor A
where A.clientecodigo in (
select distinct left(analiticocodigo,11)  from [##tmpgenasientodet'+@Compu+'] ) and 
case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
when ''00000000000'' then A.clientecodigo 
When '''' Then A.clientecodigo
else  A.clienteruc end
not in ( Select entidadcodigo from ['+@BaseConta+'].dbo.ct_entidad) '
Exec(@SqlCad)
/*Insertar Analitico*/
Set @SqlCad='
insert into ['+@BaseConta+'].dbo.ct_analitico
Select * From (
Select 	   
	   analiticocodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
                     when ''00000000000'' then A.clientecodigo 
                     When '''' Then A.clientecodigo
                     else  A.clienteruc end + ''' +@TipoAna+ ''',
	   entidadcodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
                     when ''00000000000'' then A.clientecodigo 
                     When '''' Then A.clientecodigo
                     else  A.clienteruc end,
       tipoanaliticocodigo=''' +@TipoAna+ ''',       
       usuariocodigo=''Sys25'',
       fechaact=getdate()         
from ['+@BaseVenta+'].dbo.cp_proveedor A
where A.clientecodigo in (
select distinct left(analiticocodigo,11)  from [##tmpgenasientodet'+@Compu+']) ) as XX
where analiticocodigo not in (select analiticocodigo from ['+@BaseConta+'].dbo.ct_analitico) '
Exec(@SqlCad)
GO
