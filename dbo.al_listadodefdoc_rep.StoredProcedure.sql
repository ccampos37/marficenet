SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [al_listadodefdoc_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
declare @cod as varchar(2)
set @cod='12'
set @cadena='Select A.CtnCodigo,B.TDO_CODSUN,B.TDO_DESCRI,A.CtnNumser,A.CtnNumero  
             From ['+@base+'].dbo.Num_Documentos A   
             Inner Join ['+@base+'].dbo.Tipo_Docu B 
	     on A.CTNCODIGO = B.TDO_TIPDOC '
execute(@cadena)
GO
