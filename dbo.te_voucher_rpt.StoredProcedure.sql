SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Drop proc [dbo].[te_voucher_rpt] 

exec te_voucher_rpt 'gremco','208869'
*/

CREATE                            proc [te_voucher_rpt] 
@Base  varchar(50),
@Nrecibo  varchar(6)
as
Declare @SlqCad varchar(8000)
Set @SlqCad='
select d.empresadescripcion,A.cabrec_numrecibo,A.operacioncodigo,
       A.cabrec_ingsal,b.detrec_observacion,
       C.operaciondescripcion,A.cajacodigo,
       C.operacioncontrolaclienteprov,C.operacionvalidacajabancos,       
       cajadescripcion=Isnull((Select D.cajadescripcion from ['+@Base+'].dbo.te_codigocaja D  where 
       D.cajacodigo=A.cajacodigo),''''), 
       A.cabrec_fechadocumento,A.monedacodigo,
       A.cabrec_tipocambio,
       A.clientecodigo,         
       PoveCliConc=
       Isnull(
       case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          when ''P'' then (Select P.clienterazonsocial  from ['+@Base+'].dbo.cp_proveedor P Where P.clientecodigo=A.clientecodigo)
          When ''C'' then (Select Cl.clienterazonsocial  from ['+@Base+'].dbo.vt_cliente Cl Where Cl.clientecodigo=A.clientecodigo)           
          Else  A.cabrec_descripcion
       End,'''') ,
       Td=B.detrec_tipodoc_concepto,                
       Td_Concep=
       Isnull(
       case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          when ''P'' then (Select X.tdocumentodescripcion from ['+@Base+'].dbo.cp_tipodocumento X Where X.tdocumentocodigo=B.detrec_tipodoc_concepto)
          When ''C'' then (Select Y.tdocumentodescripcion from ['+@Base+'].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=B.detrec_tipodoc_concepto)           
          Else  (Select G.conceptodescripcion  from ['+@Base+'].dbo.te_conceptocaja G  where G.conceptocodigo=B.detrec_tipodoc_concepto)
       End,''''),
		 DescTdc=
		 Isnull(
       case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          when ''P'' then (Select X.tdocumentodescripcion from ['+@Base+'].dbo.cp_tipodocumento X Where X.tdocumentocodigo=B.detrec_tdqc)
          When ''C'' then (Select Y.tdocumentodescripcion from ['+@Base+'].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=B.detrec_tdqc)           
          Else  (Select G.conceptodescripcion  from ['+@Base+'].dbo.te_conceptocaja G  where G.conceptocodigo=B.detrec_tdqc)
       End,''''),
       B.detrec_numdocumento,FormaPag=B.detrec_forcan,
       B.detrec_tdqc,
       detrec_ndqc= case a.cabrec_transferenciaautomatico when ''1'' then 
                   b.detrec_numdocumento else b.detrec_ndqc end,
       detrec_cajabanco1,
       DescrBanco=
       Isnull(        
       Case When B.detrec_tipocajabanco=''B'' 
       Then (Select BA.bancodescrcorta   from ['+@Base+'].dbo.gr_banco BA Where  BA.bancocodigo=B.detrec_cajabanco1 )
       Else '''' end,''''),
       CtaCteBanco=B.detrec_numctacte,
       comprobconta=a.cabcomprobnumero,
       detrec_monedacancela,
       detrec_monedadocumento,
       cabrec_observacion1,
       detrec_importesoles,
       detrec_importedolares,cabrec_estadoreg
                   
from ['+@Base+'].dbo.te_cabecerarecibos A
     inner join ['+@Base+'].dbo.te_detallerecibos B on      A.cabrec_numrecibo=B.cabrec_numrecibo 
     left join ['+@Base+'].dbo.te_operaciongeneral C on     A.operacioncodigo=C.operacioncodigo 
     left join ['+@Base+'].dbo.co_multiempresas d on a.empresacodigo=d.empresacodigo
Where isnull(b.detalle_no_saldos,0)<>''1''   
     and A.cabrec_numrecibo='''+@Nrecibo+''''
execute(@SlqCad) 
--execute  te_voucher_rpt  'gremco','100007'



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
