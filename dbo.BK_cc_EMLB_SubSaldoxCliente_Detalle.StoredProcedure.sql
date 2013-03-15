SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE                    proc [BK_cc_EMLB_SubSaldoxCliente_Detalle](
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codcliente varchar(50),
@ctacontable varchar(20),
@coddocumento varchar(2)
)
as
/*
declare @base varchar(50), @compu varchar(20), @fecha varchar(10), @acuenta char(1) 
declare @codmoneda varchar(2), @codcliente varchar(50), @ctacontable varchar(20)
set @base='ventas_prueba'
SET @compu='DESARROLLO3'
SET @fecha='30/09/2002'
SET @codmoneda='%'
SET @codcliente='%'
SET @ctacontable='%'
SET @acuenta='1'
*/
set nocount on
DECLARE @sqlcad varchar(3000)
DECLARE @condctacontable nvarchar (2000)
set @sqlcad=''
set @sqlcad='SELECT cod_documento=a.documentocargo,a.monedacodigo,desc_documento=b.tdocumentodescripcion,
	SALDO_SOLES = CASE 
	WHEN a.monedacodigo = 01 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargopagadoux,0))
    ELSE 0
	end,
	SALDO_DOLARES = CASE 
	WHEN a.monedacodigo = 02 THEN SUM(isnull(a.cargoapeimpape,0)) - SUM(isnull(a.cargopagadoux,0))
    ELSE 0
	end
FROM  	##tmp_saldoactualizado' +@compu+  ' a, 
	[' +@base+ '].dbo.cc_tipodocumento b
WHERE a.documentocargo=b.tdocumentocodigo and abs(ROUND(cargoapeimpape,2))>abs(ROUND(cargopagadoux,2))
		and a.documentocargo<>''80''
GROUP BY documentocargo,monedacodigo,b.tdocumentodescripcion'
exec(@sqlcad)
set nocount off
--select * from ##tmp_saldoactualizadodesarrollo3 order by abonocancli,documentoabono,abononumdoc
--exec cc_EMLB_SubSaldoxCliente_Detalle 'ventas_prueba','DESARROLLO3','02/03/2003','1','%','3932','%','%'
GO
