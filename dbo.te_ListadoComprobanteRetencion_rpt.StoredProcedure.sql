SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [te_ListadoComprobanteRetencion_rpt] 
@base varchar(50),
@cadcajabanco varchar(20)='B',
@codigo varchar(20)='%',
@fechaini varchar(10),
@fechafin varchar(10)
as
/*Set @Base='Ventas_Prueba'
Set @Nrecibo='100001'*/
Declare @SlqCad varchar(8000)
Set @SlqCad='
select yy.* , nuevosaldo=yy.montoretencion*100/6 from
(
select zz.*,cargoapefecemi from  
(
select z.cabrec_fechadocumento,z.clientecodigo,z.ruc,z.PoveCliConc,
  z.td,z.detrec_numdocumento,z.Td_Concep,z.num_retencion,
  montoretencion =sum( case when isnull(z.detalle_no_saldos,0)=1
                 then z.detrec_importesoles  Else  0 end),
  montodocumento=sum( case when isnull(z.detalle_no_saldos,0)<> 1
                 then z.detrec_importesoles  Else  0 end)
from 
(
select a.cabrec_numrecibo,
num_retencion = 
case when b.detrec_tdqc =''' +@codigo+ ''' then 
         b.detrec_ndqc 
     else (select distinct detrec_ndqc from ['+@Base+'].dbo.te_detallerecibos h
            where ltrim(rtrim(detrec_tdqc)) like  ''' +@codigo+ '''and
                  b.cabrec_numrecibo=h.cabrec_numrecibo and
                  B.detrec_tipodoc_concepto=h.detrec_tipodoc_concepto and 
	          B.detrec_numdocumento=h.detrec_numdocumento and 
		  isnull(h.detrec_estadoreg,0)<>''1'') 
     end,
A.cabrec_fechadocumento,A.monedacodigo,
A.clientecodigo,b.detalle_no_saldos,         
PoveCliConc=(Select P.clienterazonsocial  from ['+@Base+'].dbo.cp_proveedor P Where P.clientecodigo=A.clientecodigo),
       ruc =(Select P.clienteruc  from ['+@Base+'].dbo.cp_proveedor P Where P.clientecodigo=A.clientecodigo),
       Td=B.detrec_tipodoc_concepto,                
       Td_Concep=(Select X.tdocumentodescripcion from ['+@Base+'].dbo.cp_tipodocumento X Where X.tdocumentocodigo=B.detrec_tipodoc_concepto),
       B.detrec_numdocumento,
       B.detrec_tdqc,B.detrec_ndqc,
       detrec_cajabanco1,
       detrec_importesoles,
       detrec_importedolares,
       detrec_estadoreg,
       detrec_fechacancela            
from ['+@Base+'].dbo.te_cabecerarecibos a
     inner join ['+@Base+'].dbo.te_detallerecibos B on A.cabrec_numrecibo=B.cabrec_numrecibo 
where b.cabrec_numrecibo in 
  (select distinct m.cabrec_numrecibo from ['+@Base+'].dbo.te_detallerecibos m
         where ltrim(rtrim(m.detrec_tdqc)) like  ''' +@codigo+ '''
               and isnull(m.detrec_estadoreg,0)<>''1'' 	
               and m.detrec_fechacancela between ''' +@fechaini+ ''' and '''+@fechafin+''')
) as z 
group by z.cabrec_fechadocumento,z.clientecodigo,z.ruc,z.PoveCliConc,
  z.td,z.detrec_numdocumento,z.Td_Concep,z.num_retencion 
) as zz 
inner join ['+@Base+'].dbo.cp_cargo d on zz.clientecodigo+zz.Td+zz.detrec_numdocumento=
   d.clientecodigo+d.documentocargo +d.cargonumdoc
) as yy
order by yy.num_retencion '
execute(@SlqCad) 
---execute te_ListadoComprobanteRetencion_rpt 'molina','%%','55','01/08/2006','11/11/2006'
GO
