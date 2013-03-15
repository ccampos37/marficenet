SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute ct_libroInventariosFisicos_rpt 'ziyaz','02','2010','06','02'

*/
create proc [ct_libroInventariosFisicos_rpt]

@base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@mes varchar(2),
@puntovta varchar(2)

as
declare @sql varchar(4000)

set @sql=' SELECT al.puntovtacodigo,puntovtadescripcion, decodigo,adescri,saldoini=smsaldoini,PrecioSaldo=b.deprecio,TotalSaldo=smsaldoini*b.deprecio,CAFECDOC,canumdoc,
pedidotipofac= case when rtrim(isnull(canroped,''''))='''' then tip.sunatcodigo else 
case when doc.tdocumentosunat='''' then doc.tdocumentocodigo else doc.tdocumentosunat end end,
DOCUMENTO=MARFICE.dbo.fn_FormatoNumDoc (case when rtrim(isnull(canroped,''''))='''' then a.carfndoc else pedidonrofact end ) ,T.sunatcodigo ,catipmov,aaaa='''+@anno+''',mes=dbo.fn_DescripcionMes('+@mes+'),
PrecioIngreso=b.deprecio,ingresos= CASE WHEN CATIPMOV=''I'' THEN DECANTID ELSE 0 END,
ValIngreso=CASE WHEN CATIPMOV=''I'' THEN DECANTID*b.deprecio ELSE 0 END,
PrecioSalida=b.deprecio,SALIDAS= CASE WHEN CATIPMOV=''S'' THEN DECANTID ELSE 0 END,
ValSalida=CASE WHEN CATIPMOV=''S'' THEN DECANTID*b.deprecio ELSE 0 END,
PP.DIRECCIONCOMERCIAL,EMP.EMPRESADESCRIPCION,EMP.EMPRESARUC,Unidad=uni.sunatcodigo
FROM '+@base+'.DBO.MOVALMCAB A
INNER JOIN  '+@base+'.DBO.MOVALMDET b ON CAALMA+CATD+CANUMDOC=DEALMA+DETD+DENUMDOC
left join '+@base+'.DBO.maeart on decodigo=acodigo
left JOIN '+@base+'.DBO.tabtransa T ON CACODMOV=TT_CODMOV 
left JOIN '+@base+'.DBO.vt_pedido P ON A.empresacodigo+A.CANROPED=P.empresacodigo +P.pedidonumero  
inner join  '+@base+'.DBO.tabalm al on a.caalma=al.taalma
left join  '+@base+'.DBO.AL_MOVRESMES m on a.empresacodigo+b.decodigo+al.puntovtacodigo=m.empresacodigo+m.smcodigo+m.puntovtacodigo
left join  '+@base+'.DBO.vt_puntoventa pp on m.puntovtacodigo=pp.puntovtacodigo
LEFT JOIN  '+@base+'.DBO.cc_tipodocumento doc on p.pedidotipofac=doc.tdocumentocodigo
LEFT JOIN  '+@base+'.DBO.tipo_docu tip on a.carftdoc = tip.tdo_tipdoc
LEFT JOIN '+@base+'.DBO.CO_MULTIEMPRESAS EMP ON A.EMPRESACODIGO=EMP.EMPRESACODIGO
inner join '+@base+'.DBO.TABUNIMED uni on aunidad=uni.um_abrev
WHERE a.empresacodigo='''+@empresa+''' and YEAR(CAFECDOC)='+@anno+' AND MONTH(CAFECDOC)='+@mes +' and m.puntovtacodigo='''+@puntovta+'''
     and smmespro='''+@anno+@mes+''' AND ESTADOCOSTO=''1''  '

execute(@sql)

--			SELECT * FROM ZIYAZ.dbo.maeart 
--			execute ct_libroInventariosFisicos_rpt 'ziyaz','02','2010','06','02'
GO
