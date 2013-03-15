SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [cp_SubPlanillaDocVarios] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codcliente varchar(20),
@tipo integer
AS
DECLARE @cadsql nvarchar (4000)
SET @cadsql = N'
SELECT 	a.documentocargo as Cod_Documento, b.tdocumentodescripcion as Desc_Documento,
	TOTAL_SOLES = CASE WHEN a.monedacodigo = ''01'' THEN SUM(isnull(a.cargoapeimpape,0)) ELSE 0 end,
	TOTAL_DOLARES = CASE WHEN a.monedacodigo = ''02'' THEN SUM(isnull(a.cargoapeimpape,0)) 	ELSE 0 	end
FROM 	['+@base+'].dbo.cp_cargo a JOIN ['+@base+'].dbo.cp_tipodocumento b 
	         ON a.documentocargo = b.tdocumentocodigo 
	JOIN ['+@base+'].dbo.cp_tipoplanilla f 
	ON f.tplanillacodigo = a.abonotipoplanilla
WHERE 	f.tplanilladocvarios = ''1'' 
	AND a.cargoapeflgcan <> 1 
	AND a.cargoapeflgreg IS NULL 
	AND a.clientecodigo LIKE ''' +@codcliente+ ''''
if @tipo=1 set @cadsql=@cadsql+' and a.cargoapefecpla BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' ' 
if @tipo=2 set @cadsql=@cadsql +' and a.abonotipoplanilla='''+rtrim(@fecdesde)+''' 
                                  and a.abononumplanilla='''+rtrim(@fechasta)+''''
set @cadsql=@cadsql+' GROUP BY 	a.documentocargo,b.tdocumentodescripcion,a.monedacodigo 
                      ORDER BY a.documentocargo '
execute (@cadsql)
RETURN
--exec cp_SubPlanillaDocVarios 'acuaplayacasma','02','293','%',2
GO
