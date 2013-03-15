SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute si_consistenciadata_pro 'planta_casma','TE-AB'
execute si_consistenciadata_pro 'planta_casma','TE-CA'

*/





CREATE    procedure [si_consistenciadata_pro]

@base as varchar(50),
@tipo as varchar(5)
as

declare @sql as nvarchar(1000)

if @tipo='TE-AB'
set @sql='SELECT * FROM ['+@base+'].dbo.cp_abono a
          left join 
	( select a.cabrec_numrecibo,a.clientecodigo,b.detrec_tipodoc_concepto,b.detrec_numdocumento 
	  from ['+@base+'].dbo.te_cabecerarecibos a 
	  inner join ['+@base+'].dbo.te_detallerecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo
	  where a.cabrec_estadoreg<>1 and b.detrec_estadoreg<>1 
	 ) as z
         on a.abononumplanilla+a.abonocancli+a.documentoabono+abononumdoc=
	    Z.cabrec_numrecibo+z.clientecodigo+z.detrec_tipodoc_concepto+z.detrec_numdocumento
	where a.abonotipoplanilla=''TE'' and ISNULL(a.abonocanflreg,0)<>1 and isnull(z.cabrec_numrecibo,0)=0 '
if @tipo='TE-CA'

set @sql='SELECT * FROM 
	( select b.detrec_fechacancela,a.empresacodigo,a.cabrec_numrecibo,a.clientecodigo,b.detrec_tipodoc_concepto,b.detrec_numdocumento 
	  from ['+@base+'].dbo.te_cabecerarecibos a 
	  inner join ['+@base+'].dbo.te_detallerecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo
	  where a.cabrec_estadoreg<>1 and b.detrec_estadoreg<>1 AND b.detrec_adicionactacte=''P''
                and a.cabcomprobnumero = 0
	 ) as z
         left JOIN ['+@base+'].dbo.cp_cargo a
         on z.empresacodigo+z.clientecodigo+z.detrec_tipodoc_concepto+z.detrec_numdocumento=
	    a.EMPRESACODIGO+a.clientecodigo+a.documentocargo+cargonumdoc
	 where ISNULL(a.cargoapeflgreg,0)<>1 and isnull(a.empresacodigo,0)=0 '

EXECUTE(@sql)
/*
select z.cabrec_numrecibo from 
(select distinct cabrec_numrecibo,mes=month(cabrec_fechadocumento) 
 from te_cabecerarecibos where isnull(cabrec_estadoreg,0)<>1
) as z
full join
( select distinct cabrec_numrecibo,mes=month(detrec_fechacancela) 
 from te_detallerecibos where isnull(detrec_estadoreg,0)<>1
) as zz 
on z.cabrec_numrecibo=zz.cabrec_numrecibo and z.mes=zz.mes 
where isnull(zz.mes,0)=0 or isnull(z.mes,0)=0 order by 1

*/
GO
