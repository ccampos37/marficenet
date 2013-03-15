SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_CalcCadBalance]') and xtype in (N'FN', N'IF', N'TF'))
--drop function [dbo].[fn_CalcCadBalance]
--GO
create  FUNCTION [fn_CalcCadBalance]()
RETURNS varchar(5000)
BEGIN 	
	DECLARE  @sqlcad varchar(5000)
	SET @sqlcad=''+
        'DeudorSol=abs(case when (debe-haber) >=0 then debe-haber else 0 end), 
		AcreedorSol=abs(case when (debe-haber) <=0 then debe-haber else 0 end), 
		DeudorUss=abs(case when (debeuss-haberuss) >=0 then debeuss-haberuss else 0 end), 
		AcreedorUss=abs(case when (debeuss-haberuss) <=0 then debeuss-haberuss else 0 end), 
		DeudorSolAC=abs(case when (debeac-haberac) >=0 then debeac-haberac else 0 end), 
		AcreedorSolAC=abs(case when (debeac-haberac) <=0 then debeac-haberac else 0 end), 
		DeudorUssAC=abs(case when (debeacuss-haberacuss) >=0 then debeacuss-haberacuss else 0 end), 
		AcreedorUssAC=abs(case when (debeacuss-haberacuss) <=0 then debeacuss-haberacuss else 0 end), 				
--Inventarios
		InvActivoSol=case when C.tipocuentacodigo=''01'' then  abs(case when (debe-haber) >=0 then debe-haber else 0 end) else 0 end  ,
		InvPasivoSol=case when C.tipocuentacodigo=''01'' then  abs(case when (debe-haber) <=0 then debe-haber else 0 end) else 0 end ,
		InvActivoUss=case when C.tipocuentacodigo=''01'' then  abs(case when (debeuss-haberuss) >=0 then debeuss-haberuss else 0 end) else 0 end,
		InvPasivoUss=case when C.tipocuentacodigo=''01'' then  abs(case when (debeuss-haberuss) <=0 then debeuss-haberuss else 0 end) else 0 end,
		InvActivoSolAC=case when C.tipocuentacodigo=''01'' then  abs(case when (debeac-haberac) >=0 then debeac-haberac else 0 end) else 0 end,
		InvPasivoSolAC=case when C.tipocuentacodigo=''01'' then  abs(case when (debeac-haberac) <=0 then debeac-haberac else 0 end) else 0 end,
		InvActivoUssAC=case when C.tipocuentacodigo=''01'' then  abs(case when (debeacuss-haberacuss) >=0 then debeacuss-haberacuss else 0 end) else 0 end,
		InvPasivoUssAC=case when C.tipocuentacodigo=''01'' then  abs(case when (debeacuss-haberacuss) <=0 then debeacuss-haberacuss else 0 end) else 0 end,
--Por Funcion
		FunPerdiSol=case when C.tipocuentacodigo in (''05'',''03'') then abs(case when (debe-haber) >=0 then debe-haber else 0 end) else 0 end, 
		FunGanaSol=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debe-haber) <=0 then debe-haber else 0 end) else 0 end,
		FunPerdiUss=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debeuss-haberuss) >=0 then debeuss-haberuss else 0 end) else 0 end,
		FunGanaUss=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debeuss-haberuss) <=0 then debeuss-haberuss else 0 end) else 0 end,		
		FunPerdiSolAC=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debeac-haberac) >=0 then debeac-haberac else 0 end) else 0 end,
		FunGanaSolAC=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debeac-haberac) <=0 then debeac-haberac else 0 end) else 0 end,
		FunPerdiUssAC=case when C.tipocuentacodigo in (''05'',''03'') then   abs(case when (debeacuss-haberacuss) >=0 then debeacuss-haberacuss else 0 end) else 0 end,
		FunGanaUssAC=case when C.tipocuentacodigo in (''05'',''03'') then  abs(case when (debeacuss-haberacuss) <=0 then debeacuss-haberacuss else 0 end) else 0 end,
--Por Natruraleza
		NatPerdiSol=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debe-haber) >=0 then debe-haber else 0 end) else 0 end,
		NatGanaSol=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debe-haber) <=0 then debe-haber else 0 end) else 0 end,
		NatPerdiUss=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debeuss-haberuss) >=0 then debeuss-haberuss else 0 end) else 0 end,
		NatGanaUss=case when C.tipocuentacodigo in (''05'',''04'') then  abs(case when (debeuss-haberuss) <=0 then debeuss-haberuss else 0 end) else 0 end,
		NatPerdiSolAC=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debeac-haberac) >=0 then debeac-haberac else 0 end) else 0 end,
		NatGanaSolAC=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debeac-haberac) <=0 then debeac-haberac else 0 end) else 0 end,
		NatPerdiUssAC=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debeacuss-haberacuss) >=0 then debeacuss-haberacuss else 0 end) else 0 end,
		NatGanaUssAC=case when C.tipocuentacodigo in (''05'',''04'',''07'') then  abs(case when (debeacuss-haberacuss) <=0 then debeacuss-haberacuss else 0 end) else 0 end'
	RETURN @sqlcad
END
GO
