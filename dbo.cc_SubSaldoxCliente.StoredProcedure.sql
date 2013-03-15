SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [cc_SubSaldoxCliente] 		/*EN USO*/
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
SELECT 	a.documentocargo as Cod_Documento,b.tdocumentodescripcion as Desc_Documento,
	TOTAL_SOLES = CASE 
	WHEN a.monedacodigo = 01 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargoapeimppag,0) )
	ELSE 0
	end,
	TOTAL_DOLARES = CASE 
	WHEN a.monedacodigo = 02 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargoapeimppag,0))
	ELSE 0
	end
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON 
	a.documentocargo = b.tdocumentocodigo 	
WHERE	
	LTRIM(RTRIM(a.clientecodigo)) LIKE ('''+@codcliente+''') 
	AND a.cargoapefecemi <= '''+@fechasta+''' AND a.cargoapeflgcan <> 1 
	'+@where+' 
	AND a.monedacodigo LIKE ('''+@codmoneda+''') 
	AND a.cargoapeflgreg IS NULL
GROUP BY
	a.documentocargo,b.tdocumentodescripcion,a.monedacodigo
ORDER BY 
	b.tdocumentodescripcion,a.documentocargo,a.monedacodigo '
--	JOIN 
--	['+@base+'].dbo.cc_tipodocumento f 
--	ON 
--	f.tdocumentocodigo = a.documentocargo 
exec (@sensql)
RETURN
END
ELSE
BEGIN
SET @sensql = N'
SELECT 	a.documentocargo as Cod_Documento,b.tdocumentodescripcion as Desc_Documento,
	TOTAL_SOLES = CASE 
	WHEN a.monedacodigo = 01 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(e.abonocanimpcan,0))
	ELSE 0
	end,
	TOTAL_DOLARES = CASE 
	WHEN a.monedacodigo = 02 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(e.abonocanimpcan,0))
	ELSE 0
	end
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b
	ON  
	a.documentocargo = b.tdocumentocodigo 
	JOIN
	['+@base+'].dbo.vt_abono e
	ON
	a.documentocargo = e.documentoabono
	AND a.cargonumdoc = e.abononumdoc
WHERE	
	LTRIM(RTRIM(a.clientecodigo)) LIKE ('''+@codcliente+''')
	AND a.monedacodigo LIKE ('''+@codmoneda+''')
	AND a.cargoapefecemi <= '''+@fechasta+'''
	AND a.cargoapeflgcan <> 1 
	'+@where+'
	AND CONVERT(varchar(10),e.abonocanfecpla,103) <= '''+@fechasta+'''	  	
	AND a.cargoapeflgreg IS NULL
GROUP BY
	a.documentocargo,b.tdocumentodescripcion,a.monedacodigo
ORDER BY 
	b.tdocumentodescripcion,a.documentocargo,a.monedacodigo'
--	JOIN
--	['+@base+'].dbo.cc_tipodocumento f
--	ON
--	f.tdocumentocodigo = a.documentocargo
exec (@sensql)
RETURN
END
GO
