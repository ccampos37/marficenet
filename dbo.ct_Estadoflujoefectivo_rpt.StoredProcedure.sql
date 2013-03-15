SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop     proc ct_Estadoflujoefectivo_rpt
execute ct_Estadoflujoefectivo_rpt 'aliterm2012','01','2012','10','##xx'
*/
CREATE      proc [ct_Estadoflujoefectivo_rpt]
(@Base varchar(50),
 @empresa varchar(2), 
 @anno varchar(4), 
 @mes varchar(2),
 @compu varchar(50)
)
as
Declare @sqlcad varchar(5000)
Declare @anno1 varchar(4)
set @anno1=str(CAST(@Anno as integer)-1,4)
  
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_estadoflujoefectivo'+@compu)
  exec('DROP TABLE ##tmp_estadoflujoefectivo'+@compu)
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_estadoflujoefectivoant'+@compu)
  exec('DROP TABLE ##tmp_estadoflujoefectivoant'+@compu)
--Sumariza las cuentas y agrupa por la Línea a nivel Detalle
Set @sqlcad=' 
	select H.EGP_DESCRI,H.EGP_LINEA,EGP_NIVEL,TOT.*
	 INTO ##tmp_estadoflujoefectivo' +@compu+ ' 
	 FROM [' +@base+ '].dbo.ct_strucganper H
	 left join
	( Select linea,sAcum=sum(SaldoAcum),sMes=sum(Saldo),sAcumD=sum(SaldoAcumD),sMesD=sum(SaldoD)
		from
		(Select A.CuentaCodigo,linea=B.EGP_LINEA,
	   		SaldoAcum=saldoacumhaber' +@mes+ '-saldoacumdebe' +@mes+ ', 	       
   			Saldo=saldohaber' +@mes+ '-saldodebe' +@mes+ ',
	   		SaldoAcumD=saldoacumusshaber' +@mes+ '-saldoacumussdebe' +@mes+ ',	
	   		SaldoD=saldousshaber' +@mes+ '-saldoussdebe' +@mes+ '
	 	from [' +@base+ '].dbo.ct_saldos' +@anno+ ' A ,[' +@base+ '].dbo.ct_strucganper B
 	 	Where   A.empresacodigo like ''' +@empresa+  ''' and
                        PATINDEX(''%''+left(A.Cuentacodigo,B.EGP_NIVELCUENTA)+''%'',B.EGP_CUENTA) > 0 and 
        	   	EGP_TIPO=''03'' AND
           		(A.saldoacumdebe' +@mes+ '+A.saldoacumhaber' +@mes+ ')<>0) as X
     	Group by linea 
    ) as TOT on H.EGP_LINEA=TOT.linea 
    where EGP_TIPO=''03'' ORDER BY H.EGP_LINEA ' +char(13)+ char(13) + ''
