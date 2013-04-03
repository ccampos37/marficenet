/*

execute ct_pro_GeneraSunat682 'aliterm2012','01','2012',1
*/

alter proc ct_pro_GeneraSunat682
(
@base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@nivel integer
) as
declare @sql varchar(4000)
set @sql=''
if @nivel >=4
   begin
    set @sql=@sql+' select TIPO=4, cuentacodigo= left(a.cuentacodigo,5), 
	SaldoIniDEBE=ROUND(sum(saldodebe00),0) ,
	SaldoIniHABER=ROUND(sum(saldohaber00),0) ,
	MovAcumDEBE=ROUND(sum(saldoacumdebe12-saldodebe00),0) ,
	MovAcumHABER=ROUND(SUM(saldoacumhaber12-saldohaber00),0),
	SaldoFinDEBE=ROUND(sum(saldoacumdebe12),0) ,
	SaldoFinHABER=ROUND(SUM(saldoacumhaber12),0)
	from '+@base+'.dbo.ct_saldos'+@anno+ ' a
	inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo =b.empresacodigo+b.cuentacodigo 
	where A.empresacodigo='''+@empresa+''' AND  saldoacumdebe12+saldoacumhaber12<>0 
	group by   left(a.cuentacodigo,5)

	union all '
   end

if @nivel >=3
   begin
    set @sql=@SQL+' select TIPO=3, cuentacodigo= left(a.cuentacodigo,4), 
	SaldoIniDEBE=ROUND(sum(saldodebe00),0) ,
	SaldoIniHABER=ROUND(sum(saldohaber00),0) ,
	MovAcumDEBE=ROUND(sum(saldoacumdebe12-saldodebe00),0) ,
	MovAcumHABER=ROUND(SUM(saldoacumhaber12-saldohaber00),0),
	SaldoFinDEBE=ROUND(sum(saldoacumdebe12),0) ,
	SaldoFinHABER=ROUND(SUM(saldoacumhaber12),0)
	from '+@base+'.dbo.ct_saldos'+@anno+ ' a
	inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo =b.empresacodigo+b.cuentacodigo 
	where A.empresacodigo='''+@empresa+''' AND  saldoacumdebe12+saldoacumhaber12<>0 
	group by   left(a.cuentacodigo,4)

	union all '
   end
if @nivel>=2
   BEGIN
    set @sql=@sql+'select  tipo=2,cuentacodigo= left(a.cuentacodigo,3), 
	SaldoIniDEBE=ROUND(sum(saldodebe00),0) ,
	SaldoIniHABER=ROUND(sum(saldohaber00),0) ,
	MovAcumDEBE=ROUND(sum(saldoacumdebe12-saldodebe00),0) ,
	MovAcumHABER=ROUND(SUM(saldoacumhaber12-saldohaber00),0),
	SaldoFinDEBE=ROUND(sum(saldoacumdebe12),0) ,
	SaldoFinHABER=ROUND(SUM(saldoacumhaber12),0)
	from '+@base+'.dbo.ct_saldos'+@anno+ ' a
	inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo =b.empresacodigo+b.cuentacodigo 
	where A.empresacodigo='''+@empresa+''' AND  saldoacumdebe12+saldoacumhaber12<>0 
	group by   left(a.cuentacodigo,3)

	union all '
   END
if @nivel >=1
   BEGIN
    set @sql=@sql + 'select  tipo=1,cuentacodigo= left(a.cuentacodigo,2), 
	saldoinidebe=ROUND(sum(saldodebe00),0) ,
	saldoinihaber=ROUND(sum(saldohaber00),0) ,
	saldoacumdebe=ROUND(sum(saldoacumdebe12-saldodebe00),0) ,
	saldoacumhaber=ROUND(SUM(saldoacumhaber12-saldohaber00),0),
	saldodebe=ROUND(sum(saldoacumdebe12),0) ,
	saldohaber=ROUND(SUM(saldoacumhaber12),0)
	from '+@base+'.dbo.ct_saldos'+@anno+ ' a
	inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo =b.empresacodigo+b.cuentacodigo 
	where A.empresacodigo='''+@empresa+''' AND  saldoacumdebe12+saldoacumhaber12<>0 
	group by   left(a.cuentacodigo,2)
	order by 1 desc,2  '
  END
execute(@sql)

