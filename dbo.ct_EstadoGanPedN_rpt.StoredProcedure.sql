SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* 
drop proc ct_EstadoGanPedN_rpt
 EXEC ct_EstadoGanPedN_rpt 'planta_casma','03','2011','02','##xsde'
*/
CREATE           proc [ct_EstadoGanPedN_rpt]
(
 @Base varchar(50),
 @empresa varchar(2),  
 @anno varchar(4),
 @mes varchar(2),
 @compu varchar(30)
)
as
Declare @sqlcad varchar(5000)
--Declare @sqlcad1 varchar(5000)
/*
DECLARE @Base varchar(50), @anno varchar(4),  @mes varchar(2), @compu varchar(20)
SET @BASE='CONTAPRUEBA'
SET @ANNO='2002'
SET @MES='12'
SET @COMPU='IVAN'
*/
 
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_estadoganpedN'+@compu)
  exec('DROP TABLE ##tmp_estadoganpedN'+@compu)
--Sumariza las cuentas y agrupa por la Línea a nivel Detalle
Set @sqlcad=' 
	select H.EGP_DESCRI,H.EGP_LINEA,EGP_NIVEL,TOT.* INTO ##tmp_estadoganpedN' +@compu+ ' FROM
                [' +@base+ '].dbo.ct_strucganper H
         left join       
		(select linea,sAcum=sum(SaldoAcum),sMes=sum(Saldo),sAcumD=sum(SaldoAcumD),sMesD=sum(SaldoD)
		from
		(Select A.CuentaCodigo,linea=B.EGP_LINEA,
	   		SaldoAcum=saldoacumhaber' +@mes+ '-saldoacumdebe' +@mes+ ', 	       
   			Saldo=saldohaber' +@mes+ '-saldodebe' +@mes+ ',
	   		SaldoAcumD=saldoacumusshaber' +@mes+ '-saldoacumussdebe' +@mes+ ',	
	   		SaldoD=saldousshaber' +@mes+ '-saldoussdebe' +@mes+ '
	 	from [' +@base+ '].dbo.ct_saldos' +@anno+ ' A ,[' +@base+ '].dbo.ct_strucganper B
 	 	Where   A.empresacodigo like ''' +@empresa+  ''' and
                        PATINDEX(''%''+left(A.Cuentacodigo,B.EGP_NIVELCUENTA)+''%'',B.EGP_CUENTA) > 0 and 
        	   	EGP_TIPO=''02'' AND
           		(A.saldoacumdebe' +@mes+ '+A.saldoacumhaber' +@mes+ ')<>0) as X
     	Group by linea ) as TOT
     	on H.EGP_LINEA=TOT.linea 
     	where EGP_TIPO=''02''
	ORDER BY H.EGP_LINEA ' +char(13)+ char(13) + ''
exec(@sqlcad)
--PRINT(@sqlcad)
exec('update ##tmp_estadoganpedN' +@compu+ ' set sAcum=0,sMes=0,sAcumD=0,sMesD=0 where sAcum is null or sMes is null or sAcumD is null or sMesD is null')
DECLARE @linea integer,@tot varchar(2),@formes varchar(100)
   exec('DECLARE tablas CURSOR FOR 
      	SELECT EGP_LINEA,egp_tot,EGP_FORMULA from [' +@base+ '].dbo.ct_strucganper_tot WHERE EGP_TOT like ''R%'' AND EGP_TIPO=''02'' ORDER BY egp_tot')
	OPEN tablas
	/* Leer cada registro del cursor  */
	FETCH NEXT FROM tablas INTO @linea,@tot,@formes
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @cadsql varchar(3000)
			set @cadsql=''
			set @cadsql='update ##tmp_estadoganpedN' +@compu+ ' set sAcum=(select sum(sAcum) from ##tmp_estadoganpedN' +@compu+ ' where egp_linea in ' +@formes+ '),
                sMes=(select sum(sMes) from ##tmp_estadoganpedN' +@compu+ ' where egp_linea in ' +@formes+ '),  
				sAcumD=(select sum(sAcumD) from ##tmp_estadoganpedN' +@compu+ ' where egp_linea in ' +@formes+ '),
				sMesD=(select sum(sMesD) from ##tmp_estadoganpedN' +@compu+ ' where egp_linea in ' +@formes+ ')
				where egp_linea=' + rtrim(cast(@linea as varchar(2)))
            exec(@cadsql)
 	FETCH NEXT FROM tablas INTO @linea, @tot, @formes
    END
	CLOSE tablas
	DEALLOCATE tablas
    
    set nocount off
    exec('select * from ##tmp_estadoganpedN' +@compu+ ' order by 2')


/****** Object:  StoredProcedure [dbo].[ct_EstadoGanPedF_rpt]    Script Date: 12/07/2011 10:16:44 ******/
SET ANSI_NULLS ON
GO
