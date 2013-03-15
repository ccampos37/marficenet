SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create    PROC [cc_SubDocumentosVarios] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@CodCliente varchar(20),
@TipoDoc varchar(2)
AS
DECLARE @sensql varchar (4000)
SET @sensql = 'SELECT 	
	EstadoDoc=case when isnull(a.cargoapeflgreg,0)<>''1'' 
			then ''Activos'' 
			else ''Anulados'' 
	end  ,
   a.documentocargo, b.tdocumentodesccorta as Desc_Documento,
	Importe_Soles=case when a.monedacodigo=''01'' then sum(ISNULL( dbo.tipodoc(B.tdocumentotipo,A.cargoapeimpape) ,0 )) else 0 end ,
	Importe_Dolares=case when a.monedacodigo=''02'' then sum(ISNULL( dbo.tipodoc(B.tdocumentotipo,A.cargoapeimpape) ,0)) else 0 end
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON 
	a.documentocargo = b.tdocumentocodigo 
WHERE	
	a.cargoapefecemi BETWEEN '''+@fecdesde+''' AND  '''+@fechasta+''' 
	AND ltrim(rtrim(a.clientecodigo)) LIKE ''' +@codcliente+ ''' 
	AND a.documentocargo LIKE ''' +@TipoDoc+ '''
group by a.cargoapeflgreg,a.documentocargo,b.tdocumentodesccorta,a.monedacodigo
order by 1,2'
EXEC (@sensql)
RETURN
--select * from ventas_prueba.dbo.vt_cargo
--exec cc_EMLB_SubDocumentosVarios 'ventas_prueba','01/01/2003','27/01/2003','%','%'
GO
