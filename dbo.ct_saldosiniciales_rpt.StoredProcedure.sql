SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop  PROCEDURE ct_saldosiniciales_rpt

execute ct_saldosiniciales_rpt 'gremco','30','2008'
select * from 
*/
CREATE          PROCEDURE [ct_saldosiniciales_rpt]
@base varchar(20),
@empresa AS VARCHAR(2),
@ano varchar(4)


AS
DECLARE @CADENA AS NVARCHAR(1000)
SET @CADENA='SELECT a.cuentacodigo,b.cuentadescripcion,a.saldodebe00,a.saldohaber00 
             FROM '+@base+'.dbo.ct_saldos'+@ano+' a
             inner join '+@base+'.dbo.ct_cuenta b
                on a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo 
             where a.empresacodigo='''+@empresa+''' and (a.saldodebe00 > 0 or a.saldohaber00 > 0) 
             order by 1 '

execute(@CADENA)
--print(@CADENA)
---select * from planta_casma.dbo.ct_cuenta where empresacodigo='02'
GO
