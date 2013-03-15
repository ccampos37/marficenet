SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Fecha actualización: 15/02/2007
CREATE        PROCEDURE [SP_GETDATAEXPORT]
	@Base char(20),
	@Anno char(4),
	@ctaret4ta char(20) = '404200',
	@ctaret3ra char(20) = '404100',
	@ctaigv char(20) = '401100',
	@ctaprovext char(20) = '421400',
	@ctaprovrxh char(20) = '469300',
	@empresa char(2) = '01',
	@PerIni char(2),
	@PerFin char(2)
WITH RECOMPILE
AS
Declare @strSQL varchar(3000)
IF EXISTS (SELECT name 
		FROM tempdb.dbo.sysobjects
		WHERE name = '##tbl_detmov' AND type = 'U')
	DROP TABLE ##tbl_detmov
	
IF EXISTS (SELECT name 
		FROM tempdb.dbo.sysobjects
		WHERE name = '##tbl_cabprovi' AND type = 'U')
	DROP TABLE ##tbl_CabProvi
SET @strSQL = 'SELECT a.cabprovinumero, CAST(a.cabprovimes AS CHAR(2)) cabprovimes, a.tipocompracodigo, CAST(a.documetocodigo AS CHAR(2)) documetocodigo,
	cabproviserie = SUBSTRING(a.cabprovinumdoc, 1, CHARINDEX(''-'', a.cabprovinumdoc) - 1),
	cabprovindoc = SUBSTRING(a.cabprovinumdoc, CHARINDEX(''-'', a.cabprovinumdoc) + 1, LEN(a.cabprovinumdoc) - CHARINDEX(''-'', a.cabprovinumdoc)),
	a.cabprovifchdoc, CAST(a.proveedorcodigo AS CHAR(11)) proveedorcodigo, CAST(a.cabproviruc AS CHAR(11)) cabproviruc, a.cabprovirznsoc, a.cabprovifchven, CAST(a.monedacodigo AS CHAR(2)) monedacodigo, 
	a.cabprovinumdoc, isnull((select tipocambioventa from [' + rtrim(@Base) + '].dbo.ct_tipocambio where a.cabprovifchdoc = tipocambiofecha), 0.00) as cabprovitipcambio, 
	a.cabprovitotbru, a.cabprovitotdcto, a.cabprovitotigv,
	a.cabprovitotinaf, a.cabprovitotal,
	ctaproveedor = CAST( 
		CASE 
			WHEN (a.documetocodigo = 23 OR a.documetocodigo = 99) THEN ' + @ctaprovext +
			--'WHEN (a.documetocodigo = 02) THEN ' + @ctaprovrxh +
			'ELSE( SELECT tdocumentocuentasoles 
					FROM [' + rtrim(@Base) + '].dbo.cp_tipodocumento 
					WHERE a.documetocodigo = tdocumentocodigo)	
		END AS CHAR(20)),
	ctaigv = 
		CAST(CASE 
			WHEN (a.documetocodigo = 02 AND a.cabprovitotinaf < 0) THEN ' + @ctaret4ta +
			'ELSE ' + @ctaigv +
		'END AS CHAR(20)),
	a.modoprovicod,
	a.cabprovicaja,
	a.cabprovinumtesor,
	a.empresacodigo 
     INTO ##tbl_CabProvi
     FROM [' + rtrim(@Base) + '].dbo.co_cabeceraprovisiones a
     ORDER BY a.cabprovimes, a.tipocompracodigo, a.documetocodigo, a.cabprovifchdoc'
Execute (@strSQL)
--print(@strSQL)
--SELECT * from  #tbl_CabProvi ORDER BY cabprovimes, tipocompracodigo, documetocodigo, cabprovifchdoc
set @strSQL = 'SELECT b.cabprovinumero, CAST(b.cabprovimes AS CHAR(2)) cabprovimes, CAST(c.cuentacodigo AS CHAR(20)) CUENTACODIGO,
	centrocostocodigo = 
		cast(CASE
			WHEN (b.centrocostocodigo='''' or cast(b.centrocostocodigo as int)=0) THEN '''' 
			ELSE left(b.centrocostocodigo + ''000000'', 6)
		END as char(10)),
	b.detproviglosa,
	sum(b.detproviimpbru) detproviimpbru, sum(b.detproviimpigv) detproviimpigv, sum(b.detproviimpina) detproviimpina,
	sum(b.detprovitotal) detprovitotal,
	entidadcodigo = 
		cast(CASE 
			WHEN (b.entidadcodigo = ''00'') THEN ''''
			ELSE b.entidadcodigo
		END as char(11)),
	entidadrazsoc = 
		ISNULL((select entidadrazonsocial from [' + rtrim(@Base) + '].dbo.ct_entidad where entidadcodigo = b.entidadcodigo and entidadcodigo<>''00''), '''') 
     INTO ##tbl_detmov
     FROM [' + rtrim(@Base) + '].dbo.co_detalleprovisiones b, [' + rtrim(@Base) + '].dbo.co_gastos c
     WHERE b.gastoscodigo = c.gastoscodigo
     GROUP BY b.cabprovinumero, b.cabprovimes, c.cuentacodigo, b.centrocostocodigo, b.detproviglosa, b.entidadcodigo
     ORDER BY b.cabprovinumero, b.cabprovimes, c.cuentacodigo, b.centrocostocodigo, b.detproviglosa, b.entidadcodigo'
Execute (@strSQL)
--print(@strSQL)
set @strSQL = 'SELECT b.*, a.cabprovinumero, a.cabprovimes, a.tipocompracodigo, a.documetocodigo,
	a.cabproviserie, a.cabprovindoc, a.cabprovifchdoc, a.proveedorcodigo, a.cabproviruc, 
	a.cabprovirznsoc, a.cabprovifchven, a.monedacodigo, a.cabprovinumdoc, 
	cabprovitipcambio, a.cabprovitotbru, a.cabprovitotdcto, a.cabprovitotigv, a.cabprovitotinaf, 
	a.cabprovitotal, a.ctaproveedor,
	ctaigv = 
		CAST(CASE 
			WHEN (a.documetocodigo = 04 AND b.detproviimpina < 0) THEN ' + @ctaret3ra +
			'ELSE a.ctaigv
		END AS CHAR(20)),
	a.modoprovicod,
	a.cabprovicaja,
	ctacaja = cast ((select cajacuentasoles from [' + rtrim(@Base) + '].dbo.te_codigocaja where cajacodigo = a.cabprovicaja) as char(20)),
	a.cabprovinumtesor,
	a.empresacodigo
    FROM ##tbl_CabProvi a, ##tbl_detmov b
    WHERE a.cabprovinumero = b.cabprovinumero and a.cabprovimes = b.cabprovimes and  a.cabprovimes between ' + @PerIni + ' and ' + @PerFin + ' and ' + 'a.empresacodigo = ' + @empresa +
    'ORDER BY a.cabprovimes, a.documetocodigo, a.cabprovifchdoc, a.cabprovinumero'
Execute (@strSQL)
--exec sp_getdataexport @Base='aliterm', @Anno='2008', @empresa='00', @PerIni='01', @PerFin='01'
GO
