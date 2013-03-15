SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [ct_ResumenMovimientosCuentas_V] (
@base 	as varchar(30),
@anno 	as varchar(4),
@cuenta 	as varchar(2000),
@numdig 	as int )
as
Declare @cadsql as varchar(5000)
set @cadsql='
select YY.* from 
(select Cod2=left(ZZ.cuentacodigo,2),ZZ.cuentacodigo,Nmes=cabcomprobmes,Mes=case ZZ.cabcomprobmes
	when 1 then ''Enero'' 
	when 2 then ''Febrero''
	when 3 then ''Marzo''
	when 4 then ''Abril''
	when 5 then ''Mayo''
	when 6 then ''Junio''
	when 7 then ''Julio''
	when 8 then ''Agosto''
	when 9 then ''Setiembre''
	when 10 then ''Octubre''
	when 11 then ''Noviembre''
	when 12 then ''Diciembre''
	end,
ZZ.Valor  from 
(select cuentacodigo,cabcomprobmes,Valor=(sum(detcomprobdebe)-sum(detcomprobhaber))
from [' +@base+ '].dbo.ct_detcomprob' +@anno+ ' B
where left(B.cuentacodigo,' +cast(@numdig as varchar(2))+ ') in ' +@cuenta+ ' and len(B.cuentacodigo)=6
group by cuentacodigo,cabcomprobmes) as ZZ ) as YY
order by 2,3'
print(@cadsql)
--exec ct_ResumenMovimientosCuentas_V 'Prueba_Contaprueba_Sanil','2002','(''94'',''95'',''97'',''75'',''76'',''77'')',2
--exec ct_ResumenMovimientosCuentas_V 'Contaprueba','2002','(''101101'')',6
GO
