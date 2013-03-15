SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_EstadoGanPedF_rpt

execute ct_EstadoGanPedF_rpt 'planta_casma','03','2011','09','##xx',0

*/
CREATE         proc [ct_EstadoGanPedF_rpt]
(
 
 @Base varchar(50),
 @empresa varchar(2),  
 @anno varchar(4),
 @mes varchar(2),
 @compu varchar(30),
 @acum integer=0
)
as
Declare @sqlcad varchar(5000)
Declare @sqlcad1 varchar(5000)
 
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_estadoganped'+@compu)
  exec('DROP TABLE ##tmp_estadoganped'+@compu)
Set @sqlcad=''
Set @sqlcad='
select H.EGP_DESCRI,H.EGP_LINEA,EGP_NIVEL,TOT.* INTO ##tmp_estadoganped' +@compu+ ' 
       FROM [' +@base+ '].dbo.ct_strucganper H
 left join 
(select linea=EGP_LINEA,sAcum=sum(sAcum),sMes=sum(sMes),sAcumD=sum(sAcumD),sMesD=sum(sMesD) from 
(select * from [' +@base+ '].dbo.ct_strucganper_tot,
(select linea,sAcum=sum(SaldoAcum),sMes=sum(Saldo),sAcumD=sum(SaldoAcumD),sMesD=sum(SaldoD)
from
(Select A.CuentaCodigo,linea=B.EGP_LINEA,
	  	SaldoAcum=saldoacumhaber' +@mes+ '-saldoacumdebe' +@mes+ ', 	       
      		Saldo=saldohaber' +@mes+ '-saldodebe' +@mes+ ',
 	    	SaldoAcumD=saldoacumusshaber' +@mes+ '-saldoacumussdebe' +@mes+ ',	
	    	SaldoD=saldousshaber' +@mes+ '-saldoussdebe' +@mes+ '
	 from [' +@base+ '].dbo.ct_saldos' +@anno+ ' A ,[' +@base+ '].dbo.ct_strucganper B
 	 Where A.empresacodigo like ''' +@empresa+  ''' and
           PATINDEX(''%''+left(A.Cuentacodigo,B.EGP_NIVELCUENTA)+''%'',B.EGP_CUENTA) > 0 and 
           EGP_TIPO=''01'' AND
           (saldoacumdebe' +@mes+ '+saldoacumhaber' +@mes+ ')<>0 ) as X
     Group by linea) as Y
Where PATINDEX(''%*''+rtrim(cast(LINEA as varchar(2)))+''*%'',EGP_FORMES) > 0 and EGP_TOT=''D'') as YY
where PATINDEX(''%*''+rtrim(cast(YY.LINEA as varchar(2)))+''*%'',YY.EGP_FORMES) > 0  
group by EGP_LINEA
union all
--Sumariza las cuentas y agrupa por la Línea a nivel Detalle
select linea,sAcum=sum(SaldoAcum),sMes=sum(Saldo),sAcumD=sum(SaldoAcumD),sMesD=sum(SaldoD)
from
(Select A.CuentaCodigo,linea=B.EGP_LINEA,
	   	SaldoAcum=saldoacumhaber' +@mes+ '-saldoacumdebe' +@mes+ ', 	       
   		Saldo=saldohaber' +@mes+ '-saldodebe' +@mes+ ',
	   	SaldoAcumD=saldoacumusshaber' +@mes+ '-saldoacumussdebe' +@mes+ ',	
	   	SaldoD=saldousshaber' +@mes+ '-saldoussdebe' +@mes+ '
     from [' +@base+ '].dbo.ct_saldos' +@anno+ ' A ,[' +@base+ '].dbo.ct_strucganper B
 	 Where A.empresacodigo like ''' +@empresa+  ''' and
           PATINDEX(''%''+left(A.Cuentacodigo,B.EGP_NIVELCUENTA)+''%'',B.EGP_CUENTA) > 0 and 
           EGP_TIPO=''01'' AND
           (A.saldoacumdebe' +@mes+ '+A.saldoacumhaber' +@mes+ ')<>0 and B.EGP_LINEA not in (select EGP_LINEA 
           from [' +@base+ '].dbo.ct_strucganper_tot)) as X
     Group by linea ) as TOT
 on H.EGP_LINEA=TOT.linea 
 where EGP_TIPO=''01'' ORDER BY H.EGP_LINEA ' +char(13)+ char(13) + ''

execute(@sqlcad)

set @sqlcad=' update ##tmp_estadoganped' +@compu+ ' 
    set smes=b.mes , sacum=b.acum 
    from ##tmp_estadoganped' +@compu+ ' a, 
    ( select mes=sum(gastos' +@mes+ '),acum= sum(gastosacum' +@mes+ ')
      from [' +@base+ '].dbo.ct_gastos' +@anno+ ' where empresacodigo='''+@empresa+''' and 
           left(centrocostocodigo,2)=''10''
    ) b
    where egp_linea=50
  
    update ##tmp_estadoganped' +@compu+ ' 
    set smes=b.mes , sacum=b.acum 
    from ##tmp_estadoganped' +@compu+ ' a, 
    ( select mes=sum(gastos' +@mes+ '),acum= sum(gastosacum' +@mes+ ')
      from [' +@base+ '].dbo.ct_gastos' +@anno+ ' where empresacodigo='''+@empresa+''' and 
           left(centrocostocodigo,2)=''20''
    ) b where egp_linea=48 '

--execute(@sqlcad)

