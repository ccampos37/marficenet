SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

select * from ##tmpctasjck

execute ct_Cuentas_VS_Analiticos_rpt 'planta_casma','01','2012',6,'##jck',5,1

*/

ALTER  procedure [ct_Cuentas_VS_Analiticos_rpt]
@base  varchar(50),
@empresa varchar(2),
@Anno varchar(4),
@mes integer ,
@computer varchar(50),
@Nivel char(1),
@tipo integer=0

as

Declare @sqlcad nvarchar(4000)
declare @sqlcad1 nvarchar(4000)
declare @n as integer , @nn as char(2)
set @sqlcad='If Exists(Select name from tempdb..sysobjects where name=''##tmpctas'+@computer+''') 
    Drop Table [##tmpctas'+@computer+'] 
    select top 0 empresacodigo,cuentacodigo,cabcomprobmes=space(15),tipo=space(12),debehaber=space(10),
    IMPORTE=saldohaber00 ,importe1=saldohaber00
    into [##tmpctas'+@computer+'] from ['+@base+'].dbo.ct_saldos'+@anno+''

execute(@sqlcad)

set @sqlcad=' insert [##tmpctas'+@computer+']
    select empresacodigo,left(cuentacodigo,'+@nivel+'),''00 S.Inicial'',''Cuenta'',''DEBE'',
    sum(saldodebe00),1 from ['+@base+'].dbo.ct_saldos'+@anno+' 
    where empresacodigo='''+@empresa+''' and saldodebe00> 0 
    group by empresacodigo,cuentacodigo

   insert [##tmpctas'+@computer+']
    select empresacodigo,left(cuentacodigo,'+@nivel+'),''00 S.Inicial'',''Cuenta'',''HABER'',
       sum(saldodebe00),1 from ['+@base+'].dbo.ct_saldos'+@anno+' 
       where empresacodigo='''+@empresa+''' and saldohaber00 > 0 
       group by empresacodigo,cuentacodigo

   insert [##tmpctas'+@computer+']
   select empresacodigo,left(cuentacodigo,'+@nivel+'),''00 S.Inicial'',''Analit'',''DEBE'',
          case when sum(ctacteanaliticodebe)- sum(ctacteanaliticohaber) > 0 then 
                    sum(ctacteanaliticodebe)- sum(ctacteanaliticohaber) else 0 end,-1
   from ['+@base+'].dbo.ct_ctacteanalitico'+@anno+' 
   where empresacodigo='''+@empresa+''' and cabcomprobmes=0
   group by empresacodigo,cuentacodigo 

   insert [##tmpctas'+@computer+']
   select empresacodigo,left(cuentacodigo,'+@nivel+'),''00 S.Inicial'',''Analit'',''HABER'',
        case when sum(ctacteanaliticohaber)- sum(ctacteanaliticodebe) > 0 then 
                    sum(ctacteanaliticohaber)- sum(ctacteanaliticodebe) else 0 end, -1
   from ['+@base+'].dbo.ct_ctacteanalitico'+@anno+' 
   where empresacodigo='''+@empresa+'''  and cabcomprobmes=0
   group by empresacodigo,cuentacodigo ' 

execute( @sqlcad)

set @n=1
while @n<=@mes
  begin
     set @nn=right('00'+rtrim(ltrim(@n)),2)
     set @sqlcad=' insert [##tmpctas'+@computer+']
                   select empresacodigo,left(cuentacodigo,'+@nivel+'),'''+@nn+'''+'' ''+dbo.fn_descripcionmes('+@nn+'),
                         ''cuenta'',''DEBE'',sum(SALDODEBE'+@nn+'),1
                         from ['+@base+'].dbo.ct_saldos'+@anno+' 
                          where (SALDODEBE'+@nn+')> 0 AND  empresacodigo='''+@empresa+''' 
                         group by empresacodigo,cuentacodigo
                   insert [##tmpctas'+@computer+']
                   select empresacodigo,left(cuentacodigo,'+@nivel+'),'''+@nn+'''+'' ''+dbo.fn_descripcionmes('+@nn+'),
                         ''cuenta'',''HABER'',sum(saldohaber'+@nn+'),1
                         from ['+@base+'].dbo.ct_saldos'+@anno+' 
                          where (saldohaber'+@nn+') > 0 AND  empresacodigo='''+@empresa+''' 
                         group by empresacodigo,cuentacodigo

                   insert [##tmpctas'+@computer+']
                   select empresacodigo,left(cuentacodigo,'+@nivel+'),'''+@nn+'''+'' ''+dbo.fn_descripcionmes('+@nn+'),
                        ''analit'',''DEBE'', sum(ctacteanaliticodebe),-1
                         from ['+@base+'].dbo.ct_ctacteanalitico'+@anno+' 
                         where (ctacteanaliticodebe) > 0 and cabcomprobmes='+@nn+' and 
                         empresacodigo='''+@empresa+''' 
                         group by empresacodigo,cuentacodigo
                   insert [##tmpctas'+@computer+']
                   select empresacodigo,left(cuentacodigo,'+@nivel+'),'''+@nn+'''+'' ''+dbo.fn_descripcionmes('+@nn+'),
                        ''analit'',''HABER'', sum(ctacteanaliticohaber),-1
                         from ['+@base+'].dbo.ct_ctacteanalitico'+@anno+' 
                         where (ctacteanaliticohaber) > 0 and cabcomprobmes='+@nn+' and  
                         empresacodigo='''+@empresa+''' 
                         group by empresacodigo,cuentacodigo'     
     execute (@sqlcad)
     set @n=@n+1
     IF @n > @mes 
        BREAK
      ELSE
        CONTINUE
  end
set @sqlcad1 =' update [##tmpctas'+@computer+'] set importe1=importe*importe1 '

set @sqlcad=' select descripcion=b.cuentacodigo+''  ''+b.cuentadescripcion,a.* 
    from [##tmpctas'+@computer+'] a inner join  ['+@base+'].dbo.ct_cuenta b
         on a.empresacodigo=b.empresacodigo and a.cuentacodigo=b.cuentacodigo
    where b.cuentaestadoanalitico =1  '

If @tipo=1  set @sqlcad=@sqlcad1+@sqlcad+' and a.cuentacodigo in ( select cuentacodigo 
                         from [##tmpctas'+@computer+'] group by cuentacodigo 
                         having sum(importe1)<>0 ) '
execute(@sqlcad)     

SET QUOTED_IDENTIFIER OFF
