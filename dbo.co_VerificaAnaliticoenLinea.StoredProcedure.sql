SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [co_VerificaAnaliticoenLinea]
--Declare 
@BaseConta		Varchar(100),
@BaseCompra 	varchar(100),
@Ano     		varchar(4),
@Mes     		varchar(2),
@tipanal        varchar(3),
@User           varchar(50),
@Nprovi         varchar(10)
As
Declare @SqlCad Varchar(8000)
Set @SqlCad='
INSERT INTO ['+@BaseConta+'].dbo.ct_entidad
(entidadcodigo, entidadrazonsocial, entidaddireccion, 
 entidadruc, entidadtelefono, entidadtipocontri,
 usuariocodigo, fechaact)
--Verificar luego los proveedores que no tenga ruc y que el sistema
--de un mensaje de cuales son
SELECT DISTINCT cabproviruc, left(ltrim(rtrim(cabprovirznsoc)),40),'' '',
                cabproviruc,'' '',''00'','''+@User+''',Getdate()   
FROM   ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A 
WHERE a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and A.cabprovinumero='+@Nprovi+' and ltrim(rtrim(isnull(A.cabprovinconta,'''')))=''''
      and  cabproviruc collate  Modern_Spanish_CI_AI 
      Not in(Select entidadcodigo collate  Modern_Spanish_CI_AI from ['+@BaseConta+'].dbo.ct_entidad)
INSERT INTO ['+@BaseConta+'].dbo.ct_analitico
(analiticocodigo, entidadcodigo, tipoanaliticocodigo, usuariocodigo, fechaact)
SELECT DISTINCT cabproviruc+'''+@tipanal+''',cabproviruc,'''+@tipanal+''','''+@User+''',getdate()
FROM   ['+@BaseCompra+'].dbo.co_cabeceraprovisiones A
WHERE a.cabproviano='+@ano+' and A.cabprovimes='+@Mes+' and A.cabprovinumero='+@Nprovi+' and ltrim(rtrim(isnull(A.cabprovinconta,'''')))='''' and 
      cabproviruc+'''+@tipanal+''' collate  Modern_Spanish_CI_AI 
      Not in(Select analiticocodigo collate  Modern_Spanish_CI_AI from ['+@BaseConta+'].dbo.ct_analitico)
'
exec(@SqlCad)
--exec co_VerificaAnalitico 'prueba_Contaprueba_sanil','sanildefonso','2003','04','001','sa'
GO