exec(@sqlcad)
--PRINT(@sqlcad)
exec('update ##tmp_estadoflujoefectivo' +@compu+ ' set sAcum=0,sMes=0,sAcumD=0,sMesD=0 where sAcum is null or sMes is null or sAcumD is null or sMesD is null')
DECLARE @linea integer,@tot varchar(2),@formes varchar(100)
   exec('DECLARE tablas CURSOR FOR 
      	SELECT EGP_LINEA,egp_tot,EGP_FORMULA from [' +@base+ '].dbo.ct_strucganper_tot WHERE EGP_TOT like ''R%'' AND EGP_TIPO=''03'' ORDER BY egp_tot')
	OPEN tablas
	/* Leer cada registro del cursor  */
	FETCH NEXT FROM tablas INTO @linea,@tot,@formes
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @cadsql varchar(3000)
			set @cadsql=''
			set @cadsql='update ##tmp_estadoflujoefectivo' +@compu+ ' 
			    set sAcum=(select sum(sAcum) from ##tmp_estadoflujoefectivo' +@compu+ ' where egp_linea in ' +@formes+ '),
                sMes=(select sum(sMes) from ##tmp_estadoflujoefectivo' +@compu+ ' where egp_linea in ' +@formes+ '),  
				sAcumD=(select sum(sAcumD) from ##tmp_estadoflujoefectivo' +@compu+ ' where egp_linea in ' +@formes+ '),
				sMesD=(select sum(sMesD) from ##tmp_estadoflujoefectivo' +@compu+ ' where egp_linea in ' +@formes+ ')
				where egp_linea=' + rtrim(cast(@linea as varchar(2)))
            exec(@cadsql)
 	FETCH NEXT FROM tablas INTO @linea, @tot, @formes
    END
	CLOSE tablas
	DEALLOCATE tablas
Set @sqlcad=' 
	select H.EGP_DESCRI,H.EGP_LINEA,EGP_NIVEL,TOT.* 
	INTO ##tmp_estadoflujoefectivoant' +@compu+ ' 
	FROM [' +@base+ '].dbo.ct_strucganper H
	left join 
	( Select linea,sAcum=sum(SaldoAcum),sMes=sum(Saldo),sAcumD=sum(SaldoAcumD),sMesD=sum(SaldoD)
		from
		(Select A.CuentaCodigo,linea=B.EGP_LINEA,
	   		SaldoAcum=saldoacumhaber' +@mes+ '-saldoacumdebe' +@mes+ ', 	       
   			Saldo=saldohaber' +@mes+ '-saldodebe' +@mes+ ',
	   		SaldoAcumD=saldoacumusshaber' +@mes+ '-saldoacumussdebe' +@mes+ ',	
	   		SaldoD=saldousshaber' +@mes+ '-saldoussdebe' +@mes+ '
	 	from [' +@base+ '].dbo.ct_saldos' +@anno1+ ' A ,[' +@base+ '].dbo.ct_strucganper B
 	 	Where   A.empresacodigo like ''' +@empresa+  ''' and
			PATINDEX(''%''+left(A.Cuentacodigo,B.EGP_NIVELCUENTA)+''%'',B.EGP_CUENTA) > 0 and 
        	   	EGP_TIPO=''03'' AND
           		(A.saldoacumdebe' +@mes+ '+A.saldoacumhaber' +@mes+ ')<>0) as X
     	Group by linea
    ) as TOT on H.EGP_LINEA=TOT.linea 
    where EGP_TIPO=''03'' ORDER BY H.EGP_LINEA ' +char(13)+ char(13) + ''
exec(@sqlcad)
--PRINT(@sqlcad)
exec('update ##tmp_estadoflujoefectivoant' +@compu+ ' set sAcum=0,sMes=0,sAcumD=0,sMesD=0 where sAcum is null or sMes is null or sAcumD is null or sMesD is null')
   exec('DECLARE tablas1 CURSOR FOR 
      	SELECT EGP_LINEA,egp_tot,EGP_FORMULA from [' +@base+ '].dbo.ct_strucganper_tot WHERE EGP_TOT like ''R%'' AND EGP_TIPO=''03'' ORDER BY egp_tot')
	OPEN tablas1
	/* Leer cada registro del cursor  */
	FETCH NEXT FROM tablas1 INTO @linea,@tot,@formes
	WHILE @@FETCH_STATUS = 0
	BEGIN
			set @cadsql=''
			set @cadsql='update ##tmp_estadoflujoefectivoant' +@compu+ ' set sAcum=(select sum(sAcum) from ##tmp_estadoflujoefectivoant' +@compu+ ' where egp_linea in ' +@formes+ '),
                sMes=(select sum(sMes) from ##tmp_estadoflujoefectivoant' +@compu+ ' where egp_linea in ' +@formes+ '),  
				sAcumD=(select sum(sAcumD) from ##tmp_estadoflujoefectivoant' +@compu+ ' where egp_linea in ' +@formes+ '),
				sMesD=(select sum(sMesD) from ##tmp_estadoflujoefectivoant' +@compu+ ' where egp_linea in ' +@formes+ ')
				where egp_linea=' + rtrim(cast(@linea as varchar(2)))
            exec(@cadsql)
 	FETCH NEXT FROM tablas1 INTO @linea, @tot, @formes
    END
	CLOSE tablas1
	DEALLOCATE tablas1
	 
	set @sqlcad=' select H.EGP_DESCRI,H.EGP_LINEA,h.EGP_NIVEL,mes=h.smes , mesant=hh.smes
	                     from ##tmp_estadoflujoefectivo' +@compu+ ' h 
	                     left join  ##tmp_estadoflujoefectivoant' +@compu+ ' hh on h.egp_linea=hh.egp_linea ' 
	execute(@sqlcad)
GO
