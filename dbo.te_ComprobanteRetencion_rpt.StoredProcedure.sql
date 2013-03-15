SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE           proc [te_ComprobanteRetencion_rpt] 
@Base  varchar(50),
@Nrecibo  varchar(6),
@Nretencion  varchar(13),
@porcentajeretencion float=6.00
as
/*Set @Base='Ventas_Prueba'
Set @Nrecibo='100001'*/
Declare @SlqCad varchar(8000)
Set @SlqCad='
select yy.*,nuevomonto=yy.montoretencion*100/6 from
(
select zz.*,cargoapefecemi from  
(
select z.cabrec_fechadocumento,z.clientecodigo,z.ruc,z.PoveCliConc,
  z.td,z.detrec_numdocumento,z.Td_Concep,z.num_retencion,
  montoretencion =sum( case when isnull(z.detalle_no_saldos,0)=1
                 then z.detrec_importesoles  Else  0 end),
  montodocumento=sum( case when isnull(z.detalle_no_saldos,0)<> 1
                 then z.detrec_importesoles  Else  0 end)
from (
select A.cabrec_numrecibo,'''+@Nretencion+''' as num_retencion,
       A.cabrec_fechadocumento,A.monedacodigo,
       A.clientecodigo,b.detalle_no_saldos,         
       PoveCliConc=(Select P.clienterazonsocial  from ['+@Base+'].dbo.cp_proveedor P Where P.clientecodigo=A.clientecodigo),
       ruc =(Select P.clienteruc  from ['+@Base+'].dbo.cp_proveedor P Where P.clientecodigo=A.clientecodigo),
       Td=B.detrec_tipodoc_concepto,                
       Td_Concep=(Select X.tdocumentodescripcion from ['+@Base+'].dbo.cp_tipodocumento X Where X.tdocumentocodigo=B.detrec_tipodoc_concepto),
       B.detrec_numdocumento,
       B.detrec_tdqc,B.detrec_ndqc,
       detrec_cajabanco1,
       detrec_importesoles ,
       detrec_importedolares
                   
from ['+@Base+'].dbo.te_cabecerarecibos A,
     ['+@Base+'].dbo.te_detallerecibos B
Where  
    A.cabrec_numrecibo=B.cabrec_numrecibo 
    and A.cabrec_numrecibo='''+@Nrecibo+'''
) as z 
group by z.cabrec_fechadocumento,z.clientecodigo,z.ruc,z.PoveCliConc,
  z.td,z.detrec_numdocumento,z.Td_Concep,z.num_retencion 
) as zz 
inner join ['+@Base+'].dbo.cp_cargo d on zz.clientecodigo+zz.Td+zz.detrec_numdocumento=
   d.clientecodigo+d.documentocargo +d.cargonumdoc
) as yy
'
execute(@SlqCad) 
---execute te_ComprobanteRetencion_rpt 'acua_molina','401055','0030000073'
GO
