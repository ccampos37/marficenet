SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec [te_Ctasxrendir_rpt] 'aliterm2011','01','004778'

*/

CREATE  proc [te_Ctasxrendir_rpt]
--Declare
    @base varchar(50),
    @empresa varchar(2)='01',
	@rendicionNro varchar(20)
as
declare @cadsql varchar(5000)
set @cadsql=' select numerodocxrendir,  detrec_monedacancela,f.monedadescripcion,soles=a.detrec_importesoles,dolares=a.detrec_importedolares,
    a.detrec_cajabanco1, a.detrec_numctacte,b.cabrec_numrecibo,b.cabrec_ingsal,a.detrec_fechacancela,a.detrec_cajabanco1+a.detrec_numctacte as Codigo,
    a.detrec_monedadocumento,a.detrec_numdocumento,b.cabrec_numreciboegreso,
    clientCode= case when rtrim(b.cabrec_numreciboegreso)<>'''' and rtrim(b.cabrec_transferenciaautomatico)<>''1'' then
                              (select top 1 te.clientecodigo from [' +@base+ '].dbo.te_cabecerarecibos te
                                 where  b.cabrec_numreciboegreso=te.cabrec_numreciboegreso
                                        and rtrim(b.cabrec_transferenciaautomatico)=''1'')
                          else b.clientecodigo end,		
	entidad= case when rtrim(b.cabrec_numreciboegreso)<>'''' and rtrim(b.cabrec_transferenciaautomatico)<>''1'' then
                              (select top 1 te.cabrec_descripcion from [' +@base+ '].dbo.te_cabecerarecibos te
                                 where  b.cabrec_numreciboegreso=te.cabrec_numreciboegreso
                                        and rtrim(b.cabrec_transferenciaautomatico)=''1'')
                          else b.cabrec_descripcion end,
	DescCajaBanco= case when a.detrec_tipocajabanco=''B'' then d.bancodescripcion else e.cajadescripcion end,
	a.detrec_forcan,tdqc=a.detrec_tdqc+'' - ''+a.detrec_ndqc,
	0 as SaldoInicial, g.empresadescripcion,f.monedasimbolo,
  	ProveCliConc= Isnull(
     			case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          	              When ''P'' then (Select Top 1 P.clienterazonsocial  from [' +@base+ '].dbo.cp_proveedor P Where P.clientecodigo=b.clientecodigo)
        	  	      When ''C'' then (Select Top 1 Cl.clienterazonsocial  from  [' +@base+ '].dbo.vt_cliente Cl Where Cl.clientecodigo=b.clientecodigo)           
        		      Else  b.cabrec_descripcion
       		              End,'''') ,       
  	Td_Concep= Isnull(
		   	case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
	       	              when ''P'' then (Select X.tdocumentodescripcion from  [' +@base+ '].dbo.cp_tipodocumento X Where X.tdocumentocodigo=A.detrec_tipodoc_concepto)
	        	      When ''C'' then (Select Y.tdocumentodescripcion from  [' +@base+ '].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=A.detrec_tipodoc_concepto)           
        	  	      Else  (Select G.conceptodescripcion  from [' +@base+ '].dbo.te_conceptocaja G  where G.conceptocodigo=A.detrec_tipodoc_concepto)
       		              End,''''),
                b.cabrec_transferenciaautomatico
	from  [' +@base+ '].dbo.te_detallerecibos a
	  inner join [' +@base+ '].dbo.te_cabecerarecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo 
	  left join [' +@base+ '].dbo.te_operaciongeneral c on b.operacioncodigo=c.operacioncodigo  
	  left join [' +@base+ '].dbo.gr_banco d on a.detrec_cajabanco1=d.bancocodigo 
          left join [' +@base+ '].dbo.te_codigocaja e on a.detrec_cajabanco1=e.cajacodigo  
          inner join [' +@base+ '].dbo.gr_moneda f on a.detrec_monedacancela=f.monedacodigo 
          left join [' +@base+ '].dbo.co_multiempresas g on b.empresacodigo=g.empresacodigo
	where  b.empresacodigo ='''+@empresa+''' and numerodocxrendir like '''+@rendicionNro  +''' and  numerodocxrendir <> '''' and  
           detrec_tipocajabanco =''C'' and isnull(b.cabrec_estadoreg,0)<>1 and isnull(detalle_no_saldos,0)<>1 
                       '
execute(@cadsql)
-- select * from aliterm2012.dbo.te_cabecerarecibos
GO
