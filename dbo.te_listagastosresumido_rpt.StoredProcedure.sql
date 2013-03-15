SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--drop      proc te_listagastosresumido_rpt
--ALTER      proc te_listagastosresumido_rpt
CREATE      proc [te_listagastosresumido_rpt]
--Declare
@base varchar(50),
@cadcajabanco varchar(20),
@codigo varchar(20),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='C',    
@ingsal varchar(1)='E'
as
declare @cadsql varchar(4000)
set @cadsql='select x.detrec_gastos,x.gastosdescripcion,
   soles=sum(x.detrec_importesoles),
   dolares=sum(x.detrec_importedolares) from ( 
   select detrec_gastos=left(rtrim(detrec_gastos),4),g.gastosdescripcion,
        a.detrec_item, a.detrec_emisioncheque,detrec_monedacancela,
        a.detrec_importesoles,a.detrec_importedolares, 
        detrec_tipocajabanco,a.detrec_cajabanco1, a.detrec_numctacte,
	b.cabrec_numrecibo, b.cabrec_ingsal,a.detrec_fechacancela,
	a.detrec_cajabanco1+a.detrec_numctacte as Codigo,
	a.detrec_monedadocumento,
	a.detrec_numdocumento,
	DescCajaBanco= case when a.detrec_tipocajabanco=''B'' then d.bancodescripcion else e.cajadescripcion end,
	a.detrec_forcan,
	a.detrec_tdqc,
	a.detrec_ndqc,
	0 as SaldoInicial,
        f.monedasimbolo,
  	ProveCliConc=Isnull(
     		case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          	When ''P'' then (Select Top 1 P.clienterazonsocial  from [' +@base+ '].dbo.cp_proveedor P Where P.clientecodigo=b.clientecodigo)
        	  	When ''C'' then (Select Top 1 Cl.clienterazonsocial  from  [' +@base+ '].dbo.vt_cliente Cl Where Cl.clientecodigo=b.clientecodigo)           
        		Else  b.cabrec_descripcion
       		End,'''') ,       
  	Td_Concep=
	      Isnull(
		   	case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
	       	when ''P'' then (Select X.tdocumentodescripcion from  [' +@base+ '].dbo.cp_tipodocumento X Where X.tdocumentocodigo=A.detrec_tipodoc_concepto)
	        	When ''C'' then (Select Y.tdocumentodescripcion from  [' +@base+ '].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=A.detrec_tipodoc_concepto)           
        	  	Else  (Select G.conceptodescripcion  from [' +@base+ '].dbo.te_conceptocaja G  where G.conceptocodigo=A.detrec_tipodoc_concepto)
       		End,''''),b.cabrec_transferenciaautomatico
		from  [' +@base+ '].dbo.te_detallerecibos a
		  inner join [' +@base+ '].dbo.te_cabecerarecibos b
                      on a.cabrec_numrecibo=b.cabrec_numrecibo 
		  inner join [' +@base+ '].dbo.te_operaciongeneral c
                      on b.operacioncodigo=c.operacioncodigo  
		  left join [' +@base+ '].dbo.gr_banco d
                      on a.detrec_cajabanco1=d.bancocodigo 
                  left join [' +@base+ '].dbo.te_codigocaja e
                      on a.detrec_cajabanco1=e.cajacodigo  
                  inner join [' +@base+ '].dbo.gr_moneda f
                      on a.detrec_monedacancela=f.monedacodigo 
                  inner join [' +@base+ '].dbo.co_gastos g
                      on detrec_gastos=g.gastoscodigo 
	where  a.detrec_cajabanco1 like ''' +@cadcajabanco+ ''' 
               and detrec_gastos like ''' +@codigo+''' 
               and isnull(b.cabrec_estadoreg,0)<>1 
               and isnull(detalle_no_saldos,0)<>1
               and isnull(cabrec_transferenciaautomatico,0)<>1
               and a.detrec_fechacancela between ''' +@fechaini+ ''' 
               and '''+@fechafin+'''
   )as  X
        where x.cabrec_ingsal like '''+@ingsal+''' 
        group by x.detrec_gastos,x.gastosdescripcion order by detrec_gastos '
execute (@cadsql)
--execute te_listagastosresumido_rpt 'edbtemplate','%%','%%','01/01/2006','25/08/2006'
--select * from invaqplaya.dbo.te_detallerecibos
GO
