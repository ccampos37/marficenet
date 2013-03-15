SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [ct_LibroInventarios_rpt] 'gremco','12','2008',12,1

select * from gremco.dbo.ct_cuenta
select * from gremco.dbo.ct_saldos2008

*/
create  Proc [ct_LibroInventariosXanalitico_rpt]
(
@Base 		varchar(50),
@empresa 	varchar(2),
@Anno 		varchar(4),
@Mes 		varchar(2),
@tipo   int=1
)
as 
 
DECLARE @sqlcad varchar(8000)
if @tipo=1
   begin
       set @sqlcad='select desc2=left(a.cuentacodigo,2)+'' - ''+c.cuentadescripcion,a.cuentacodigo,b.cuentadescripcion ,b.tipoajuste,
                   debeUssAc=case when isnull(b.tipoajuste,''00'')=''00'' then 0 else 
                                  case when saldoacumussdebe'+@mes+'- saldoacumusshaber'+@mes+' > 0 then 
                                             saldoacumussdebe'+@mes+'- saldoacumusshaber'+@mes+' else 0 end
                              end,
                   HaberUssAc=case when isnull(b.tipoajuste,''00'')=''00'' then 0 else 
                                  case when saldoacumussdebe'+@mes+'- saldoacumusshaber'+@mes+' < 0 then 
                                            abs( saldoacumussdebe'+@mes+'- saldoacumusshaber'+@mes+') else 0 end
                              end,
                    debeAC=case when saldoacumdebe'+@mes+'-saldoacumhaber'+@mes+' > 0 then saldoacumdebe'+@mes+'-saldoacumhaber'+@mes+' else 0 end,
                    HaberAC=case when saldoacumdebe'+@mes+'- saldoacumhaber'+@mes+' < 0 then saldoacumhaber'+@mes+'-saldoacumdebe'+@mes+' else 0 end
             from '+@base+'.dbo.ct_saldos'+@anno+' a 
             inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo 
             inner join '+@base+'.dbo.ct_cuenta c on a.empresacodigo+left(a.cuentacodigo,2)=c.empresacodigo+c.cuentacodigo 
              where a.empresacodigo='''+@empresa+''' and  saldoacumdebe'+@mes+'- saldoacumhaber'+@mes+' <> 0 '
  end
execute (@sqlcad)
GO
