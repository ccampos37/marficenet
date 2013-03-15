SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROC [cc_clientes_rep]
@base varchar(50),
@cliente varchar(11)='%%',
@negocio varchar(02)='%%',
@distrito varchar(10)='%%'
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	clientecodigo,clienteruc,clienterazonsocial,
        clientedireccion,clientetelefono,
     clientefax,clientemail,b.negociodescripcion
     from ['+@base+'].dbo.vt_cliente a 
     inner join ['+@base+'].dbo.vt_negocio b
           on a.negociocodigo=b.negociocodigo
WHERE	
     clientecodigo like '''+@cliente+''' 
     and a.negociocodigo like '''+@negocio+''' 
     and clientedistrito like '''+@distrito+'''
ORDER BY
     b.negociodescripcion,a.clientecodigo'
	
exec (@sensql)
RETURN
--select * from fox.dbo.vt_cliente
--exec cc_clientes_rep 'gremco','%%','%%','%%'
GO
