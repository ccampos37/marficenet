SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cc_SubSaldoxCliente_Detalle 'planta_casma','xx','06/05/2008','0','%%','%%','%%','%%',1

*/
CREATE       proc [cc_SubSaldoxCliente_Detalle](
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@acuenta char(1), 
@codmoneda varchar(2),
@codcliente varchar(50),
@ctacontable varchar(20),
@coddocumento varchar(2),
@tipo integer=1
)
as
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
FROM
	(select distinct clientecodigo,cargonumdoc,documentocargo,monedacodigo,tdocumentodescripcion,
         cargoapeimpape,cargopagadoux from ##tmp_saldoactualizado' +@compu+  ') as a,
	[' +@base+ '].dbo.cc_tipodocumento b
WHERE a.documentocargo=b.tdocumentocodigo  '
if @tipo=1
begin
   set @sqlcad=@sqlcad + ' and abs(ROUND(cargoapeimpape,2))<>abs(ROUND(cargopagadoux,2)) '
end
if @tipo=2
begin
   set @sqlcad=@sqlcad + ' and abs(ROUND(cargoapeimpape,2)-ROUND(cargopagadoux,2)) > 1 '
end
set @sqlcad=@sqlcad + ' GROUP BY documentocargo,monedacodigo,b.tdocumentodescripcion'
exec(@sqlcad)
--select * from ##tmp_saldoactualizadodesarrollo3 order by abonocancli,documentoabono,abononumdoc
GO
