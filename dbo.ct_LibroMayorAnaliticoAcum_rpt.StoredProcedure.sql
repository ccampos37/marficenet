SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop  proc ct_LibroMayorAnaliticoAcum_rpt



select * from desarrollo.dbo.ct_cabcomprob2010 where empresacodigo='02' and cabcomprobmes=1 and cabcomprobglosa like ('%208849%')

exec ct_LibroMayorAnaliticoAcum_rpt 'ziyaz','02','2010','00','01','01','104101','104101','%%','TODOS'

*/
CREATE             proc [ct_LibroMayorAnaliticoAcum_rpt]
( 
    @base   varchar(50),
    @empresa varchar(2),    
    @anno   varchar(4),   
    @mesant varchar(2),
    @mesini varchar(2),	
    @mesfin varchar(2),
    @cuentacodigo char(10),
    @cuentacodigoFin char(10),
    @entidad char(12),
    @razonsocial varchar(50)
)
as
declare @sqlcad varchar(2500)
declare @sqlcad1 varchar(3500)
declare @sqlcad2 varchar(2000)

IF cast(@mesant as integer)>0 
BEGIN
set @sqlcad='SELECT A.cabcomprobmes,A.detcomprobfechaemision,A.cabcomprobnumero,a.analiticocodigo,A.documentocodigo, 
    a.centrocostocodigo,A.detcomprobnumdocumento,A.tipdocref,A.detcomprobnumref,
    detcomprobglosa=Case When ltrim(rtrim(A.detcomprobglosa)) is null Then d.cabcomprobglosa When ltrim(rtrim(A.detcomprobglosa))='''' Then d.cabcomprobglosa Else A.detcomprobglosa End,
    A.detcomprobtipocambio,A.detcomprobussdebe-A.detcomprobusshaber as ComprobUSS,A.detcomprobdebe,A.detcomprobhaber,
    SaldoDebe=C.saldoacumdebe' +@mesant+ ',
    SaldoHaber=C.saldoacumhaber' +@mesant+ ',
    SaldoIni=(C.saldoacumdebe' +@mesant+ '- C.saldoacumhaber' +@mesant+ '),
    SaldoUS =(C.saldoacumussdebe' +@mesant+ '- C.saldoacumusshaber' +@mesant+ '),'
END
ELSE
BEGIN
set @sqlcad='SELECT A.cabcomprobmes,A.detcomprobfechaemision,A.cabcomprobnumero,a.analiticocodigo,A.documentocodigo, 
    a.centrocostocodigo,A.detcomprobnumdocumento,A.tipdocref,A.detcomprobnumref,
    detcomprobglosa=Case When ltrim(rtrim(A.detcomprobglosa)) is null Then d.cabcomprobglosa When ltrim(rtrim(A.detcomprobglosa))='''' Then d.cabcomprobglosa Else A.detcomprobglosa End,
    A.detcomprobtipocambio,A.detcomprobussdebe-A.detcomprobusshaber as ComprobUSS,A.detcomprobdebe,A.detcomprobhaber,
    SaldoDebe=C.saldodebe' +@mesant+ ',
    SaldoHaber=C.saldohaber' +@mesant+ ',
	 SaldoIni=(C.saldodebe' +@mesant+ '-C.saldohaber' +@mesant+ '),
	SaldoUS =(C.saldoussdebe' +@mesant+ '- C.saldousshaber' +@mesant+ '),'
