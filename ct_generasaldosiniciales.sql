SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop procedure ct_GenerarSaldoIniciales_pro
execute ct_GenerarSaldoIniciales_pro 'aliterm2012','01','2013','2012','5','5911100'
*/
ALTER                procedure [ct_GenerarSaldoIniciales_pro]
(
	
	@base			varchar(50),
	@empresa 		varchar(2),	
	@annoact		varchar(4),
	@annoant		varchar(4),
   	@ultnivel		varchar(1),
	@CuentaResEjer		varchar(10)='5911000'
	
)
as
Declare @cadsql varchar(3000)
set @cadsql='
	insert [' +@base+ '].dbo.ct_saldos' +@annoact+ ' (empresacodigo,cuentacodigo,usuariocodigo,fechaact)
		select empresacodigo,cuentacodigo,usuariocodigo,fechaact from [' +@base+ '].dbo.ct_cuenta 
			where empresacodigo+cuentacodigo not in (select empresacodigo+cuentacodigo from [' +@base+ '].dbo.ct_saldos' +@annoact+ ')
			      and empresacodigo='''+@empresa+''' '
Execute(@cadsql)

set @cadsql='
update [' +@base+ '].dbo.ct_saldos' +@annoact+'
      set saldodebe00=0, saldohaber00=0 , saldoussdebe00=0 , saldousshaber00=0
      WHERE empresacodigo='''+@empresa+'''

update [' +@base+ '].dbo.ct_saldos' +@annoact+'
	set saldodebe00=case when b.saldoacumdebe12-b.saldoacumhaber12>0 then  abs(b.saldoacumdebe12-b.saldoacumhaber12) else 0 end,
		 saldohaber00=case when b.saldoacumdebe12-b.saldoacumhaber12<0 then abs(b.saldoacumdebe12-b.saldoacumhaber12) else 0 end
		,saldoussdebe00=case when b.saldoacumussdebe12-b.saldoacumusshaber12>0 then abs(b.saldoacumussdebe12-b.saldoacumusshaber12) else 0 end,
		 saldousshaber00=case when b.saldoacumussdebe12-b.saldoacumusshaber12<0 then abs(b.saldoacumussdebe12-b.saldoacumusshaber12) else 0 end
from [' +@base+ '].dbo.ct_saldos' +@annoact+' a, ['+@base+'].dbo.ct_saldos' +@annoant+ ' b
where A.empresacodigo =''' +@empresa+  ''' and
	a.empresacodigo=b.empresacodigo and a.cuentacodigo=b.cuentacodigo and left(a.cuentacodigo,2)<=''59'''

Execute(@cadsql)

--Generando resultados de ejercicio		
set @cadsql='
Update [' +@base+ '].dbo.ct_saldos' +@annoact+'
	set saldodebe00=saldodebe00+b.SaldoDebe, saldohaber00=saldohaber00+b.SaldoHaber,
       saldoussdebe00=saldoussdebe00+b.SaldoUssDebe,saldousshaber00=saldousshaber00+b.SaldoUssHaber
From  [' +@base+ '].dbo.ct_saldos' +@annoact+' a,
(Select a.empresacodigo,a.cuentacodigo,
	Saldodebe=Case When Sum(a.Debe)-Sum(a.Haber)<0 Then Sum(a.Haber)-Sum(a.Debe) Else 0 End,
	Saldohaber=Case When Sum(a.Debe)-Sum(a.Haber)>0 Then Sum(a.Debe)-Sum(a.Haber) Else 0 End,
	SaldoUssdebe=Case When Sum(a.DDebe)-Sum(a.DHaber)<0 Then Sum(a.DHaber)-Sum(a.DDebe) Else 0 End,
	SaldoUsshaber=Case When Sum(a.DDebe)-Sum(a.DHaber)>0 Then Sum(a.DDebe)-Sum(a.DHaber) Else 0 End
From (
Select empresacodigo,cuentacodigo='''+@CuentaResEjer+''',
	Debe=Case When sum(saldoacumdebe12-saldoacumhaber12)>0 Then sum(saldoacumdebe12-saldoacumhaber12) Else 0 End,
	Haber=Case When sum(saldoacumdebe12-saldoacumhaber12)<0 Then sum(saldoacumhaber12-saldoacumdebe12) Else 0 End,
	DDebe=Case When sum(saldoacumussdebe12-saldoacumusshaber12)>0 Then sum(saldoacumussdebe12-saldoacumusshaber12) Else 0 End,
	DHaber=Case When sum(saldoacumussdebe12-saldoacumusshaber12)<0 Then sum(saldoacumusshaber12-saldoacumussdebe12) Else 0 End
From [' +@base+ '].dbo.ct_saldos' +@annoant+ ' 
Where empresacodigo=''' +@empresa+  ''' And Left(cuentacodigo,2) Between ''10'' And ''59'' And cuentacodigo<>'''+@CuentaResEjer+'''
Group by empresacodigo
Union all
Select empresacodigo,cuentacodigo,
	Debe=Case When saldoacumdebe12-saldoacumhaber12>0 Then saldoacumdebe12-saldoacumhaber12 Else 0 End,
	Haber=Case When saldoacumdebe12-saldoacumhaber12<0 Then saldoacumhaber12-saldoacumdebe12 Else 0 End,
	DDebe=Case When saldoacumussdebe12-saldoacumusshaber12>0 Then saldoacumussdebe12-saldoacumusshaber12 Else 0 End,
	DHaber=Case When saldoacumussdebe12-saldoacumusshaber12<0 Then saldoacumusshaber12-saldoacumussdebe12 Else 0 End
From [' +@base+ '].dbo.ct_saldos' +@annoant+ '
Where empresacodigo=''' +@empresa+  ''' And Left(cuentacodigo,2) Between ''10'' And ''59'' And  cuentacodigo='''+@CuentaResEjer+'''    ) a
group by a.empresacodigo, a.cuentacodigo ) b
where A.empresacodigo = ''' +@empresa+  ''' and a.empresacodigo=b.empresacodigo and a.cuentacodigo=b.cuentacodigo '

execute(@cadsql)

--exec ct_GenerarSaldoIniciales_pro 'contaprueba','2003','2002','6'
