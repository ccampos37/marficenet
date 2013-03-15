SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE         proc [v_te_conciliacionCaja]
--Declare 
as 
select 
cajadescripcion=case yy.tipocajabase when 'C' then
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
tipoingreso=case  B.cabrec_ingsal when  'I' then
             'INGRESOS ' else 'EGRESOS ' end,
zz.detrec_tipocajabanco,
e.centrocostonivel,e.centrocostodescripcion,
zz.empresacodigo,f.empresadescripcion ,
empresacodigodescripcion = zz.empresacodigo+' '+f.empresadescripcion ,
Td_Concep=Isnull(
    case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),'X')) 
       	when 'P' then (Select X.tdocumentodescripcion from dbo.cp_tipodocumento X 
                        Where X.tdocumentocodigo=zz.detrec_tipodoc_concepto)
        When 'C' then (Select Y.tdocumentodescripcion from  dbo.cc_tipodocumento Y 
                        Where Y.tdocumentocodigo=zz.detrec_tipodoc_concepto)           
       	Else  (Select G.conceptodescripcion  from dbo.te_conceptocaja G  
                where G.conceptocodigo=zz.detrec_tipodoc_concepto) End,''),
b.cabrec_transferenciaautomatico,
b.cabrec_numreciboegreso,
tipocajabase = case b.cabrec_transferenciaautomatico when 1 then
                  (select top 1 j.detrec_tipocajabanco from te_detallerecibos j
                   inner join te_cabecerarecibos k 
                    on j.cabrec_numrecibo=k.cabrec_numrecibo
                    where k.cabrec_numreciboegreso=b.cabrec_numreciboegreso
                     and k.cabrec_numrecibo<>b.cabrec_numrecibo
                   )
              else zz.detrec_tipocajabanco end,
cajabase = case b.cabrec_transferenciaautomatico when 1 then
                  (select top 1 j.detrec_cajabanco1 from te_detallerecibos j
                   inner join te_cabecerarecibos k 
                    on j.cabrec_numrecibo=k.cabrec_numrecibo
                    where k.cabrec_numreciboegreso=b.cabrec_numreciboegreso
                     and k.cabrec_numrecibo<>b.cabrec_numrecibo
                   )
              else zz.detrec_cajabanco1 end,
ruc=Isnull( case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),'X')) 
       	When 'P' then (Select Top 1 P.clienteruc  from dbo.cp_proveedor P 
                        Where P.clientecodigo=b.clientecodigo)
        When 'C' then (Select Top 1 Cl.clienteruc  from  dbo.vt_cliente Cl 
                        Where Cl.clientecodigo=b.clientecodigo)           
        Else  '' End,''),
ProveCliConc=Isnull(case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),'X')) 
       	When 'P' then (Select Top 1 P.clienterazonsocial  from dbo.cp_proveedor P 
                         Where P.clientecodigo=b.clientecodigo)
        When 'C' then (Select Top 1 Cl.clienterazonsocial  from  dbo.vt_cliente Cl
			 Where Cl.clientecodigo=b.clientecodigo)           
	Else  b.cabrec_descripcion End,''),
zz.MONTO,zz.gastos,zz.costos,zz.provision,zz.detrec_monedacancela,
B.cabrec_estadoreg,B.cabrec_fechadocumento,zz.fechconcil,
c.gastosdescripcion,c.gastosequivalente 
from ##mmjserver zz  
inner join dbo.te_cabecerarecibos b on  zz.cabrec_numrecibo=B.cabrec_numrecibo 
 left join dbo.co_gastos c WITH (NOLOCK) on  zz.gastos=c.gastoscodigo 
 left join dbo.gr_moneda  d WITH (NOLOCK) on  b.monedacodigo=d.monedacodigo 
 left join dbo.ct_centrocosto  e WITH (NOLOCK) on  zz.costos=e.centrocostocodigo 
 left join dbo.co_multiempresas f WITH (NOLOCK) on  zz.empresacodigo=f.empresacodigo 
) as yy
left join dbo.te_codigocaja g WITH (NOLOCK) on  yy.cajabase=g.cajacodigo 
left join dbo.gr_banco h WITH (NOLOCK) on  yy.cajabase=h.bancocodigo
GO
