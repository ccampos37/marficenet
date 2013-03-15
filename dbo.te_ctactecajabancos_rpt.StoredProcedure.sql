SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute te_ctactecajabancos_rpt 'acualima08','C','%%','%%','01/02/2008','29/02/2008','01'

*/




CREATE                    proc [te_ctactecajabancos_rpt]
--Declare
    @base varchar(50),
    @cadcajabanco varchar(20),
    @codigo varchar(20),
    @cuenta varchar(30),
    @fechaini varchar(10),
    @fechafin varchar(10),
    @empresa varchar(2),
    @concepto varchar(20)='%%',
    @ingsal   varchar(3)='%%',
    @transfer varchar(3)='%%' 
as
 --1:Caja  2:Banco  
/*set @base='ventas_prueba'
set @codigo='%'
set @cuenta='%%'
set @cadcajabanco='%%'
set @fechaini='01/03/2003'
set @fechafin='25/03/2003'
set @concepto='%%'
set @ingsal='%%'
set @transfer='%%'*/
declare @cadsql varchar(5000)
set @cadsql='
        select h.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,saldoinicial=isnull(g.saldoinicial,0),
               x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
               x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.Td_Concep,
               x.detrec_numdocumento,x.monedasimbolo,x.cabrec_ingsal,
               soles=sum(x.detrec_importesoles), 
               dolares=sum(detrec_importedolares)
               from ( 
		select  b.empresacodigo,detrec_monedacancela,
                aaaamm=str(year(a.detrec_fechacancela),4)+
                right(''00''+ltrim(str(month(a.detrec_fechacancela),2)),2),
                a.detrec_importesoles,
		a.detrec_importedolares, 
                a.detrec_cajabanco1, a.detrec_numctacte,
		b.cabrec_numrecibo,b.cabrec_ingsal,a.detrec_fechacancela,
		Codigo= Case when a.detrec_tipoCajaBanco=''B'' then
                             a.detrec_cajabanco1+a.detrec_numctacte 
                          else a.detrec_Cajabanco1+a.detrec_monedacancela  end,
		a.detrec_monedadocumento,f.monedadescripcion,
		a.detrec_numdocumento,b.cabrec_numreciboegreso,
		DescCajaBanco= case when a.detrec_tipocajabanco=''B'' then d.bancodescripcion else e.cajadescripcion end,
		a.detrec_forcan,
		tdqc=a.detrec_tdqc+'' ''+a.detrec_ndqc,
		0 as SaldoInicial,
      f.monedasimbolo,
  		ProveCliConc=
       	Isnull(
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
		  left join [' +@base+ '].dbo.gr_banco d
                      on a.detrec_cajabanco1=d.bancocodigo 
                  left join [' +@base+ '].dbo.te_codigocaja e
                      on a.detrec_cajabanco1=e.cajacodigo  
                  inner join [' +@base+ '].dbo.gr_moneda f
                      on a.detrec_monedacancela=f.monedacodigo 
                where  b.empresacodigo like '''+@empresa +''' 
		       and a.detrec_cajabanco1 like ''' +@codigo+ '''  
                       and a.detrec_numctacte like  ''' +@cuenta+ '''  
                       and detrec_tipocajabanco like ''' +@cadcajabanco+''' 
                       and isnull(b.cabrec_estadoreg,0)<>1 
                       and isnull(detalle_no_saldos,0)<>1  
                       and Detrec_fechacancela between ''' +@fechaini+ ''' and '''+@fechafin+'''
        ) as  X
          full join [' +@base+ '].dbo.te_saldosmensuales g
               on x.empresacodigo=g.empresacodigo and x.aaaamm=g.mesproceso and rtrim(x.codigo)=g.cajabancocodigo+g.monedacuenta  
          left join [' +@base+ '].dbo.co_multiempresas h on x.empresacodigo=h.empresacodigo
        where x.Td_Concep like '''+@concepto+''' and  
              x.cabrec_ingsal like '''+@ingsal+''' and  
              case when  rtrim(ltrim(isnull(x.cabrec_transferenciaautomatico,'''')))='''' 
              then ''0'' else ''1'' end 
            like  '''+@transfer+'''     
       group by h.empresadescripcion,x.codigo,x.detrec_numctacte,x.DescCajaBanco,g.saldoinicial,
               x.detrec_monedacancela,x.monedadescripcion,x.cabrec_numrecibo,x.cabrec_numreciboegreso,
               x.ProveCliConc,x.detrec_fechacancela,x.tdqc,x.Td_Concep,
               x.detrec_numdocumento,x.monedasimbolo,x.cabrec_ingsal,x.aaaamm   
		order by h.empresadescripcion, X.detrec_numctacte,x.detrec_monedacancela,X.detrec_fechacancela'

execute (@cadsql)
GO
