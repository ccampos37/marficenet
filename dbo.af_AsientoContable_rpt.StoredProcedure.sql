SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute af_AsientoContable_rpt 'planta_casma'

*/


CREATE proc [af_AsientoContable_rpt]
@base varchar(50)
as
Declare @sqlcad varchar(4000)

set @sqlcad ='select   a.CO_C_SUBDI, a.CO_C_COMPR, a.CO_D_FECHA,glosacab= a.CO_A_GLOSA,CO_C_MONED, CO_C_CONVE, CO_N_CAMES, a.CO_D_FECCA, CO_N_TIPCA, 
                     CO_C_DESMES, CO_C_DESCRSUBDI,CO_C_SECUE, CO_C_CUENT, CO_C_ANEXO, CO_C_DOCUM, CO_D_FECDC,CO_C_CENCO, b.CO_N_DEBE, b.CO_N_HABER, 
                     b.CO_N_DEBUS, b.CO_N_HABUS, glosadet=b.CO_A_GLOSA, CO_L_TRANS, CO_L_DESTI,CO_C_DESTI
FROM '+@base+'.dbo.af_tempocab a
inner join '+@base+'.dbo.af_tempodet b On a.co_c_subdi+a.co_c_compr=b.co_c_subdi+b.co_c_compr  '

execute (@sqlcad )
GO
