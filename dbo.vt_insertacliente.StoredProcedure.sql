SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC vt_insertacliente 'desarrollo','desarrollo','2011','06','002','admin'

*/

CREATE      Proc [vt_insertacliente]
--Declare 
@BaseConta		Varchar(100),
@BaseVenta	 	varchar(100),
@Ano     		varchar(4),
@Mes     		varchar(2),
@tipanal        varchar(3),
@User           varchar(50) 
As
/*  Set @BaseConta='CONTAPRUEBA'
  Set @BaseVenta='TRANSFER'
  Set @Ano='2003'
  Set @Mes='01'
  set @tipanal='002'
  set @User='Sys' */
Declare @SqlCad Varchar(8000)
Set @SqlCad='
INSERT INTO ['+@BaseConta+'].dbo.ct_entidad
(entidadcodigo, entidadrazonsocial, entidaddireccion, 
 entidadruc, entidadtelefono, entidadtipocontri,
 usuariocodigo, fechaact)
--Verificar luego los proveedores que no tenga ruc y que el sistema
--de un mensaje de cuales son
SELECT DISTINCT 
	entidadcodigo=Left(case when A.pedidotipofac=''01'' 
         then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
         else A.clientecodigo End,11), 
    entidadrazonsocial=left(isnull((select top 1 clienterazonsocial from ['+@BaseVenta+'].dbo.Vt_cliente Cli where Cli.clientecodigo=A.clientecodigo),''No Tiene''),40),
    entidaddireccion='' '',
    entidadruc=Left(case when A.pedidotipofac=''01'' 
         then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
         else A.clientecodigo End,11),
    entidadtelefono='' '',
    entidadtipocontri=''00'',usuariocodigo='''+@user+''',fechaact=Getdate()
FROM ['+@BaseVenta+'].dbo.Vt_Pedido A 
WHERE Month(A.pedidofecha)='+@Mes+' and year(A.pedidofecha)='+@Ano+' 
and rtrim(Left(case when A.pedidotipofac=''01'' or A.pedidotipofac=''15''
         then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
         else A.clientecodigo End,11)) not in (select entidadcodigo from ['+@BaseConta+'].dbo.ct_entidad )'

PRINT(@SqlCad)


Set @SqlCad='
INSERT INTO ['+@BaseConta+'].dbo.ct_analitico
(analiticocodigo, entidadcodigo, tipoanaliticocodigo, usuariocodigo, fechaact)
SELECT DISTINCT
      analiticocodigo=rtrim(Left(case when A.pedidotipofac=''01'' or A.pedidotipofac=''15''
         then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then rtrim(A.clientecodigo) else rtrim(A.clienteruc) end 
         else rtrim(A.clientecodigo) End,11))
                +''002'',
      entidadcodigo=rtrim(Left(case when A.pedidotipofac=''01'' or A.pedidotipofac=''15'' 
       then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
       else A.clientecodigo End,11)),
       tipoanaliticocodigo=''002'',usuariocodigo=''Sys'',fechaact=getdate()
FROM   ['+@BaseVenta+'].dbo.Vt_Pedido A 
        WHERE Month(A.pedidofecha)='+@Mes+' and year(A.pedidofecha)='+@Ano+' AND  A.pedidotipofac <> ''80'' and 
        rtrim(Left(case when A.pedidotipofac=''01'' or A.pedidotipofac=''15''
         then case when isnull(rtrim(ltrim(A.clienteruc)),'''') ='''' then A.clientecodigo else A.clienteruc end 
         else A.clientecodigo End,11))+''002'' not in (select analiticocodigo from ['+@BaseConta+'].dbo.ct_analitico )'

execute(@SqlCad)
GO
