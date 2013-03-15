SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [cc_PlanillaCobranza_Sub]
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20),
@tipocobranza varchar(2),
@coddocumento varchar(2),
@tipo char(1)
---execute cc_SubPlanillaCobranza 'gremco','01/01/2007','31/07/2007','%%','%%','CO','%%'
as
DECLARE @sensql1 nvarchar (4000)
DECLARE @sensql2 nvarchar (4000)
SET @sensql1='SELECT Cod_Doc_Abono,Desc_Doc_Abono,Cod_Doc_Cargo,Desc_Doc_Cargo,
		ContadoDolar=IMPORTES_DOLARES_CONTADO,
    	CreditoDolar=IMPORTES_DOLARES_CREDITO,
		ContadoSol=IMPORTES_SOLES_CONTADO,
		CreditoSol=IMPORTES_SOLES_CREDITO
 FROM
(SELECT Cod_Doc_Abono,Desc_Doc_Abono,
	Cod_Doc_Cargo,Desc_Doc_Cargo,
	IMPORTES_DOLARES_CONTADO = 
	isnull ((SELECT SUM (isnull(Importe_Abono,0)) FROM ##tmp_PlanillaCob GG
			where MonedaAbono=''02'' and tipopago=''CO''
			AND GG.Cod_Doc_Abono=YY.Cod_Doc_Abono and GG.Cod_Doc_Cargo=YY.Cod_Doc_Cargo
	),0) ,
	IMPORTES_DOLARES_CREDITO = 
	isnull ((
	SELECT SUM (isnull(Importe_Abono,0)) FROM ##tmp_PlanillaCob GG
			where MonedaAbono=''02'' and tipopago=''CR''
			AND GG.Cod_Doc_Abono=YY.Cod_Doc_Abono and GG.Cod_Doc_Cargo=YY.Cod_Doc_Cargo
	),0) , 
	IMPORTES_SOLES_CONTADO = 
	isnull ((SELECT SUM (isnull(Importe_Abono,0)) FROM ##tmp_PlanillaCob GG
			where MonedaAbono=''01'' and tipopago=''CO''
			AND GG.Cod_Doc_Abono=YY.Cod_Doc_Abono and GG.Cod_Doc_Cargo=YY.Cod_Doc_Cargo
	),0),
	IMPORTES_SOLES_CREDITO = 
	isnull ((SELECT SUM (isnull(Importe_Abono,0))FROM ##tmp_PlanillaCob GG
			where MonedaAbono=''01'' and tipopago=''CR''
			AND GG.Cod_Doc_Abono=YY.Cod_Doc_Abono and GG.Cod_Doc_Cargo=YY.Cod_Doc_Cargo
	),0)
FROM 	
		##tmp_PlanillaCob YY
GROUP BY 
	Cod_Doc_Abono,Desc_Doc_Abono,Cod_Doc_Cargo,Desc_Doc_Cargo ) as ZZ'
execute(@sensql1)
RETURN
GO