set @sqlcad1='update ##tmp_estadoganped'   +@compu+   ' set sAcum=0 where sAcum is null                                    
		    	update ##tmp_estadoganped' +@compu+ ' set sMes=0 where sMes is null
				update ##tmp_estadoganped' +@compu+ ' set sAcumD=0 where sAcumD is null
				update ##tmp_estadoganped' +@compu+  ' set sMesD=0 where sMesD is null '
set @sqlcad1=@sqlcad1+'DECLARE @linea integer,@tot varchar(2),@formes varchar(100)
	DECLARE tablas CURSOR FOR 
      	SELECT EGP_LINEA,egp_tot,EGP_FORMULA from [' +@base+ '].dbo.ct_strucganper_tot WHERE EGP_TOT like ''R%'' AND EGP_TIPO=''01'' ORDER BY egp_tot,egp_linea
	OPEN tablas
	/* Leer cada registro del cursor  */
	FETCH NEXT FROM tablas INTO @linea,@tot,@formes
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @xAcu numeric(20,2),@xMes numeric(20,2),@xAcuD numeric(20,2),@xMesD numeric(20,2)
        DECLARE @xAcu1 numeric(20,2),@xMes1 numeric(20,2),@xAcu2 numeric(20,2),@xMes2 numeric(20,2)
 		/*set @xAcu=(select sum(sAcum) 	from MARFICE.DBO.CT_TMPREP_EGPF where EGP_LINEA in @formes)
		set @xMes=(select sum(sMes)  	from MARFICE.DBO.CT_TMPREP_EGPF where EGP_LINEA in @formes)
		set @xAcuD=(select sum(sAcumD)  from MARFICE.DBO.CT_TMPREP_EGPF where EGP_LINEA in @formes)
		set @xMesD=(select sum(sMesD)  	from MARFICE.DBO.CT_TMPREP_EGPF where EGP_LINEA in @formes)
       		 */
		if @linea=20
			begin 
		  		set @xAcu=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (2,16))
				set @xMes=(select sum(sMes)  		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (2,16))
				set @xAcuD=(select sum(sAcumD)  	from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (2,16))
				set @xMesD=(select sum(sMesD)  		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (2,16))
			end
		if @linea=40
			begin 
		  		set @xAcu1=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (20))
				set @xMes1=(select sum(sMes) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (20))
		  		set @xAcu2=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (24))
				set @xMes2=(select sum(sMes) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (24))
				set @xAcu=@xAcu1+@xAcu2                
				set @xMes=@xMes1+@xMes2
				set @xAcuD=(select sum(sAcumD)  	from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (20,24))
				set @xMesD=(select sum(sMesD)  		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (20,24))
			end
	
		if @linea=54
			begin 
		  		set @xAcu=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (40,44))
				set @xMes=(select sum(sMes)  		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (40,44))
				set @xAcuD=(select sum(sAcumD) 		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (40,44))
				set @xMesD=(select sum(sMesD)  		from ##tmp_estadoganped' +@compu+  ' where EGP_LINEA in (40,44))
			end
		if @linea=80
			begin 
		  		set @xAcu=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (54,58))
				set @xMes=(select sum(sMes) 		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (54,58))
				set @xAcuD=(select sum(sAcumD)  	from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (54,58))
				set @xMesD=(select sum(sMesD)  		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (54,58))
			end
        if @linea=90
			begin 
		  		set @xAcu=(select sum(sAcum) 		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (80,84,86))
				set @xMes=(select sum(sMes) 		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (80,84,86))
				set @xAcuD=(select sum(sAcumD)  	from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (80,84,86))
				set @xMesD=(select sum(sMesD)  		from ##tmp_estadoganped' +@compu+ ' where EGP_LINEA in (80,84,86))
			end
		update ##tmp_estadoganped' +@compu+  ' set sAcum=@xAcu 		where 	EGP_LINEA=@linea
		update ##tmp_estadoganped' +@compu+  ' set sMes=@xMes 		where 	EGP_LINEA=@linea
		update ##tmp_estadoganped' +@compu+  ' set sAcumD=@xAcuD 	where 	EGP_LINEA=@linea
		update ##tmp_estadoganped' +@compu+  ' set sMesD=@xMesD 	where 	EGP_LINEA=@linea
 	FETCH NEXT FROM tablas INTO @linea, @tot, @formes
    END
	CLOSE tablas
	DEALLOCATE tablas
    
    set nocount off '

--PRINT (@SQLCAD+@sqlcad1)
execute(@sqlcad1)

if @acum=0
   begin
      set @sqlcad='select * from ##tmp_estadoganped' +@compu+ ' order by 2 '
      execute(@sqlcad)
   end
If @acum=1
   begin
      if @mes='01'
         begin
            IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_estadoganped1'+@compu)
               exec('DROP TABLE ##tmp_estadoganped1'+@compu)
   
               set @sqlcad='select mes='''+@mes+''' ,* into ##tmp_estadoganped1'+@compu+'
                   from  ##tmp_estadoganped' +@compu+ ''
         end
      if @mes<>'01'
         begin 
            set @sqlcad='insert ##tmp_estadoganped1'+@compu+'
               select mes='''+@mes+''' ,* from  ##tmp_estadoganped' +@compu+ ''
         end
       execute(@sqlcad)
   end
if @acum=2
   begin
      set @sqlcad=' select * from ##tmp_estadoganped1'+@compu
      execute(@sqlcad)
   end
--select * from MARFICE.DBO.CT_TMPREP_EGPF order by 2
--EXEC ct_EstadoGanPedF_rpt 'CONTAPRUEBA','2002','12','DESARROLLO3'
GO
