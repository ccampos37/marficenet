SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from ##jck_cajaconcil
execute xx_concilcaja 'planta_casma','03','01','25/11/2009','##jck_cajaconcil','1'
select * from acuaplayacasma.dbo.v_te_conciliacioncaja
*/
CREATE        proc [XX_concilCaja]
@Base   varchar(50), 
@caja varchar(2),
@Moneda varchar(2),
@Fecharef  varchar(10),
@filtro  varchar(50),
@tipo  varchar(1)='0'
as 
Declare @Sqlcad varchar(4000),@Sqlvar varchar(1000)
Set @Sqlcad='
select 
monto=case when '''+@moneda+''' =''01'' then a.montosol else a.montodol end,
 a.* from '+@base+'.dbo.v_te_conciliacionCaja A 
inner join '+@base+'.dbo.co_multiempresas b on a.empresacodigo=b.empresacodigo and a.detrec_cajabanco1=cajacodigo
Where detrec_tipocajabanco=''C'' and cabrec_estadoreg <> 1 
      and detrec_fechacancela <='''+@Fecharef+''' 
      and rtrim(detrec_cajabanco1)='''+@caja+'''
      and rtrim(monedacodigo)='''+@moneda+''' '
If @tipo='0' set @sqlvar= '  and isnull(chkconcil,0)<>1 '
if @tipo='1' set @sqlvar= '  and ISNULL(A.chkconcil,0)=1 '
If @filtro<>'XX'   set @Sqlvar=@sqlvar +' and cabrec_numrecibo in ( select * from '+@filtro + ')'
execute(@Sqlcad+@Sqlvar+' order by detrec_fechacancela,cabrec_ingsal,cabrec_numrecibo ')
---execute xx_concilCaja 'gremco','01','01','01/02/2008','##jck_cajaconcil','0'
GO
