SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [cc_Inmueblesxclientes_rep]
@base varchar(50),
@cliente varchar(11)='%%',
@negocio varchar(02)='%%',
@distrito varchar(10)='%%'
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.clientecodigo,a.clienteruc,a.clienterazonsocial,
        a.clientedireccion,a.clientetelefono,
     a.clientefax,a.clientemail,d.tadescri,e.adescri,c.detpedmontoimpto
     from ['+@base+'].dbo.vt_cliente a 
     inner join ['+@base+'].dbo.vt_pedido b
           on a.clientecodigo=b.clientecodigo
     inner join ['+@base+'].dbo.vt_detallepedido c
           on b.pedidonumero=c.pedidonumero
     inner join ['+@base+'].dbo.tabalm d
           on b.almacencodigo=d.taalma
     inner join ['+@base+'].dbo.maeart e
           on c.productocodigo=e.acodigo
WHERE	
     a.clientecodigo like '''+@cliente+''' 
ORDER BY
     a.clientecodigo'
	
exec (@sensql)
RETURN
--select * from fox.dbo.vt_cliente
--exec cc_Inmueblesxclientes_rep 'tabor','%%','%%','%%'
GO
