SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Documentos Vencidos y por Vencer*/
CREATE      proc [cp_relacionDocumentos]
@base varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@codcliente varchar(20),
@codmoneda varchar(2),
@coddocumento varchar(2)
as
set nocount on
DECLARE @sqlcad varchar(3500)
set @sqlcad='
	SELECT A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
			A.cargoapefecvct,A.monedacodigo,
                        referencia = abonotipoplanilla+''-''+abononumplanilla,
                        soles =case when a.monedacodigo=''01'' then
                                    isnull(A.cargoapeimpape,0) else 0 end,
                        dolares=case when a.monedacodigo=''02'' then
                                    isnull(A.cargoapeimpape,0) else 0 end,
			cargoapeimppag=isnull(A.cargoapeimppag,0),
			cargopagadoux=isnull(A.cargoapeimppag,0),
			A.cargoapeflgcan,A.cargoapecarabo,
 			E.tdocumentodescripcion,
			I.clienteruc,I.clienterazonsocial,
			H.monedasimbolo,
			Monto=case when a.monedacodigo=''01'' then
                                   isnull(A.cargoapeimpape,0)
                                 else
                                   isnull(A.cargoapeimpape,0)*(select  tipocambioventa from ['+@base+'].dbo.ct_tipocambio j
                                          where a.cargoapefecemi=j.tipocambiofecha )
                              end
	FROM 	[' +@base+ '].dbo.cp_cargo A,
 			['+@base+'].dbo.cp_tipodocumento E,
			[' +@base+ '].dbo.gr_moneda H,
			[' +@base+ '].dbo.cp_proveedor I
	WHERE A.documentocargo=E.tdocumentocodigo AND 
              A.documentocargo LIKE ''' +@coddocumento+  ''' AND
			A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
			A.clientecodigo like ''' +@codcliente+ ''' AND 
			A.cargoapeflgcan=0  AND
			A.cargoapeflgreg IS NULL AND 
			A.cargoapefecemi BETWEEN '''+@fechaini+''' and '''+@fechafin+''' 
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
execute(@sqlcad)
--- execute cp_relacionDocumentos 'acuaplayacasma','01/12/2006','31/12/2006','%%','%%','%%'
GO
