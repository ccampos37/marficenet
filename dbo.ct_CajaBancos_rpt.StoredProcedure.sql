SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop  proc ct_CajaBancos_rpt
exec ct_CajaBancos_rpt 'mmj2008','01','2007','12','11','%%'
*/
CREATE  proc [ct_CajaBancos_rpt]
( 
    @base   varchar(50),
    @Empresa varchar(2),
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
    A.detcomprobussdebe,A.detcomprobusshaber,
    SaldoDebe=C.saldoacumdebe' +@mesant+ ',
    SaldoHaber=C.saldoacumhaber' +@mesant+ ','
END
ELSE
BEGIN
set @sqlcad='SELECT A.detcomprobfechaemision,A.cabcomprobnumero,A.documentocodigo, 
    A.detcomprobnumdocumento,A.tipdocref,A.detcomprobnumref,A.detcomprobglosa,A.detcomprobtipocambio, 
    A.detcomprobussdebe-A.detcomprobusshaber as ComprobUSS,A.detcomprobdebe,A.detcomprobhaber,
    A.detcomprobussdebe,A.detcomprobusshaber,
    SaldoDebe=C.saldodebe' +@mesant+ ',
    SaldoHaber=C.saldohaber' +@mesant+ ','
END
set @sqlcad1='SaldoIni=(C.saldodebe' +@mesant+ '- C.saldohaber' +@mesant+ '),    
    SaldoIniD=(C.saldoussdebe' +@mesant+ '- C.saldousshaber' +@mesant+ '),
    SaldoFin=A.detcomprobdebe-A.detcomprobhaber,
    A.cuentacodigo,
    B.cuentadescripcion,
    A.monedacodigo,
    Cuenta2=left(A.cuentacodigo,2)
    FROM  
	[' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A, 
	[' +@base+ '].dbo.[ct_cuenta] B, 
        	[' +@base+ '].dbo.[ct_saldos' + @anno+ '] C
    WHERE 
        a.empresacodigo=b.empresacodigo and
        A.cuentacodigo = B.cuentacodigo AND
       	a.empresacodigo=c.empresacodigo and 
	A.cuentacodigo = C.cuentacodigo AND
	A.cuentacodigo like ''' +@cuentacodigo+ ''' AND
       	A.cabcomprobmes=''' +@mesact+ ''' AND 
	A.empresacodigo='''+@empresa+'''  
    ORDER BY A.cuentacodigo'
     
exec (@sqlcad+@sqlcad1)
--set @cad='Select saldodebe' +@mes+ '- saldohaber' +@mes+ ' as SaldoInicial from  ct_saldosXXXX'
GO
