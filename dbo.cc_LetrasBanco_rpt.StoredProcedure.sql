SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [cc_LetrasBanco_rpt]
(
	@base as varchar(50),
	@codbanco as varchar(20),
	@codcliente as varchar(20)
)
as
declare @cadsql as varchar(4000)
set @cadsql='
	select 
		documentocargo,cargonumdoc,abonotipoplanilla,
		abononumplanilla,cargoapefecpla,
		cargoapefecemi,cargoapefecvct,cargoapenrumbco,
		monedacodigo,cargoapeimpape,cargoapeimppag,
		a.abonotipoplanilla,b.tplanilladescripcion,a.bancocodigo,c.bancodescripcion,
		a.clientecodigo,d.clienterazonsocial 
	from 
		[' +@base+ '].dbo.vt_cargo a, 
		[' +@base+ '].dbo.cc_tipoplanilla b,
		[' +@base+ '].dbo.gr_banco c,
		[' +@base+ '].dbo.vt_cliente d
	where 
		a.abonotipoplanilla=b.tplanillacodigo and
		(isnull(b.tplanillacanjes,0)=1 or isnull(b.tplanillarenovar,0)=1) and
		isnull(a.cargoapeflgcan,0)<>1 and
		a.bancocodigo=c.bancocodigo and 
		a.clientecodigo=d.clientecodigo and
		isnull(a.bancocodigo,'''') like ''' +@codbanco+''' and
		a.clientecodigo like '''+@codcliente+''''
exec(@cadsql)
--exec cc_LetrasBanco_rpt 'Ventas_prueba','%','%'
GO
