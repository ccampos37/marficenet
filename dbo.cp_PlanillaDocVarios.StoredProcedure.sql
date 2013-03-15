SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROC [cp_PlanillaDocVarios] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente varchar(20),
@tipo integer
AS
DECLARE @cadsql nvarchar (4000)
SET @cadsql = N'
SELECT a.abononumplanilla as Num_Planilla,a.cargoapefecpla as Fec_Planilla, 
       a.cargoapetipcam as Tipo_Cambio,	a.clientecodigo as Cod_Cliente,
       c.clienterazonsocial as Razon_Social,a.documentocargo as Cod_Documento, 
       b.tdocumentodesccorta as Desc_Documento,a.cargonumdoc as Num_Documento,
       a.cargoapefecemi as Fec_Emision,	a.cargoapefecvct as Fec_Vencimiento,d.monedasimbolo,
	ISNULL(a.cargoapeimpape,0) as Importe_Apertura
FROM ['+@base+'].dbo.cp_cargo a INNER JOIN ['+@base+'].dbo.cp_tipodocumento b 
	                              ON a.documentocargo = b.tdocumentocodigo 
	INNER JOIN ['+@base+'].dbo.cp_proveedor c ON a.clientecodigo = c.clientecodigo 
	INNER JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo 
	INNER JOIN ['+@base+'].dbo.cp_tipoplanilla f ON f.tplanillacodigo = a.abonotipoplanilla 
WHERE  f.tplanilladocvarios = ''1'' 
	AND a.cargoapeflgcan <> 1 
	AND a.cargoapeflgreg IS NULL 
	AND a.clientecodigo LIKE ''' +@codcliente+ ''''
if @tipo=1 set @cadsql=@cadsql+' and a.cargoapefecpla BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' ' 
if @tipo=2 set @cadsql=@cadsql +' and a.abonotipoplanilla='''+rtrim(@fecdesde)+''' 
                                  and a.abononumplanilla='''+rtrim(@fechasta)+''''
set @cadsql=@cadsql+ ' ORDER BY a.abononumplanilla,d.monedasimbolo,a.cargoapefecpla,
    a.clientecodigo,a.cargonumdoc '
exec (@cadsql)
RETURN
--exec cp_PlanillaDocVarios 'acuaplayacasma','02','293','%',2
GO
