SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE                        proc [te_listadocheques_rpt]
@base varchar(50),
@codigo varchar(20),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='0'
as
declare @cadsql varchar(4000)
if @tipo='0' set @cadsql=' select * from ( '
If @tipo='1' set @cadsql=' select z.detrec_estadoreg ,z.cabrec_numrecibo,z.tipo ,z.numerocheque,z.detrec_fechacancela,
                                z.Codigo,z.detrec_monedacancela, z.rendicionnumero,importe=sum(z.importe) from ( '
set @cadsql=@cadsql +'
select  a.detrec_estadoreg ,a.detrec_item, a.detrec_emisioncheque,
detrec_monedacancela,
tipo = case b.cabrec_transferenciaautomatico when ''1'' then
       ''TRANSF.'' else ''EMISION'' end , 
numerocheque= case b.cabrec_transferenciaautomatico when ''1'' then 
                   a.detrec_numdocumento else a.detrec_ndqc end, 
importe= case detrec_monedacancela when ''01'' then 
         a.detrec_importesoles else a.detrec_importedolares end,
detrec_tipocajabanco,a.detrec_cajabanco1, a.detrec_numctacte,
b.cabrec_numrecibo, b.cabrec_ingsal,a.detrec_fechacancela,
a.detrec_cajabanco1+'' ''+a.detrec_numctacte as Codigo,
a.detrec_monedadocumento,a.detrec_numdocumento,
detrec_observacion,
bancodescripcion= case when a.detrec_tipocajabanco=''B'' then d.bancodescripcion else e.cajadescripcion end,
a.detrec_forcan,a.detrec_tdqc,a.detrec_ndqc,0 as SaldoInicial,f.monedasimbolo,
monedadescripcion,a.rendicionnumero,
Nombre=
   Isnull(
   	case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
       	When ''P'' then (Select Top 1 P.clienterazonsocial  from [' +@base+ '].dbo.cp_proveedor P Where P.clientecodigo=b.clientecodigo)
     	When ''C'' then (Select Top 1 Cl.clienterazonsocial  from  [' +@base+ '].dbo.vt_cliente Cl Where Cl.clientecodigo=b.clientecodigo)           
     		Else  b.cabrec_descripcion
       		End,'''') ,       
Td_Concep=
  Isnull(
  	case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
       	when ''P'' then (Select X.tdocumentodescripcion from  [' +@base+ '].dbo.cp_tipodocumento X Where X.tdocumentocodigo=A.detrec_tipodoc_concepto)
       	When ''C'' then (Select Y.tdocumentodescripcion from  [' +@base+ '].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=A.detrec_tipodoc_concepto)           
        	  	Else  (Select G.conceptodescripcion  from [' +@base+ '].dbo.te_conceptocaja G  where G.conceptocodigo=A.detrec_tipodoc_concepto)
 		End,'''')
from  	[' +@base+ '].dbo.te_detallerecibos a, 
	[' +@base+ '].dbo.te_cabecerarecibos b, 
	[' +@base+ '].dbo.te_operaciongeneral c,
	[' +@base+ '].dbo.gr_banco d,
	[' +@base+ '].dbo.te_codigocaja e,
	[' +@base+ '].dbo.gr_moneda f
where   a.cabrec_numrecibo=b.cabrec_numrecibo and 
	b.operacioncodigo=c.operacioncodigo and 
        a.detrec_tipocajabanco=''B'' and ltrim(rtrim(a.detrec_tdqc)) like  ''' +@codigo+ '''  and
---         b.cabrec_transferenciaautomatico=1 ) and
	a.detrec_cajabanco1*=d.bancocodigo and
	a.detrec_cajabanco1*=e.cajacodigo  and 
	a.detrec_monedacancela=f.monedacodigo and
	isnull(a.detalle_no_saldos,0)<>''1'' 	and
        b.cabrec_estadoreg<>1 and 
	a.detrec_fechacancela between ''' +@fechaini+ ''' and '''+@fechafin+''' '
if @tipo='0' set @cadsql=@cadsql+' ) as z order by z.detrec_cajabanco1, z.detrec_numctacte,z.NUMEROCHEQUE'
if @tipo='1'
   set @cadsql=@cadsql+' ) as z group by z.detrec_estadoreg ,z.cabrec_numrecibo,z.tipo ,z.numerocheque,z.detrec_fechacancela,
                                z.Codigo,z.detrec_monedacancela,z.rendicionnumero
       order by z.codigo, z.NUMEROCHEQUE'
execute (@cadsql)
--exec te_listadocheques_rpt 'acua_molina','59','01/01/2007','30/01/2007',1
--select * from ventas_prueba.dbo.te_detallerecibos
GO
