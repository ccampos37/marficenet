SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROC [cc_ImpresionLetra]
@base varchar(50),
@documentocargo nvarchar(2),
@cargonumdoc nvarchar(15),
@codcliente nvarchar(20)
AS
DECLARE @sensql nvarchar (4000)
Declare @cadsql varchar(300)
set @sensql=' 
	select 	A.*,
				e.clienterazonsocial,
				e.clientedireccion,
				e.clienteruc,
				e.clientetelefono,
				f.tdocumentodesccorta as DescDocAbono,
				g.monedasimbolo as MonAbono
		from 	[' + @base+ '].dbo.vt_cargo A,
		[' + @base+ '].dbo.vt_cliente e,
		[' + @base+ '].dbo.cc_tipodocumento f,
		[' + @base+ '].dbo.gr_moneda g
	where A.documentocargo like''' +@documentocargo+ ''' and
         A.cargonumdoc like ''' + @cargonumdoc+ ''' and
			A.clientecodigo like ''' + @codcliente+ ''' and
			A.clientecodigo = e.clientecodigo and
			A.documentocargo = f.tdocumentocodigo and
			A.monedacodigo = g.monedacodigo'
exec (@sensql)
RETURN
--EXEC cc_ImpresionLetra 'POLVOSAZULES','%','%','%'
				
--select * from ventas_prueba.dbo.vt_abono A where abononumplanilla='000044'
--   A.abononumplanilla=B.abononumplanilla
GO
