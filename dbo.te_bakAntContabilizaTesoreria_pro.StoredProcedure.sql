SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create       proc [te_bakAntContabilizaTesoreria_pro]
	@base varchar(50),
	@cadcajabanco varchar(20),
	@codigo varchar(20)
	--@codtipo varchar(1)  --1:Caja  2:Banco  
as
/*
Declare @base varchar(50)
Declare @cadcajabanco varchar(20)
Declare @codigo varchar(20)
Declare @codtipo varchar(1)  --1:Caja  2:Banco  
set @base='ventas_prueba'
set @codigo='%'
set @cadcajabanco='B'
*/
declare @cadsql varchar(3000)
set @cadsql='
		select  a.detrec_item, a.detrec_emisioncheque,detrec_monedacancela,a.detrec_importesoles,
		a.detrec_importedolares, detrec_tipocajabanco,a.detrec_cajabanco1, a.detrec_numctacte,
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
  		ProveCliConc=
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
		from  [' +@base+ '].dbo.te_detallerecibos a, 
				[' +@base+ '].dbo.te_cabecerarecibos b, 
				[' +@base+ '].dbo.te_operaciongeneral c,
				[' +@base+ '].dbo.gr_banco d,
				[' +@base+ '].dbo.te_codigocaja e,
				[' +@base+ '].dbo.gr_moneda f
		where a.cabrec_numrecibo=b.cabrec_numrecibo and 
				b.operacioncodigo=c.operacioncodigo and 
				ltrim(rtrim(a.detrec_cajabanco1+a.detrec_numctacte)) like  ''' +@codigo+ '''  and
				detrec_tipocajabanco like ''' +@cadcajabanco+''' and 
				a.detrec_cajabanco1*=d.bancocodigo and
				a.detrec_cajabanco1*=e.cajacodigo  and 
				a.detrec_monedacancela=f.monedacodigo and
				b.cabrec_ingsal=''E'' and
				month(a.detrec_fechacancela)=12 and year(a.detrec_fechacancela)=2002
		order by a.detrec_cajabanco1, a.detrec_numctacte,a.detrec_fechacancela'
print (@cadsql)
--exec te_ContabilizaTesoreria_pro 'ventas_prueba','B','%'
GO
