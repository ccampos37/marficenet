SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [ct_LibroInventarios_rpt] 'gremco','12','2008','12','2'

select * from gremco.dbo.ct_cuenta
select * from gremco.dbo.ct_saldos2008

*/
create  Proc [ct_LibroInventarios_rpt]
(
@Base 		varchar(50),
@empresa 	varchar(2),
@Anno 		varchar(4),
@Mes 		varchar(2),
@tipo   char(1))
as 
 
DECLARE @sqlcad varchar(8000)
       set @sqlcad='select tipo=1,desc2=left(a.cuentacodigo,2)+'' - ''+c.cuentadescripcion,a.cuentacodigo,b.cuentadescripcion ,b.tipoajuste,
                    analitico=space(15), razonsocial=space(40),
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
             where a.empresacodigo='''+@empresa+''' and  saldoacumdebe'+@mes+'- saldoacumhaber'+@mes+' <> 0 and left(a.cuentacodigo,2)<=''59''  '

if @tipo='2'
    begin
       set @sqlcad=@sqlcAD+'and b.cuentaestadoanalitico=0 
                     union all
                   select tipo=2,desc2=left(a.cuentacodigo,2)+'' - ''+c.cuentadescripcion , a.cuentacodigo,b.cuentadescripcion ,b.tipoajuste,
                           d.entidadcodigo,d.entidadrazonsocial ,
                            debeUssAc=case when isnull(b.tipoajuste,''00'')=''00'' then 0 else 
                                            case when sum(ctacteanaliticoUssdebe - ctacteanaliticoUssHaber ) > 0 then 
                                                  sum(ctacteanaliticoUssdebe - ctacteanaliticoUssHaber ) else 0 end
                                       end,
                            HaberUssAc=case when isnull(b.tipoajuste,''00'')=''00'' then 0 else 
                                            case when sum(ctacteanaliticoUssdebe - ctacteanaliticoUssHaber ) < 0 then 
                                            abs( sum(ctacteanaliticoUssdebe - ctacteanaliticoUssHaber ) ) else 0 end
                                        end,
                            debeAC=case when sum(ctacteanaliticodebe - ctacteanaliticoHaber ) > 0 then 
                                             sum(ctacteanaliticodebe - ctacteanaliticoHaber ) else 0 end,
                            HaberAC=case when sum(ctacteanaliticodebe - ctacteanaliticoHaber ) < 0 then 
                                              abs ( sum(ctacteanaliticodebe - ctacteanaliticoHaber ) ) else 0 end
                     from '+@base+'.dbo.ct_ctacteanalitico'+@anno+' a 
                     inner join '+@base+'.dbo.ct_cuenta b on a.empresacodigo+a.cuentacodigo=b.empresacodigo+b.cuentacodigo 
                     inner join '+@base+'.dbo.ct_cuenta c on a.empresacodigo+left(a.cuentacodigo,2)=c.empresacodigo+c.cuentacodigo 
                     left join '+@base+'.dbo.v_analiticoentidad d on a.analiticocodigo=d.analiticocodigo
                     where a.empresacodigo='''+@empresa+''' and b.cuentaestadoanalitico=1 and cabcomprobmes<='+@mes+' and left(a.cuentacodigo,2)<=''59''
                     group by  c.cuentadescripcion,a.cuentacodigo,b.cuentadescripcion ,b.tipoajuste,d.entidadcodigo,d.entidadrazonsocial 
                     having  sum(ctacteanaliticodebe - ctacteanaliticoHaber ) <> 0    '

   end
execute(@sqlcad)

/****** Object:  StoredProcedure [dbo].[ct_LibroInventariosXanalitico_rpt]    Script Date: 02/18/2011 18:17:27 ******/
SET ANSI_NULLS ON
GO
