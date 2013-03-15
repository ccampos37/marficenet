SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE               proc [te_cajabancos_rpt]
--Declare
    @base varchar(50),
    @cadcajabanco varchar(20),
    @codigo varchar(20),
    @cuenta varchar(30),
    @fechaini varchar(10),
    @fechafin varchar(10),
    @concepto varchar(20),
    @ingsal   varchar(3),
    @transfer varchar(3),
    @empresa varchar(2),
    @tipo varchar(1),
    @Resumen varchar(1)='0' 
as
declare @cadsql varchar(5000)
if @resumen='0' set @cadsql='
select x.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,
  x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
  x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.Td_Concep,
  x.detrec_numdocumento,x.monedasimbolo,x.cabrec_ingsal,x.entidad,
  soles=sum(x.detrec_importesoles), 
  dolares=sum(detrec_importedolares) '
if @resumen='1' set @cadsql='
select x.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,
  x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
  x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.monedasimbolo,x.cabrec_ingsal,
  soles=sum(x.detrec_importesoles), 
  dolares=sum(detrec_importedolares) '
set @cadsql=@cadsql + ' 
from ( select  detrec_monedacancela,f.monedadescripcion,a.detrec_importesoles,
               a.detrec_importedolares,a.detrec_cajabanco1, a.detrec_numctacte,
		b.cabrec_numrecibo,b.cabrec_ingsal,a.detrec_fechacancela,
                a.detrec_cajabanco1+a.detrec_numctacte as Codigo,
		a.detrec_monedadocumento,a.detrec_numdocumento,b.cabrec_numreciboegreso,
                entidad= case when rtrim(b.cabrec_numreciboegreso)<>'''' and 
                                   rtrim(b.cabrec_transferenciaautomatico)<>''1'' then
                              (select top 1 te.cabrec_descripcion from [' +@base+ '].dbo.te_cabecerarecibos te
                                 where  b.cabrec_numreciboegreso=te.cabrec_numreciboegreso
                                        and rtrim(b.cabrec_transferenciaautomatico)=''1'')
                          else b.cabrec_descripcion end,
		DescCajaBanco= case when a.detrec_tipocajabanco=''B'' then d.bancodescripcion else e.cajadescripcion end,
		a.detrec_forcan,tdqc=a.detrec_tdqc+'' ''+a.detrec_ndqc,
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
	where  a.detrec_cajabanco1 like ''' +@codigo+ '''  
               and a.detrec_numctacte like  ''' +@cuenta+ '''  
               and detrec_tipocajabanco like ''' +@cadcajabanco+''' 
               and detrec_tipodoc_concepto like ''' +@concepto+'''
               and b.empresacodigo like '''+@empresa+'''
               and isnull(b.cabrec_estadoreg,0)<>1 
               and isnull(detalle_no_saldos,0)<>1  '
if @tipo='0' set @cadsql=@cadsql+ ' and a.rendicionnumero>='''+@fechaini+ ''' and a.rendicionnumero<='''+@fechafin+''')'                       
if @tipo='1' set @cadsql=@cadsql+ ' and Detrec_fechacancela between ''' +@fechaini+ ''' and '''+@fechafin+''')'
set @cadsql = @cadsql + ' as X
        where x.cabrec_ingsal like '''+@ingsal+''' and  
              case when  rtrim(ltrim(isnull(x.cabrec_transferenciaautomatico,'''')))='''' 
              then ''0'' else ''1'' end 
            like  '''+@transfer+'''     '
if @resumen='0' set @cadsql=@cadsql+'
       group by x.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,
               x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
               x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.Td_Concep,
               x.detrec_numdocumento,x.monedasimbolo,x.cabrec_ingsal,x.entidad   
		order by X.codigo, X.detrec_numctacte,x.detrec_monedacancela,X.detrec_fechacancela'
if @resumen='1' set @cadsql=@cadsql+'
       group by x.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,
               x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
               x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.monedasimbolo ,x.cabrec_ingsal  
		order by X.codigo, X.detrec_numctacte,x.detrec_monedacancela,X.detrec_fechacancela'
execute(@cadsql)
--print te_cajabancos_rpt 'gremco','C','%%','%%','01/05/2008','31/05/2008','%%','%%','%%','39','1','0'
--select * from invaqplaya.dbo.te_detallerecibos
GO
