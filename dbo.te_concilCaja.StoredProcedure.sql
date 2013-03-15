SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE                   proc [te_concilCaja]
--Declare 
@Base   varchar(50), 
@caja varchar(2),
@Moneda varchar(2),
@Fecharef  varchar(10),
@filtro  varchar(50),
@tipo  varchar(1)='0'
as 
/*
 Set @Base='Ventas_Prueba'
 Set @cuenta='011-350-0100008495-62' 
 set @concil='2' 
 Set @Fecharef='01/01/2003'  
 Set @fecha='01/12/2002'  
*/
Declare @Sqlcad varchar(4000),@Sqlvar varchar(1000)
Set @Sqlcad='
select 
      A.chkconcil,a.rendicionnumero,b.cabcomprobnumero,
      a.cabrec_numrecibo,A.detrec_fechacancela,a.detrec_cajabanco1,
      b.monedacodigo,d.monedadescripcion,
      A.detrec_emisioncheque,A.detrec_tipodoc_concepto,  A.detrec_numdocumento,
      B.cabrec_ingsal,A.detrec_tipocajabanco,  A.detrec_numctacte,
      A.detrec_monedadocumento,
      e.centrocostonivel,e.centrocostodescripcion,
      b.empresacodigo,
      empresadescripcion = b.empresacodigo+'' ''+f.empresadescripcion ,
----      empresacodigo= Isnull(
--       case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
--	  when ''P'' then 
--            (Select X.empresacodigo from  [' +@base+ '].dbo.cp_cargo X 
--             Where 
--                rtrim(b.clientecodigo)+a.detrec_tipodoc_concepto+detrec_numdocumento=
--                rtrim(x.clientecodigo)+x.documentocargo+x.cargonumdoc )
--          else b.empresacodigo
--          end , ''''),
      Td_Concep=
	      Isnull(
		   	case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
	       	when ''P'' then (Select X.tdocumentodescripcion from  [' +@base+ '].dbo.cp_tipodocumento X Where X.tdocumentocodigo=A.detrec_tipodoc_concepto)
	        	When ''C'' then (Select Y.tdocumentodescripcion from  [' +@base+ '].dbo.cc_tipodocumento Y Where Y.tdocumentocodigo=A.detrec_tipodoc_concepto)           
        	  	Else  (Select G.conceptodescripcion  from [' +@base+ '].dbo.te_conceptocaja G  where G.conceptocodigo=A.detrec_tipodoc_concepto)
       		End,''''),b.cabrec_transferenciaautomatico,
      ruc=Isnull(
     			case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          	When ''P'' then (Select Top 1 P.clienteruc  from [' +@base+ '].dbo.cp_proveedor P Where P.clientecodigo=b.clientecodigo)
        	  	When ''C'' then (Select Top 1 Cl.clienteruc  from  [' +@base+ '].dbo.vt_cliente Cl Where Cl.clientecodigo=b.clientecodigo)           
        		Else  ''''
       		End,'''') ,
      ProveCliConc=Isnull(
     			case upper(isnull(rtrim(ltrim(detrec_adicionactacte)),''X'')) 
          	When ''P'' then (Select Top 1 P.clienterazonsocial  from [' +@base+ '].dbo.cp_proveedor P Where P.clientecodigo=b.clientecodigo)
        	  	When ''C'' then (Select Top 1 Cl.clienterazonsocial  from  [' +@base+ '].dbo.vt_cliente Cl Where Cl.clientecodigo=b.clientecodigo)           
        		Else  b.cabrec_descripcion
       		End,'''') ,       
      importe = case when '''+@moneda+'''=''01'' then 
                A.detrec_importesoles else  A.detrec_importedolares end,
      A.detrec_monedacancela,
      A.detrec_tdqc,A.detrec_ndqc,A.detrec_fechacancela,B.cabrec_estadoreg,
      B.cabrec_fechadocumento,A.detrec_observacion,A.fechconcil,
      a.detrec_gastos,c.gastosdescripcion 
from ['+@Base+'].dbo.te_detallerecibos A 
     Inner join  ['+@Base+'].dbo.te_cabecerarecibos  B  
           on  A.cabrec_numrecibo=B.cabrec_numrecibo 
     left join ['+@Base+'].dbo.co_gastos  c  
           on  a.detrec_gastos=c.gastoscodigo 
     left join ['+@Base+'].dbo.gr_moneda  d  
           on  b.monedacodigo=d.monedacodigo 
     left join ['+@Base+'].dbo.ct_centrocosto  e  
           on  a.centrocostocodigo=e.centrocostocodigo 
     left join ['+@Base+'].dbo.co_multiempresas  f  
           on  b.empresacodigo=f.empresacodigo 
Where A.detrec_tipocajabanco=''C'' and B.cabrec_estadoreg <> 1 
      and isnull(detalle_no_saldos,0)<>1 
      and A.detrec_fechacancela <='''+@Fecharef+''' 
      and rtrim(A.detrec_cajabanco1)='''+@caja+'''
      and rtrim(b.monedacodigo)='''+@moneda+''' '
If @tipo='0' set @sqlvar= '  and isnull(A.chkconcil,0)<>1 '
if @tipo='1' set @sqlvar= '  and A.chkconcil=1 '
If @filtro<>'XX'   set @Sqlvar=@sqlvar +' and A.cabrec_numrecibo in ( select * from '+@filtro + ')'
execute(@Sqlcad+@Sqlvar+' order by a.detrec_fechacancela,b.cabrec_ingsal desc ')
---execute te_concilCaja 'acuaplayacasma','02','01','10/09/2006','##mmjserver_cajaconcil','1'
GO
