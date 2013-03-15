SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop             proc ct_bkLibroMayorAnalitico_rpt
*/
CREATE    proc [ct_bkLibroMayorAnalitico_rpt]
( 
    @base   varchar(50),
    @empresa varchar(2),
    @anno   varchar(4),
    @mesact varchar(2),
    @mesant varchar(2),
    @cuentacodigo varchar(20)
)
as
declare @sqlcad varchar(2000)
declare @sqlcad1 varchar(3000)
IF cast(@mesant as integer)>0 
BEGIN
set @sqlcad='SELECT A.detcomprobfechaemision,A.cabcomprobnumero,A.documentocodigo, 
    A.detcomprobnumdocumento,A.tipdocref,A.detcomprobnumref,A.detcomprobglosa,A.detcomprobtipocambio, 
    A.detcomprobussdebe-A.detcomprobusshaber as ComprobUSS,A.detcomprobdebe,A.detcomprobhaber,
    SaldoDebe=C.saldoacumdebe' +@mesant+ ',
    SaldoHaber=C.saldoacumhaber' +@mesant+ ',
    SaldoIni=(C.saldoacumdebe' +@mesant+ '- C.saldoacumhaber' +@mesant+ '),'
END
ELSE
BEGIN
set @sqlcad='SELECT A.detcomprobfechaemision,A.cabcomprobnumero,A.documentocodigo, 
    A.detcomprobnumdocumento,A.tipdocref,A.detcomprobnumref,A.detcomprobglosa,A.detcomprobtipocambio, 
    A.detcomprobussdebe-A.detcomprobusshaber as ComprobUSS,A.detcomprobdebe,A.detcomprobhaber,
    SaldoDebe=C.saldodebe' +@mesant+ ',
    SaldoHaber=C.saldohaber' +@mesant+ ',
	SaldoIni=(C.saldodebe' +@mesant+ '-C.saldohaber' +@mesant+ '),'
END
set @sqlcad1='SaldoFin=A.detcomprobdebe-A.detcomprobhaber,
    A.cuentacodigo,
    B.cuentadescripcion,
    A.monedacodigo,
    Cuenta2=left(A.cuentacodigo,2)
    FROM  
		[' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A, 
		[' +@base+ '].dbo.[ct_cuenta] B, 
    	[' +@base+ '].dbo.[ct_saldos' + @anno+ '] C
    WHERE a.empresacodigo=b.empresacodigo and 
	A.cuentacodigo = B.cuentacodigo and
       a.empresacodigo = c.empresacodigo and 
       A.cuentacodigo = C.cuentacodigo AND
       a.empresacodigo like ''' +@empresa+ ''' AND
       A.cuentacodigo like ''' +@cuentacodigo+ ''' AND
       A.cabcomprobmes=''' +@mesact+ ''' 
       ORDER BY A.cuentacodigo'
     
exec (@sqlcad+@sqlcad1)
--exec ct_LibroMayorAnalitico_rpt 'PRUEBA_contaprueba_SANIL','2002','01','00','104115'
--set @cad='Select saldodebe' +@mes+ '- saldohaber' +@mes+ ' as SaldoInicial from  ct_saldosXXXX'
GO
