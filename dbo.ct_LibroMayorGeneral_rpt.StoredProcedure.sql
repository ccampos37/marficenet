SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* 
drop proc ct_LibroMayorGeneral_rpt
exec ct_LibroMayorGeneral_rpt 'PLANTA_CASMA','01','2008','01','01','%%','%%','%%','%%','0'
*/

CREATE                  proc [ct_LibroMayorGeneral_rpt]
( 
    @base   varchar(50),
    @empresa varchar(2),
    @anno   varchar(4),
    @mesant varchar(2),  --3
    @mesact varchar(2),  --4
    @cuentacodigo varchar(20),
    @asientocodigo varchar(3),
    @subasientocodigo varchar(3),
    @cuentacodigoFin varchar(20),
    @acumula varchar(1)
)
as
declare @sqlcad varchar(5000),@sqlcad1 varchar(5000)
declare @mes integer
set @mes=cast(@mesant-1 as integer)
declare @actmes as varchar(2)
declare @antmes as varchar(2)
declare @inimes as varchar(2)
set @inimes=cast(@mes as varchar(2))
set @inimes=right('00'+rtrim(ltrim(@inimes)),2)

if @acumula = '1' 
 begin
  set @actmes = @mesact
  set @antmes = @mesant
 end
else
 begin
  set @actmes = @mesact
  set @antmes = @mesact
 end

if @mes>0
BEGIN
set @sqlcad='SELECT A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
     	SaldoSDebe=C.saldoacumdebe' +@inimes+ ',SaldoSHaber=C.saldoacumhaber' + @inimes+',
    	SaldoDDebe=C.saldoacumussdebe' + @inimes+ ',SaldoDHaber=C.saldoacumusshaber' + @inimes + ',
	    DebeSoles=sum(A.detcomprobdebe),HaberSoles=sum(A.detcomprobhaber),
	    DebeDolar=sum(A.detcomprobussdebe),HaberDolar=sum(A.detcomprobusshaber),A.cabcomprobmes
		,'+ @acumula +'as acumula
        FROM  [' +@base+ '].dbo.[ct_detcomprob' + @anno + '] A
              inner join  [' +@base+ '].dbo.[ct_cuenta] B 
                  on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
	      inner join  [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C 
                  on A.cuentacodigo = C.cuentacodigo AND A.empresacodigo=C.empresacodigo
              inner join  [' +@base+ '].dbo.[ct_asiento] D
                  on 	A.asientocodigo=D.asientocodigo '

If cast(@cuentacodigoFin as varchar(20)) <> '%%'
 Begin
    Set @sqlcad = @sqlcad + ' WHERE   
		A.empresacodigo like ''' +@empresa+ ''' AND
     		A.cuentacodigo Between ''' +@cuentacodigo+ ''' And ''' +@cuentacodigoFin+ ''' AND
       		A.cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''' AND
       		A.asientocodigo like ''' +@asientocodigo+ ''' AND 
       		A.subasientocodigo like ''' +@subasientocodigo+ ''' 
    	GROUP BY 
			A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
        	C.saldoacumdebe' +@inimes+ ',C.saldoacumhaber' +@inimes+ ',
  			C.saldoacumussdebe' +@inimes+ ',C.saldoacumusshaber' +@inimes+',A.cabcomprobmes'
 End
Else
 Begin
    Set @sqlcad = @sqlcad + ' WHERE   
		A.empresacodigo like ''' +@empresa+ ''' AND
     		A.cuentacodigo like ''' +@cuentacodigo+ '%'' AND
       		A.cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''' AND
       		A.asientocodigo like ''' +@asientocodigo+ ''' AND
       		A.subasientocodigo like ''' +@subasientocodigo+ ''' 
    	GROUP BY 
			A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
        	C.saldoacumdebe' +@inimes+ ',C.saldoacumhaber' +@inimes+ ',
  			C.saldoacumussdebe' +@inimes+ ',C.saldoacumusshaber' +@inimes+',A.cabcomprobmes'
 End
END

if @mes=0
BEGIN
set @sqlcad='SELECT A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
     		SaldoSDebe=C.saldodebe' +@inimes+ ',SaldoSHaber=C.saldohaber' + @inimes+',
			SaldoDDebe=C.saldoussdebe' + @inimes+ ',SaldoDHaber=C.saldousshaber' + @inimes + ',
			DebeSoles=sum(A.detcomprobdebe),HaberSoles=sum(A.detcomprobhaber),
			DebeDolar=sum(A.detcomprobussdebe),HaberDolar=sum(A.detcomprobusshaber),A.cabcomprobmes
			,'+ @acumula +' as acumula
    		FROM  
                  [' +@base+ '].dbo.[ct_detcomprob' + @anno + '] A
                  inner join [' +@base+ '].dbo.[ct_cuenta] B
                      on  a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo 
	      	  inner join [' +@base+ '].dbo.[ct_saldos' +@anno+ '] C
          	      on A.cuentacodigo = C.cuentacodigo AND A.empresacodigo=C.empresacodigo
                  inner join [' +@base+ '].dbo.[ct_asiento] D
                      on A.asientocodigo=D.asientocodigo '

If cast(@cuentacodigoFin as varchar(20)) <> '%%'
 Begin
    Set @sqlcad = @sqlcad + ' WHERE 
                        A.empresacodigo like ''' +@empresa+ ''' AND
       			A.cuentacodigo Between ''' +@cuentacodigo+ ''' And ''' +@cuentacodigoFin+ ''' AND
       			A.cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''' AND
       			A.asientocodigo like ''' +@asientocodigo+ ''' AND
       			A.subasientocodigo like ''' +@subasientocodigo+ ''' 
    		GROUP BY 
				A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
        		C.saldodebe' +@inimes+ ',C.saldohaber' +@inimes+ ',
  				C.saldoussdebe' +@inimes+ ',C.saldousshaber' +@inimes+',A.cabcomprobmes'
 End
Else
 Begin
    Set @sqlcad = @sqlcad + ' WHERE 
                        A.empresacodigo like ''' +@empresa+ ''' AND
       			A.cuentacodigo like ''' +@cuentacodigo+ '%'' AND
       			A.cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''' AND
       			A.asientocodigo like ''' +@asientocodigo+ ''' AND
       			A.subasientocodigo like ''' +@subasientocodigo+ ''' 
    		GROUP BY 
				A.cuentacodigo, B.cuentadescripcion,A.asientocodigo,D.asientodescripcion,
        		C.saldodebe' +@inimes+ ',C.saldohaber' +@inimes+ ',
  				C.saldoussdebe' +@inimes+ ',C.saldousshaber' +@inimes+',A.cabcomprobmes'
 End
END
if @mes>0
BEGIN
  set @sqlcad1=' UNION SELECT A.cuentacodigo, B.cuentadescripcion,''000'',''(Ninguno)'',
        saldoacumdebe' +@inimes+ ',saldoacumhaber' +@inimes+ ',saldoacumussdebe' +@inimes+ ',saldoacumusshaber' +@inimes+ ',0,0,0,0,0
		,'+ @acumula +'as acumula
	    FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] A,
             [' +@base+ '].dbo.[ct_cuenta] B '