END
set @sqlcad1='SaldoFin=A.detcomprobdebe-A.detcomprobhaber,
    A.cuentacodigo,
    B.cuentadescripcion,
    A.monedacodigo,
    d.cabcomprobnprovi,Cuenta2=left(A.cuentacodigo,2),''' +@razonsocial + '''
    FROM [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A 
	inner join [' +@base+ '].dbo.[ct_cuenta] B
              on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo  
        inner join [' +@base+ '].dbo.[ct_saldos' + @anno+ '] C
              on a.empresacodigo=c.empresacodigo 
              and A.cuentacodigo = C.cuentacodigo
        inner join [' +@base+ '].dbo.[ct_cabcomprob' +@anno+ '] d 
              on a.empresacodigo=d.empresacodigo and A.cabcomprobmes=d.cabcomprobmes 
                 and a.asientocodigo=d.asientocodigo and a.cabcomprobnumero=d.cabcomprobnumero
    WHERE 
            a.empresacodigo='''+@empresa+''' and 
	a.analiticocodigo like ltrim(rtrim('''+@entidad+''')) and '
 If cast(@cuentacodigoFin as char(10)) <> '%' 
  Begin
  IF cast(@mesant as integer)>0 
   Begin
  set @sqlcad2 =' cast(A.cuentacodigo as varchar(10)) Between ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + ''' 
	 	and ''' + ltrim(rtrim(cast(@cuentacodigoFin as char(10))))  + ''' AND
      	     A.cabcomprobmes between ''' +@mesini+ ''' and ''' +@mesfin+ '''
Union all
  Select distinct '+@mesini+','''','''','''','''','''','''','''','''','''',0,0,0,0,SaldoDebe=C.saldoacumdebe' +@mesant+ ',SaldoHaber=C.saldoacumhaber' +@mesant+ ',
    SaldoIni=(C.saldoacumdebe' +@mesant+ '- C.saldoacumhaber' +@mesant+ '),SaldoUS =(C.saldoacumussdebe' +@mesant+ '- C.saldoacumusshaber' +@mesant+ '),
    0,C.cuentacodigo,D.cuentadescripcion,'''','''',Cuenta2=left(C.cuentacodigo,2),''''
    FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C /*INNER JOIN [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A
	ON a.empresacodigo=c.empresacodigo and A.cuentacodigo = C.cuentacodigo */
	Inner Join [' +@base+ '].dbo.[ct_cuenta] D On c.cuentacodigo=d.cuentacodigo And c.empresacodigo=d.empresacodigo
  WHERE c.empresacodigo='''+@empresa+''' and cast(c.cuentacodigo as varchar(10)) Between ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + ''' 
	and ''' + ltrim(rtrim(cast(@cuentacodigoFin as char(10))))  + ''' And (C.saldoacumdebe' +@mesant+ '+ C.saldoacumhaber' +@mesant+ ')>0
    	     ORDER BY A.cabcomprobmes,A.cuentacodigo'
    End
   Else  -- cast(@mesant as integer)>0 
    Begin
  set @sqlcad2 =' cast(A.cuentacodigo as varchar(10)) Between ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + ''' 
	 	and ''' + ltrim(rtrim(cast(@cuentacodigoFin as char(10))))  + ''' AND
      	     A.cabcomprobmes between ''' +@mesini+ ''' and ''' +@mesfin+ '''
Union all
  Select distinct '+@mesini+','''','''','''','''','''','''','''','''','''',0,0,0,0,SaldoDebe=C.saldodebe' +@mesant+ ',SaldoHaber=C.saldohaber' +@mesant+ ',
    SaldoIni=(C.saldodebe' +@mesant+ '- C.saldohaber' +@mesant+ '),SaldoUS =(C.saldoussdebe' +@mesant+ '- C.saldousshaber' +@mesant+ '),
    0,C.cuentacodigo,D.cuentadescripcion,'''','''',Cuenta2=left(C.cuentacodigo,2),''''
    FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C /*INNER JOIN [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A
	ON a.empresacodigo=c.empresacodigo and A.cuentacodigo = C.cuentacodigo */
	Inner Join [' +@base+ '].dbo.[ct_cuenta] D On c.cuentacodigo=d.cuentacodigo And c.empresacodigo=d.empresacodigo
  WHERE c.empresacodigo='''+@empresa+''' and cast(c.cuentacodigo as varchar(10)) Between ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + ''' 
	and ''' + ltrim(rtrim(cast(@cuentacodigoFin as char(10))))  + ''' And (C.saldodebe' +@mesant+ '+ C.saldohaber' +@mesant+ ')>0
    	     ORDER BY A.cabcomprobmes,A.cuentacodigo'
    End   -- cast(@mesant as integer)>0 
  End
Else  -- cast(@cuentacodigoFin as char(10)) <> '%' 
 Begin
  IF cast(@mesant as integer)>0 
   Begin
 set @sqlcad2 =' cast(A.cuentacodigo as varchar(10)) like ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + '%'' AND
      	    A.cabcomprobmes between ''' +@mesini+ ''' and ''' +@mesfin+ '''
Union all
  Select distinct '+@mesini+','''','''','''','''','''','''','''','''','''',0,0,0,0,SaldoDebe=C.saldoacumdebe' +@mesant+ ',SaldoHaber=C.saldoacumhaber' +@mesant+ ',
    SaldoIni=(C.saldoacumdebe' +@mesant+ '- C.saldoacumhaber' +@mesant+ '),SaldoUS =(C.saldoacumussdebe' +@mesant+ '- C.saldoacumusshaber' +@mesant+ '),
    0,C.cuentacodigo,D.cuentadescripcion,'''','''',Cuenta2=left(C.cuentacodigo,2),''''
    FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C /*INNER JOIN [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A
	ON a.empresacodigo=c.empresacodigo and A.cuentacodigo = C.cuentacodigo */
	Inner Join [' +@base+ '].dbo.[ct_cuenta] D On c.cuentacodigo=d.cuentacodigo And c.empresacodigo=d.empresacodigo
  WHERE c.empresacodigo='''+@empresa+''' and cast(c.cuentacodigo as varchar(10)) like ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + '%''
	And (C.saldoacumdebe' +@mesant+ '+ C.saldoacumhaber' +@mesant+ ')>0
    	ORDER BY A.cabcomprobmes,A.cuentacodigo'
   End
  Else  -- cast(@mesant as integer)>0 
   Begin
 set @sqlcad2 =' cast(A.cuentacodigo as varchar(10)) like ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + '%'' AND
      	    A.cabcomprobmes between ''' +@mesini+ ''' and ''' +@mesfin+ '''
Union all
  Select distinct '+@mesini+','''','''','''','''','''','''','''','''','''',0,0,0,0,SaldoDebe=C.saldodebe' +@mesant+ ',SaldoHaber=C.saldohaber' +@mesant+ ',
    SaldoIni=(C.saldodebe' +@mesant+ '- C.saldohaber' +@mesant+ '),SaldoUS =(C.saldoussdebe' +@mesant+ '- C.saldousshaber' +@mesant+ '),
    0,C.cuentacodigo,D.cuentadescripcion,'''','''',Cuenta2=left(C.cuentacodigo,2),''''
    FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C /*INNER JOIN [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] A
	ON a.empresacodigo=c.empresacodigo and A.cuentacodigo = C.cuentacodigo*/ 
	Inner Join [' +@base+ '].dbo.[ct_cuenta] D On c.cuentacodigo=d.cuentacodigo And c.empresacodigo=d.empresacodigo
  WHERE c.empresacodigo='''+@empresa+''' and cast(c.cuentacodigo as varchar(10)) like ''' + ltrim(rtrim(cast(@cuentacodigo as char(10))))  + '%''
	And (C.saldodebe' +@mesant+ '+ C.saldohaber' +@mesant+ ')>0
    	ORDER BY A.cabcomprobmes,A.cuentacodigo'
   End  -- cast(@mesant as integer)>0 
 End  -- cast(@cuentacodigoFin as char(10)) <> '%' 

execute (@sqlcad+@sqlcad1+@sqlcad2)
--print (@sqlcad+@sqlcad1+@sqlcad2)
GO
