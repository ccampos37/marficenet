SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROC [cc_DocumentosVarios] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@CodCliente varchar(20),
@TipoDoc varchar(2)
AS
DECLARE @sensql nvarchar (4000)
SET @sensql = N'
SELECT 	a.abononumplanilla as Num_Planilla,
	a.cargoapefecpla as Fec_Planilla, a.cargoapetipcam as Tipo_Cambio,
	a.clientecodigo as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	a.documentocargo as Cod_Documento, b.tdocumentodesccorta as Desc_Documento,
	a.cargonumdoc as Num_Documento,a.cargoapefecemi as Fec_Emision,
	a.cargoapefecvct as Fec_Vencimiento,d.monedasimbolo,
	Importe_Apertura=ISNULL( dbo.tipodoc(B.tdocumentotipo,A.cargoapeimpape) ,0 ),
	estadodoc=case when isnull(a.cargoapeflgreg,0)<>''1'' 
		then ''Activo''
		else ''Anulado''
	end,
	a.monedacodigo
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON 
	a.documentocargo = b.tdocumentocodigo 
	JOIN 
	['+@base+'].dbo.vt_cliente c 
	ON 
	a.clientecodigo = c.clientecodigo 
	JOIN 
	['+@base+'].dbo.gr_moneda d 
	ON 
	a.monedacodigo = d.monedacodigo 
	left JOIN 
	['+@base+'].dbo.cc_tipoplanilla f 
	ON 
	f.tplanillacodigo = a.abonotipoplanilla 
WHERE	
	a.cargoapefecemi BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' 
	AND ltrim(rtrim(a.clientecodigo)) LIKE ''' +@codcliente+ ''' 
	AND a.documentocargo LIKE ''' +@TipoDoc+ '''
	
ORDER BY
	a.documentocargo,a.cargonumdoc'
	
exec (@sensql)
RETURN
--select * from ventas_prueba.dbo.vt_cargo where cargoapefecemi between '28/02/2003' and '28/02/2003'
--exec cc_EMLB_DocumentosVarios 'ventas_prueba','28/02/2003','28/02/2003','%','%'
GO
