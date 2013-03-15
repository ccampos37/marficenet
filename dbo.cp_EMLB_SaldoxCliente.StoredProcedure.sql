SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROC [cp_EMLB_SaldoxCliente] 		/*EN USO*/
@base varchar(50),
@ctacontable varchar(20),
@codcliente varchar(11),
@codmoneda varchar (2),
@fechasta varchar(10),
@letra bit
AS
DECLARE @sensql nvarchar (4000)
DECLARE @where nvarchar (4000)
SET @where = ''
IF @ctacontable <> '%'
BEGIN
	SET @where =  ' AND(LTRIM(RTRIM(f.tdocumentocuentasoles)) LIKE ('''+@ctacontable+''') OR LTRIM(RTRIM(f.tdocumentocuentadolares)) LIKE ('''+@ctacontable+''')) '
	IF @codmoneda <> '%'
	    BEGIN
		IF @codmoneda = '01'
		   BEGIN
		     SET @where = ' AND LTRIM(RTRIM(f.tdocumentocuentasoles)) LIKE ('''+@ctacontable+''') '
		   END
		IF @codmoneda = '02'
	    	   BEGIN
		     SET @where = ' AND LTRIM(RTRIM(f.tdocumentocuentadolares)) LIKE ('''+@ctacontable+''') '
	  	   END
	    END
END
IF convert(varchar(10),getdate(),103) = @fechasta
BEGIN
SET @sensql = N'
SELECT 	a.clientecodigo as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	a.documentocargo as Cod_Documento,b.tdocumentodesccorta as Desc_Documento,
	a.cargonumdoc as Num_Documento,
	f.tdocumentocuentasoles as Cuenta_Soles, f.tdocumentocuentadolares as Cuenta_Dolar,
	a.cargoapefecemi as Fec_Emision,a.cargoapefecvct as Fec_Vencimiento,d.monedasimbolo,
	ISNULL( dbo.tipodoc(b.tdocumentotipo,a.cargoapeimpape) ,0 ) as Cargo,
	ISNULL( a.cargoapeimppag,0 ) as Abono
FROM 	
	['+@base+'].dbo.cp_cargo a 
	JOIN 
	['+@base+'].dbo.cp_tipodocumento b 
	ON 
	a.documentocargo = b.tdocumentocodigo 
	JOIN 
	['+@base+'].dbo.cp_proveedor c 
	ON 
	a.clientecodigo = c.clientecodigo 
	JOIN 
	['+@base+'].dbo.gr_moneda d 
	ON 
	a.monedacodigo = d.monedacodigo 
	JOIN 
	['+@base+'].dbo.cp_tipodocumento f 
	ON 
	f.tdocumentocodigo = a.documentocargo 
WHERE	
	LTRIM(RTRIM(a.clientecodigo)) LIKE ('''+@codcliente+''') 
	AND a.cargoapefecemi <= '''+@fechasta+''' AND a.cargoapeflgcan <> 1 
	'+@where+' 
	AND a.monedacodigo LIKE ('''+@codmoneda+''') 
	AND a.cargoapeflgreg IS NULL
ORDER BY 
	a.clientecodigo,d.monedasimbolo,a.documentocargo,a.cargonumdoc '
exec (@sensql)
RETURN
END
ELSE
BEGIN
SET @sensql = N'
SELECT 	a.clientecodigo as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	a.documentocargo as Cod_Documento,b.tdocumentodesccorta as Desc_Documento,
	a.cargonumdoc as Num_Documento,
	f.tdocumentocuentasoles as Cuenta_Soles,f.tdocumentocuentadolares as Cuenta_Dolar,
	a.cargoapefecemi as Fec_Emision,a.cargoapefecvct as Fec_Vencimiento,d.monedasimbolo,  	
	ISNULL( dbo.tipodoc(b.tdocumentotipo,a.cargoapeimpape) ,0 ) as Cargo,
	SUM( ISNULL( e.abonocanimpcan,0 ) ) as Abono
FROM 	
	['+@base+'].dbo.cp_cargo a 
	JOIN 
	['+@base+'].dbo.cp_tipodocumento b
	ON  
	a.documentocargo = b.tdocumentocodigo 
	JOIN
	['+@base+'].dbo.cp_proveedor c
	ON
	a.clientecodigo = c.clientecodigo
	JOIN
	['+@base+'].dbo.gr_moneda d
	ON
	a.monedacodigo = d.monedacodigo
	JOIN
	['+@base+'].dbo.cp_abono e
	ON
	a.documentocargo = e.documentoabono
	AND a.cargonumdoc = e.abononumdoc
	JOIN
	['+@base+'].dbo.cp_tipodocumento f
	ON
	f.tdocumentocodigo = a.documentocargo
WHERE	
	LTRIM(RTRIM(a.clientecodigo)) LIKE ('''+@codcliente+''')
	AND a.monedacodigo LIKE ('''+@codmoneda+''')
	AND a.cargoapefecemi <= '''+@fechasta+'''
	AND a.cargoapeflgcan <> 1 
	'+@where+'
	AND CONVERT(varchar(10),e.abonocanfecpla,103) <= '''+@fechasta+'''
	AND a.cargoapeflgreg IS NULL
	  	
GROUP BY
	a.clientecodigo,c.clienterazonsocial,
	a.documentocargo,b.tdocumentodesccorta,
	a.cargonumdoc,
	f.tdocumentocuentasoles,f.tdocumentocuentadolares,
	a.cargoapefecemi,a.cargoapefecvct,d.monedasimbolo,  	
	b.tdocumentotipo,a.cargoapeimpape
ORDER BY 
	a.clientecodigo,d.monedasimbolo,a.documentocargo,a.cargonumdoc '
exec (@sensql)
RETURN
END
GO