If cast(@cuentacodigoFin as varchar(20)) <> '%%'
 Begin
    Set @sqlcad1 = @sqlcad1 + ' WHERE 
		  A.cuentacodigo = B.cuentacodigo AND
	          A.empresacodigo like ''' +@empresa+ ''' AND
                  A.cuentacodigo Between ''' +@cuentacodigo+ ''' And ''' +@cuentacodigoFin+ ''' AND
                  A.cuentacodigo not in (select cuentacodigo from [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] where cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''') and
                  (A.saldoacumdebe' +@inimes+ '<>0 or A.saldoacumhaber' +@inimes+ '<>0 or A.saldoacumussdebe' +@inimes+ '<>0 or A.saldoacumusshaber' +@inimes+ '<>0)'
 End
Else
 Begin
    Set @sqlcad1 = @sqlcad1 + ' WHERE 
		  A.cuentacodigo = B.cuentacodigo AND
	          A.empresacodigo like ''' +@empresa+ ''' AND
                  A.cuentacodigo like ''' +@cuentacodigo+ '%'' AND
                  A.cuentacodigo not in (select cuentacodigo from [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] where cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''') and
                  (A.saldoacumdebe' +@mesant+ '<>0 or A.saldoacumhaber' +@mesant+ '<>0 or A.saldoacumussdebe' +@mesant+ '<>0 or A.saldoacumusshaber' +@mesant+ '<>0)'
 End
END
if @mes=0 
BEGIN
  set @sqlcad1=' UNION SELECT A.cuentacodigo, B.cuentadescripcion,''000'',''(Ninguno)'',
        saldodebe' +@inimes+ ',saldohaber' +@inimes+ ',saldoussdebe' +@inimes+ ',saldousshaber' +@inimes+ ',0,0,0,0,0
		,'+ @acumula +' as acumula
        FROM [' +@base+ '].dbo.[ct_saldos' +@anno+ '] A inner join 
	     [' +@base+ '].dbo.[ct_cuenta] B on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo '

If cast(@cuentacodigoFin as varchar(20)) <> '%%'
 Begin
    Set @sqlcad1 = @sqlcad1 + ' WHERE     A.empresacodigo like ''' +@empresa+ ''' AND
	          A.cuentacodigo Between ''' +@cuentacodigo+ ''' And ''' +@cuentacodigoFin+ ''' AND
                  a.empresacodigo+A.cuentacodigo not in 
                 (select empresacodigo+cuentacodigo from [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] 
                    where cabcomprobmes between ''' + @inimes + ''' And ''' +@actmes+ ''') and
                  (A.saldodebe' +@inimes+ '<>0 or A.saldohaber' +@inimes+ '<>0 or A.saldoussdebe' +@inimes+ '<>0 or A.saldousshaber' +@inimes+ '<>0)'
 End
Else
 Begin
    Set @sqlcad1 = @sqlcad1 + ' WHERE     A.empresacodigo like ''' +@empresa+ ''' AND
	          A.cuentacodigo like ''' +@cuentacodigo+ '%'' AND
                  a.empresacodigo+A.cuentacodigo not in (select empresacodigo+cuentacodigo from [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] where cabcomprobmes between ''' + @antmes + ''' And ''' +@actmes+ ''') and
                  (A.saldodebe' +@inimes+ '<>0 or A.saldohaber' +@inimes+ '<>0 or A.saldoussdebe' +@inimes+ '<>0 or A.saldousshaber' +@inimes+ '<>0)'
 End
END
set @sqlcad1 = @sqlcad1 + ' Order By A.cabcomprobmes'
exec (@sqlcad + @sqlcad1)
--print (@sqlcad + @sqlcad1)
GO
