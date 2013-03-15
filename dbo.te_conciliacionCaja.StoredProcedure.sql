SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute te_conciliacionCaja 'gremco','01','01','05/01/2008','##jck_cajaconcil','0'
*/
CREATE    proc [te_conciliacionCaja]
--Declare 
@Base   varchar(50), 
@caja varchar(2),
@Moneda varchar(2),
@Fecharef  varchar(10),
@filtro  varchar(50),
@tipo  varchar(1)='0'
as 
Declare @Sqlcad varchar(4000),@Sqlcad1 varchar(4000),@Sqlvar varchar(4000)
Set @Sqlcad='
select * from 
(
select 
cajadescripcion=case yy.tipocajabase when ''C'' then
                     g.cajadescripcion else h.bancodescripcion end,
empresaresumen= case yy.cabrec_transferenciaautomatico when 1 then
                     g.cajadescripcion else yy.empresadescripcion end,
yy.* from 
(
select zz.tipo,zz.chkconcil,zz.rendicionnumero,
b.cabcomprobnumero,zz.cabrec_numrecibo,
zz.detrec_fechacancela,zz.detrec_cajabanco1,b.monedacodigo,
d.monedadescripcion,b.cabrec_ingsal,
zz.detrec_tipodoc_concepto,zz.detrec_numdocumento,
tipoingreso=case  B.cabrec_ingsal when  ''I'' then
             ''INGRESOS '' else ''EGRESOS '' end,
zz.detrec_tipocajabanco,
e.centrocostonivel,e.centrocostodescripcion,
zz.empresacodigo,f.empresadescripcion ,
empresacodigodescripcion = zz.empresacodigo+'' ''+f.empresadescripcion ,
Td_Concep=Isnull(
    case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
       	when ''P'' then (Select X.tdocumentodescripcion from 
                         ['+@Base+'].dbo.cp_tipodocumento X 
                         Where X.tdocumentocodigo=zz.detrec_tipodoc_concepto
                        )
        When ''C'' then (Select Y.tdocumentodescripcion from 
                         ['+@Base+'].dbo.cc_tipodocumento Y 
                         Where Y.tdocumentocodigo=zz.detrec_tipodoc_concepto
                         )           
     else  (Select G.conceptodescripcion  from ['+@Base+'].dbo.te_conceptocaja G  
            where G.conceptocodigo=zz.detrec_tipodoc_concepto) 
     End,''''),
b.cabrec_transferenciaautomatico,b.cabrec_numreciboegreso,
tipocajabase = case b.cabrec_transferenciaautomatico when 1 then
                  (select top 1 j.detrec_tipocajabanco from 
                    ['+@Base+'].dbo.te_detallerecibos j
                    inner join ['+@Base+'].dbo.te_cabecerarecibos k 
                         on j.cabrec_numrecibo=k.cabrec_numrecibo
                    where k.cabrec_numreciboegreso=b.cabrec_numreciboegreso
                         and k.cabrec_numrecibo<>b.cabrec_numrecibo
                   )
              else zz.detrec_tipocajabanco end,
cajabase = case b.cabrec_transferenciaautomatico when 1 then
                  (select top 1 j.detrec_cajabanco1 from 
                   ['+@Base+'].dbo.te_detallerecibos j
                   inner join ['+@Base+'].dbo.te_cabecerarecibos k 
                    on j.cabrec_numrecibo=k.cabrec_numrecibo
                    where k.cabrec_numreciboegreso=b.cabrec_numreciboegreso
                     and k.cabrec_numrecibo<>b.cabrec_numrecibo
                   )
              else zz.detrec_cajabanco1 end,
ruc=Isnull( case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
       	When ''P'' then (Select Top 1 P.clienteruc  from 
                         ['+@Base+'].dbo.cp_proveedor P 
                          Where P.clientecodigo=b.clientecodigo
                        )
        When ''C'' then (Select Top 1 Cl.clienteruc  from  
                         ['+@Base+'].dbo.vt_cliente Cl 
                         Where Cl.clientecodigo=b.clientecodigo
                        )           
        Else  '''' End,''''),
ProveCliConc=Isnull(case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
       	When ''P'' then (Select Top 1 P.clienterazonsocial  
                            from ['+@Base+'].dbo.cp_proveedor P 
                            Where P.clientecodigo=b.clientecodigo
                        )
        When ''C'' then (Select Top 1 Cl.clienterazonsocial  
                          from  ['+@Base+'].dbo.vt_cliente Cl
			  Where Cl.clientecodigo=b.clientecodigo
                         )           
	Else  b.cabrec_descripcion End,''''),
zz.MONTO,zz.gastos,zz.costos,zz.provision,zz.detrec_monedacancela,
B.cabrec_estadoreg,B.cabrec_fechadocumento,zz.fechconcil,
c.gastosdescripcion,c.gastosequivalente '
Set @Sqlcad1=' from ['+@Base+'].dbo.te_cabecerarecibos  B INNER JOIN
(
select z.*,monto =isnull(z.importe/c.cargoapeimpape*d.detprovitotal,z.importe),
         gastos=d.gastoscodigo, costos=d.centrocostocodigo,
         provision=d.cabprovinumero,TIPO=''P'',w.empresacodigo
         from ['+@Base+'].dbo.te_cabecerarecibos y WITH (NOLOCK) 
         INNER join 
   ( select 
        a.cabrec_numrecibo,b.clientecodigo,a.detrec_tipodoc_concepto,
        a.detrec_numdocumento,a.detrec_tipocajabanco,a.detrec_cajabanco1,
        a.detrec_monedacancela,a.detrec_fechacancela,
        a.chkconcil,a.fechconcil,a.detrec_adicionactacte,a.rendicionnumero,
        importe=sum(a.detrec_importesoles) 
     from ['+@Base+'].dbo.te_detallerecibos a WITH (NOLOCK)
          inner join ['+@Base+'].dbo.te_cabecerarecibos b WITH (NOLOCK) 
                on a.cabrec_numrecibo=B.cabrec_numrecibo  
     where detrec_adicionactacte=''P'' and b.cabcomprobnumero = 0
           AND ISNULL(detalle_no_saldos,1)=0 AND DETREC_ESTADOREG=0
--        and b.cabrec_numrecibo=''212999'' 
           and b.cabcomprobnumero= 0 
     group by a.cabrec_numrecibo,b.clientecodigo,
           a.detrec_tipodoc_concepto,a.detrec_numdocumento,
           a.detrec_tipocajabanco,a.detrec_cajabanco1,
           a.detrec_monedacancela,a.detrec_fechacancela,
           a.chkconcil,a.fechconcil,a.detrec_adicionactacte,a.rendicionnumero
     ) as z
      on z.cabrec_numrecibo=y.cabrec_numrecibo
     left join ['+@Base+'].dbo.cp_cargo c 
           on z.clientecodigo+z.detrec_tipodoc_concepto+z.detrec_numdocumento=
              c.clientecodigo+c.documentocargo+c.cargonumdoc
     left join ['+@Base+'].dbo.co_detalleprovisiones d WITH (NOLOCK) on c.abononumplanilla=d.cabprovinumero
     left join ['+@Base+'].dbo.co_cabeceraprovisiones w WITH (NOLOCK) on d.cabprovinumero=w.cabprovinumero
union ALL
select 
   a.cabrec_numrecibo,b.clientecodigo,a.detrec_tipodoc_concepto,
   a.detrec_numdocumento,a.detrec_tipocajabanco,a.detrec_cajabanco1,
   a.detrec_monedacancela,a.detrec_fechacancela,
   a.chkconcil,a.fechconcil,a.detrec_adicionactacte,a.rendicionnumero,
   a.detrec_importesoles,
   MONTO =a.detrec_importesoles,
   gastos=a.detrec_gastos,
   costos =a.centrocostocodigo,
   provision =b.cabcomprobnumero, tipo='' '',b.empresacodigo
   from ['+@Base+'].dbo.te_detallerecibos a WITH (NOLOCK)
     inner join ['+@Base+'].dbo.te_cabecerarecibos b WITH (NOLOCK) on a.cabrec_numrecibo=B.cabrec_numrecibo
   WHERE (detrec_adicionactacte<>''P'' or 
          detrec_adicionactacte=''P''  AND b.cabcomprobnumero  >  0 ) AND
     DETREC_ESTADOREG=0 and ISNULL(detalle_no_saldos,1)=0 
---and a.cabrec_numrecibo=''212706''
) as zz
 on  zz.cabrec_numrecibo=B.cabrec_numrecibo 
 left join ['+@Base+'].dbo.co_gastos c WITH (NOLOCK) on  zz.gastos=c.gastoscodigo 
 left join ['+@Base+'].dbo.gr_moneda  d WITH (NOLOCK) on  b.monedacodigo=d.monedacodigo 
 left join ['+@Base+'].dbo.ct_centrocosto  e WITH (NOLOCK) on  zz.empresacodigo=e.empresacodigo and zz.costos=e.centrocostocodigo 
 left join ['+@Base+'].dbo.co_multiempresas f WITH (NOLOCK) on  zz.empresacodigo=f.empresacodigo 
) as yy
left join ['+@Base+'].dbo.te_codigocaja g WITH (NOLOCK) on  yy.cajabase=g.cajacodigo 
left join ['+@Base+'].dbo.gr_banco h WITH (NOLOCK) on  yy.cajabase=h.bancocodigo 
) as xx
 
Where xx.detrec_tipocajabanco=''C'' and xx.cabrec_estadoreg <> 1 
      and xx.detrec_fechacancela <='''+@Fecharef+''' 
      and rtrim(xx.detrec_cajabanco1)='''+@caja+'''
      and rtrim(xx.monedacodigo)='''+@moneda+'''  '
If @tipo='0' set @sqlvar= '  and isnull(xx.chkconcil,0)<>1 '
if @tipo='1' set @sqlvar= '  and xx.chkconcil=1 '
If @filtro<>'XX'   set @Sqlvar=@sqlvar +' and xx.cabrec_numrecibo in 
                        ( select * from '+@filtro + ')'
execute(@Sqlcad+@Sqlcad1+@Sqlvar+' order by xx.detrec_fechacancela,xx.cabrec_ingsal desc,xx.cabrec_numrecibo ')
---execute te_conciliacionCaja 'acuaplayacasma','02','01','30/09/2006','##mmjserver_cajaconcil','1'
GO
