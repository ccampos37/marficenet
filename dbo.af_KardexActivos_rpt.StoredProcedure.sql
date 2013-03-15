SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute af_KardexActivos_rpt 'planta_casma'

*/


CREATE proc [af_KardexActivos_rpt]
@base varchar(50),
@tabla1 varchar(50)='##TEMPOREPORKARCAB',
@tabla2 varchar(50)='##TEMPOREPORKARdet'
as
Declare @sqlcad varchar(4000)

set @sqlcad =' select KAR_GRUACT,KAR_UBICAACT,KAR_SECCACT,a.KAR_CODACT,KAR_NFACTU,KAR_ORDFAB, KAR_FECFAC, KAR_MARCA, KAR_MODELO, KAR_NROSERIE,
 KAR_IMPINI, KAR_TIPCAMB,KAR_DESCRIPROV, KAR_DESCRIACT, KAR_FECREG, KAR_DETALLE, KAR_IMPORTE, KAR_SALDO, KAR_DEPREHIS, KAR_DEPREPOR, KAR_DEPRENUM,
 KAR_VALORNETO      
 from '+@tabla1+' a inner join '+@tabla2+' b on a.KAR_CODACT=b.KAR_CODACT '

execute ( @sqlcad)
GO
