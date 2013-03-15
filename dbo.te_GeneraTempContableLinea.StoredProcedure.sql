SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

exec te_GeneraTempContableLinea 'planta_casma','planta_casma','03','776900','676900','##jck','07','2009','I','101344'

EXEC te_GeneraAsientosTesorerialINEA_pro 'planta_casma','planta_casma','011','0099','04','01','2007','001','desa3','SA','E','400433',1,'0101100100'

DROP        Procedure te_GeneraTempContableLinea
select * from install.dbo.te_cabecerarecibos where cabrec_numrecibo='100922'
select * from install.dbo.te_detallerecibos where cabrec_numrecibo='100922'


select * from ##tmpEgreso##jck
select * from ##tmpCuentaEgreso##jck
select * from ##tmpCuentaCaja##jck
select * from ##tmpAsientosConta##jck
*/

CREATE               Procedure [te_GeneraTempContableLinea]

--Declare

@Base varchar(50),
@BaseConta varchar(50),
@empresa  varchar(2),
@CtaGanCambio varchar(20),
@CtaPerCambio varchar(20),
@NombrePC varchar(50),
@MesProceso varchar(2),
@AnnoProceso varchar(4),
@TipoMov varchar(1),  /*I:Ingreso E:Egreso */
@Nrecibo varchar(6),
@retencion varchar(2)='55'
as
Declare @CadCtasIngresoEgreso varchar(8000)
Declare @CadCtasCaja varchar(8000)
Declare @CadDifCambio varchar(8000)

if exists (select name from tempdb.dbo.sysobjects where name='##tmpEgreso' +@NombrePC) 
  exec('DROP TABLE ##tmpEgreso' +@NombrePC)
if exists (select name from tempdb.dbo.sysobjects where name='##tmpCuentaEgreso' + @NombrePC)
  exec('DROP TABLE ##tmpCuentaEgreso' +@NombrePC)
set @CadCtasIngresoEgreso='

select ZZ.*,
tcemision=isnull((select tipocambioventa from '  +@BaseConta+ '.dbo.ct_tipocambio as M where M.tipocambiofecha=ZZ.FechaEmision),1)
into ##tmpEgreso' +@NombrePC+ '
from 
(select b.empresacodigo,A.cabrec_numrecibo,A.detrec_item,ImporteSoles=A.detrec_importesoles,
   ImporteDolar=A.detrec_importedolares,A.detrec_monedacancela, A.detrec_cajabanco1,A.detrec_numctacte,
    A.detrec_tipocajabanco,concepto=A.detrec_tipodoc_concepto,operacioncontrolaclienteprov=isnull(operacioncontrolaclienteprov,''X''),
    tdocumentosunat=rtrim(isnull(d.tdocumentosunat,'''')) , b.clientecodigo,
    A.detrec_observacion,A.detrec_fechacancela,	tccancela=1.000,
    detrec_numdocumento,detrec_tipodoc_concepto,a.detrec_tdqc, detrec_ndqc,
    detrec_ndqcxrendir=''001''+case when len(rtrim(b.cabrec_numreciboegreso))=0  then a.detrec_ndqc
                   else isnull(( select top 1 z.cabrec_numreciboegreso
                          from [' +@Base+ '].dbo.te_cabecerarecibos z 
                          where z.numerodocxrendir=b.cabrec_numreciboegreso and z.cabrec_ingsal=''E''  
                          and z.cabrec_numrecibo<>b.cabrec_numrecibo
                        ) ,a.detrec_ndqc) end  ,
    codigoxrendir=case when len(rtrim(b.cabrec_numreciboegreso))=0  then B.clientecodigo
                   else isnull(( select top 1 z.clientecodigo
                          from [' +@Base+ '].dbo.te_cabecerarecibos z 
                          where z.numerodocxrendir=b.cabrec_numreciboegreso and z.cabrec_ingsal=''E''  
                          and z.cabrec_numrecibo<>b.cabrec_numrecibo
                        ) ,B.clientecodigo) end  ,
FechaEmision=isnull(
			case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
     			When ''P'' then (select top 1 cp.cargoapefecemi from [' +@base+ '].dbo.cp_cargo cp where cp.empresacodigo=b.empresacodigo and cp.documentocargo=A.detrec_tipodoc_concepto and 
									cp.cargonumdoc=A.detrec_numdocumento and cp.clientecodigo like B.clientecodigo)
				When ''C'' then (select top 1 cc.cargoapefecemi from [' +@base+ '].dbo.vt_cargo cc where cc.empresacodigo=b.empresacodigo and cc.documentocargo=A.detrec_tipodoc_concepto and 
									cc.cargonumdoc=A.detrec_numdocumento and cc.clientecodigo like B.clientecodigo)
  				Else
					B.cabrec_fechadocumento	End, B.cabrec_fechadocumento),
ImporteApertura=isnull(
			case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
     			When ''P'' then (select top 1 cp.cargoapeimpape from [' +@base+ '].dbo.cp_cargo cp where cp.empresacodigo=b.empresacodigo and cp.documentocargo=A.detrec_tipodoc_concepto and 
									cp.cargonumdoc=A.detrec_numdocumento and cp.clientecodigo=B.clientecodigo)
				When ''C'' then (select top 1 cc.cargoapeimpape from [' +@base+ '].dbo.vt_cargo cc where cc.empresacodigo=b.empresacodigo and cc.documentocargo=A.detrec_tipodoc_concepto and 
									cc.cargonumdoc=A.detrec_numdocumento and cc.clientecodigo like B.clientecodigo)
  				End,0),
MonedaApertura=isnull(
			case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
     			When ''P'' then (select top 1 cp.monedacodigo from [' +@base+ '].dbo.cp_cargo cp where cp.empresacodigo=b.empresacodigo and cp.documentocargo=A.detrec_tipodoc_concepto and 
									cp.cargonumdoc=A.detrec_numdocumento and cp.clientecodigo = B.clientecodigo
									and isnull(cargoapeflgreg,0)<>1 )
				When ''C'' then (select top 1 cc.monedacodigo from [' +@base+ '].dbo.vt_cargo cc where cc.empresacodigo=b.empresacodigo and cc.documentocargo=A.detrec_tipodoc_concepto and 
									cc.cargonumdoc=A.detrec_numdocumento and cc.clientecodigo = B.clientecodigo)
				else A.detrec_monedacancela End,a.detrec_monedadocumento),
cuenta= case when detrec_monedadocumento=''01'' then
	     	Isnull( case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
      		    	When ''P'' then (Select P.tdocumentocuentasoles  from  [' +@base+ '].dbo.cp_tipodocumento P 
                                         Where P.tdocumentocodigo=a.detrec_tipodoc_concepto)
        	  	when ''C'' then (Select Cl.tdocumentocuentasoles from  [' +@base+ '].dbo.cc_tipodocumento Cl 
					Where Cl.tdocumentocodigo=a.detrec_tipodoc_concepto)           
        		Else CASE  when isnull(b.cabcomprobnumero,0)>0 then
                                  (Select P.tdocumentocuentasoles  from  [' +@base+ '].dbo.cp_tipodocumento P 
                                         Where P.tdocumentocodigo=a.detrec_tipodoc_concepto)
                              else case when isnull(b.cabcomprobnumero,0)=0 and isnull(detrec_gastos,0)>0 then
                                        (select cuentacodigo from [' +@base+ '].dbo.co_gastos where gastoscodigo=a.detrec_gastos)
                                   else (Select P.conceptocuentasoles  from  [' +@base+ '].dbo.te_conceptocaja P 
                                         Where P.conceptocodigo=a.detrec_tipodoc_concepto)
 				   end
                              end
       			End,'''') 
		Else
	     	Isnull(
   	  		case upper(isnull(rtrim(ltrim(C.operacioncontrolaclienteprov)),''X'')) 
      		    	When ''P'' then (Select P.tdocumentocuentadolares  from [' +@base+ '].dbo.cp_tipodocumento P 
					Where P.tdocumentocodigo=a.detrec_tipodoc_concepto)
        	  	When ''C'' then (Select Cl.tdocumentocuentadolares  from [' +@base+ '].dbo.cc_tipodocumento Cl 
					Where Cl.tdocumentocodigo=a.detrec_tipodoc_concepto)           
        		Else   CASE  when isnull(b.cabcomprobnumero,0)>0 then
                                  (Select P.tdocumentocuentadolares  from  [' +@base+ '].dbo.cp_tipodocumento P 
                                         Where P.tdocumentocodigo=a.detrec_tipodoc_concepto)
                               else case when isnull(b.cabcomprobnumero,0)=0 and isnull(detrec_gastos,0)>0 then
                                         (select cuentacodigo from [' +@base+ '].dbo.co_gastos where gastoscodigo=a.detrec_gastos)
                                    else (Select P.conceptocuentadolar  from  [' +@base+ '].dbo.te_conceptocaja P 
                                         Where P.conceptocodigo=a.detrec_tipodoc_concepto)
 				    end
                               end
       			End,'''') end, 
        cabrec_numreciboegreso,
        centrocostocodigo=case when isnull(A.centrocostocodigo,'''')='''' then ''00'' else a.centrocostocodigo end
from [' +@Base+ '].dbo.te_detallerecibos A
     inner join [' +@Base+ '].dbo.te_cabecerarecibos B on a.cabrec_numrecibo=b.cabrec_numrecibo
     left join [' +@Base+ '].dbo.te_operaciongeneral C on b.operacioncodigo=c.operacioncodigo
     left join [' +@Base+ '].dbo.cc_tipodocumento  d on a.detrec_tipodoc_concepto=d.tdocumentocodigo
where b.cabrec_numrecibo='''+@Nrecibo+''' and 
	month(a.detrec_fechacancela)='''+@MesProceso+ ''' and
	year(a.detrec_fechacancela)='''+@AnnoProceso+ ''' and
   isnull(b.cabrec_transferenciaautomatico,0)<>''1'' and
	isnull(a.detrec_estadoreg,0)<>''1'' and
	b.cabrec_ingsal like ''' +@TipoMov+''') as ZZ '

execute (@CadCtasIngresoEgreso)

set @CadCtasIngresoEgreso='select
empresacodigo,cabrec_numrecibo,
detrec_item=detrec_item ,MonedaApertura as MonedaCodigo,
detrec_tipodoc_concepto=case when tdocumentosunat='''' then detrec_tipodoc_concepto else tdocumentosunat end ,
detrec_numdocumento=detrec_numdocumento  ,clientecodigo,
cuenta=cast(cuenta as varchar(20)),
detrec_observacion=case upper(isnull(rtrim(ltrim(operacioncontrolaclienteprov)),''X'')) 
                        when ''X'' then detrec_observacion
                                else detrec_tipocajabanco+'' ''+rtrim(detrec_cajabanco1)+'' ''+
                                    rtrim(detrec_numctacte)+'' ''+detrec_tdqc+'' ''+detrec_ndqc
                  end,
FechaEmision,detrec_fechacancela as FechaCancela,tcemision as TipoCambio,
DebeS=Cast(Round(
	case upper(isnull(rtrim(ltrim(operacioncontrolaclienteprov)),''X'')) 
  	     When ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=yy.cabrec_numrecibo)
	                         when ''E'' then 
				    case when monedaapertura=''02'' then
                                          Cast(Round(ImporteDolar*tcemision,2) as Numeric(15,2))
				    else Cast(Round(ImporteSoles,2) as Numeric(15,2))
                		    End	
		             else cast(0.00 as float) end
  	     When ''C'' then cast(0.00 as float)           
  	     Else  
				case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where A.cabrec_numrecibo=yy.cabrec_numrecibo)
						when ''I''  then cast(0.00 as float)
						when ''E''	 then 
							case when monedaapertura=''02'' 
								then	ImporteDolar*tcemision
								else	ImporteSoles
							end end
		End,2) as float),
HaberS=Cast(Round(
  		case upper(isnull(rtrim(ltrim(operacioncontrolaclienteprov)),''X'')) 
  	    	    When ''P'' then 
                         case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=yy.cabrec_numrecibo)
	                              when ''I'' then 
	                                         case when monedaapertura=''02'' then
                                                           Cast(Round(ImporteDolar*tcemision,2) as Numeric(15,2))
				                      else Cast(Round(ImporteSoles,2) as Numeric(15,2))
                		                  end	
		                      else cast(0.00 as float)
                          end
  		When ''C'' then 
			case when monedaapertura=''02'' 
				then	ImporteDolar*tcemision
						else	ImporteSoles
					end
  			Else  
				case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where A.cabrec_numrecibo=yy.cabrec_numrecibo)
						when ''E''  then cast(0.00 as float)
						when ''I''	 then 
							case when monedaapertura=''02'' 
								then	ImporteDolar*tcemision
								else	ImporteSoles
							end
				end	
  			End,2) as float),
DebeD=Cast(Round(case upper(isnull(rtrim(ltrim(operacioncontrolaclienteprov)),''X'')) 
       When ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=yy.cabrec_numrecibo)
	               when ''E'' then case when monedaapertura=''02'' then
                                          Cast(Round(ImporteDolar,2) as Numeric(15,2))
				        else Cast(Round(ImporteSoles/tcemision,2) as Numeric(15,2)) End	
		       else cast(0.00 as float) end
       When ''C'' then cast(0.00 as float)           
       Else case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where A.cabrec_numrecibo=yy.cabrec_numrecibo)
	    when ''I''  then cast(0.00 as float)
	    when ''E''	 then case when monedaapertura=''02'' then ImporteDolar else ImporteSoles/tcemision end
	    end
       End,2) as float),
HaberD=Cast(Round(case upper(isnull(rtrim(ltrim(operacioncontrolaclienteprov)),''X'')) 
  	    	  When ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=yy.cabrec_numrecibo)
	                          when ''I'' then case when monedaapertura=''02'' then Cast(Round(ImporteDolar,2) as Numeric(15,2))
				                  else Cast(Round(ImporteSoles/tcemision,2) as Numeric(15,2)) end	
		                  else cast(0.00 as float)end
  		  When ''C'' then case when monedaapertura=''02'' then ImporteDolar else ImporteSoles/tcemision end
  		  Else 	case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where A.cabrec_numrecibo=yy.cabrec_numrecibo)
			when ''E''  then cast(0.00 as float)
			when ''I''	 then case when monedaapertura=''02'' then ImporteDolar else ImporteSoles/tcemision end
                        end End,2) as float),
ImporteSol=case when monedaapertura=''02'' then	round(ImporteDolar*tcemision,2) 	else	ImporteSoles end,
ImporteDolar=	case when monedaapertura=''02'' then	ImporteDolar else round(ImporteSoles/tcemision,2) end,
ImporteSoles,centrocostocodigo
into ##tmpCuentaEgreso'+ @NombrePC+ '
from 	##tmpEgreso'+ @NombrePC+ ' yy order by 1'

execute(@CadCtasIngresoEgreso)

if exists (Select name from tempdb.dbo.sysobjects where name='##tmpCuentaCaja' +@NombrePC)
  exec('drop table ##tmpCuentaCaja' +@NombrePC)

set @CadCtasCaja='
select empresacodigo,cabrec_numrecibo=cast(cabrec_numrecibo as varchar(6)),
detrec_item=cast( isnull((select max(cast(detrec_item as numeric(3))) from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo),0)+1 as varchar(3)) collate Modern_Spanish_CI_AI,detrec_monedacancela as MonedaCodigo,
detrec_tipodoc_concepto=detrec_tdqc,
detrec_numdocumento= detrec_ndqc,clientecodigo,cuenta=cast(cuenta as varchar(20)),
detrec_observacion=case (select distinct operacioncontrolaclienteprov from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo)
                     when ''X'' then detrec_observacion else clientecodigo+'' ''+rtrim(detrec_tipodoc_concepto)+'' ''+
                         rtrim(detrec_numdocumento) end,
detrec_fechacancela as FechaEmision,detrec_fechacancela as FechaCancela,tccancela as TipoCambio,
DebeS= case (select distinct operacioncontrolaclienteprov from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo)
       when ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
	               when ''I'' then case when detrec_monedacancela=''02'' then
                                 Cast(Round(ImporteDolar*tccancela,2) as Numeric(15,2))
			     else Cast(Round(ImporteSoles,2) as Numeric(15,2))  end	
		       else cast(0.00 as float) end
       when ''C'' then case when detrec_monedacancela=''02'' then  Cast(Round(ImporteDolar*tccancela,2) as float)
		       else Cast(Round(ImporteSoles,2) as float) end
       else case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
	    when ''I''	 then case when detrec_monedacancela=''02'' then
                                  Cast(Round(ImporteDolar*tccancela,2) as Numeric(15,2))
			      else Cast(Round(ImporteSoles,2) as Numeric(15,2)) end	
            when ''E''  then cast( 0.00 as float) end	end,
HaberS=	case (select distinct operacioncontrolaclienteprov from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo)
	when ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
		        when ''E'' then case when detrec_monedacancela=''02'' then Cast(Round(ImporteDolar*tccancela,2) as Numeric(15,2))
				        else Cast(Round(ImporteSoles,2) as Numeric(15,2)) end	
                        else cast(0.00 as float) end
	when ''C'' then cast(0.00 as float)
	else case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
             when ''E'' then case when detrec_monedacancela=''02''then Cast(Round(ImporteDolar*tccancela,2) as Numeric(15,2))
                             else	Cast(Round(ImporteSoles,2) as Numeric(15,2)) end	
             when ''I''  then cast(0.00 as float) end end,
DebeD=case (select distinct operacioncontrolaclienteprov from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo)
      when ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
	             when ''I'' then case when detrec_monedacancela=''02'' then Cast(Round(ImporteDolar,2) as Numeric(15,2))
				     else Cast(Round(ImporteSoles/tccancela,2) as Numeric(15,2)) end	
                     else cast(0.00 as float) end
      when ''C'' then case when detrec_monedacancela=''02'' then Cast(Round(ImporteDolar,2) as float)
                      else Cast(Round(ImporteSoles/tccancela,2) as float) end
      else case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
		          when ''I'' then case when detrec_monedacancela=''02'' then
                                	Cast(Round(ImporteDolar,2) as Numeric(15,2))
		        	else	Cast(Round(ImporteSoles/tccancela,2) as Numeric(15,2)) end	
                          when ''E''  then cast(0.00 as float)                       end end,
HaberD=	case (select distinct operacioncontrolaclienteprov from ##tmpEgreso' +@NombrePC+ ' A where cabrec_numrecibo=TT.cabrec_numrecibo)
	   when ''P'' then case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
			   when ''E'' then case when detrec_monedacancela=''02'' then Cast(Round(ImporteDolar,2) as Numeric(15,2))
				                else Cast(Round(ImporteSoles/tccancela,2) as Numeric(15,2)) end	
		           else cast(0.00 as float) end
	    when ''C'' then cast(0.00 as float)
	    else case (select distinct cabrec_ingsal from [' +@base+ '].dbo.te_cabecerarecibos A where cabrec_numrecibo=TT.cabrec_numrecibo)
                 when ''E'' then case when detrec_monedacancela=''02''then
			                Cast(Round(ImporteDolar,2) as Numeric(15,2))
				  else	Cast(Round(ImporteSoles/tccancela,2) as Numeric(15,2))
			          end	
	         when ''I''  then cast(0.00 as float)
	         end end,
ImporteSol=  case when detrec_monedacancela=''02'' then	Round(ImporteDolar*tccancela,2)
            	else	Round(ImporteSoles,2) end,
ImporteDolar,ImporteSoles,centrocostocodigo=cast(''00'' as varchar(10))
into ##tmpCuentaCaja' +@NombrePC+ '
from
(Select XX.*,  
tccancela= case when XX.detrec_monedacancela=''02'' 
		then	isnull((select tipocambioventa from [' +@BaseConta+'].dbo.ct_tipocambio as M where M.tipocambiofecha=XX.detrec_fechacancela),0)
			else	isnull((select tipocambioventa from [' +@BaseConta+'].dbo.ct_tipocambio as M where M.tipocambiofecha=XX.detrec_fechacancela),0)
           end
from
(select zz.*,
cuenta=	case when zz.detrec_tdqc='+@retencion+' then ''469200'' 
             else case when zz.detrec_tipocajabanco=''C'' then 
	        	case when detrec_monedacancela=''01'' then
               	        	(select C.cajacuentasoles from [' +@Base+ '].dbo.te_codigocaja C where C.cajacodigo=zz.detrec_cajabanco1)
		        else (select C.cajacuentadolares from [' +@Base+ '].dbo.te_codigocaja C where C.cajacodigo=zz.detrec_cajabanco1)
		        end
	          else (select cbanco_cuenta from [' +@Base+ '].dbo.te_cuentabancos
		         where cbanco_codigo=zz.detrec_cajabanco1 and monedacodigo=zz.detrec_monedacancela and cbanco_numero=zz.detrec_numctacte)
	          end
              end,
detrec_ndqc=(select top 1 detrec_ndqcxrendir from ##tmpEgreso' +@NombrePC+ '),
detrec_observacion=(select top 1 A.detrec_observacion from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=zz.cabrec_numrecibo),
detrec_fechacancela=(select top 1 A.detrec_fechacancela from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=zz.cabrec_numrecibo),
detrec_tipodoc_concepto='''',	detrec_numdocumento='''' ,
clientecodigo=(select top 1 rtrim(codigoxrendir) from ##tmpEgreso' +@NombrePC+ ')
from
(select cc.empresacodigo,bb.cabrec_numrecibo,
        detrec_tdqc= case when bb.detrec_tdqc='''' then ''20'' else bb.detrec_tdqc end,
        bb.detrec_monedacancela,
        bb.detrec_cajabanco1,bb.detrec_numctacte,bb.detrec_tipocajabanco,ImporteSoles=sum(bb.detrec_importesoles),ImporteDolar=sum(bb.detrec_importedolares) 
	from [' +@Base+ '].dbo.te_detallerecibos bb, [' +@Base+ '].dbo.te_cabecerarecibos cc
	where month(bb.detrec_fechacancela)=''' +@mesproceso+ ''' and year(bb.detrec_fechacancela)=''' +@annoproceso+''' and
            isnull(bb.detrec_estadoreg,0)<>''1'' and bb.cabrec_numrecibo=cc.cabrec_numrecibo and
	    isnull(cc.cabrec_transferenciaautomatico,0)<>''1''	and cc.cabrec_numrecibo='''+@Nrecibo+''' and 
            cc.cabrec_ingsal like ''' +@TipoMov+''' 
         group by  cc.empresacodigo,bb.cabrec_numrecibo,bb.detrec_tdqc,bb.detrec_monedacancela,
                   bb.detrec_cajabanco1,bb.detrec_numctacte,bb.detrec_tipocajabanco) as ZZ
 ) as xx ) as tt
order by 1'

execute (@CadCtasCaja)

if exists (Select name from tempdb.dbo.sysobjects where name='##tmpcuentacaja_tmp' +@NombrePC)
  exec('drop table ##tmpcuentacaja_tmp' +@NombrePC)

set @CadCtasCaja=' Select top 0 *  into ##tmpcuentacaja_tmp' +@NombrePC+' from ##tmpCuentaCaja' +@NombrePC+ '
               insert ##tmpcuentacaja_tmp' +@NombrePC+' select * from ##tmpCuentaEgreso' +@NombrePC+ ''
execute (@CadCtasCaja)
if exists (Select name from tempdb.dbo.sysobjects where name='##tmpAsientosConta' +@NombrePC)
  exec('drop table ##tmpAsientosConta' +@NombrePC)

set @CadDifCambio='
select * into ##tmpAsientosConta' +@NombrePC+ ' from ##tmpCuentacaja_tmp' +@NombrePC+ ' union all
	select * from ##tmpCuentaCaja' +@NombrePC+ ' union all
		select * from 
(select yy.empresacodigo,YY.cabrec_numrecibo,
detrec_item=(select max(cast(detrec_item as numeric(3))) from ##tmpCuentaCaja' +@NombrePC+ ' A where cabrec_numrecibo=YY.cabrec_numrecibo)+1  ,
MonedaCodigo=''01'',detrec_tipodoc_concepto='' '', 
detrec_numdocumento='' '',clientecodigo='' '',   
cuenta= 
  case when YY.diferencia>0 then ''' +@CtaGanCambio+  ''' else ''' +@CtaPerCambio+ ''' end,
detrec_observacion='' '',fechaemision=HH.FechaCancela,
HH.FechaCancela,TipoCambio=1,		
DebeS=
	case when YY.diferencia<0 then round(abs(YY.Diferencia),2) else 0 end,
HaberS=
	case when YY.diferencia>0 then Round(YY.Diferencia,2) else 0 end,
DebeD=0,HaberD=0,HH.ImporteSol,HH.ImporteDolar,HH.ImporteSoles,centrocostocodigo=''40100''
from (select empresacodigo,cabrec_numrecibo,Diferencia=Round(sum(DebeS),2)-Round(Sum(HaberS),2) 
      from 
          ( select empresacodigo,cabrec_numrecibo,DebeS,HaberS from ##tmpCuentaEgreso' +@NombrePC+ ' 
             union all
 	    select empresacodigo,cabrec_numrecibo,DebeS,HaberS from ##tmpCuentaCaja' +@NombrePC+ '
           )as ZZ
      group by empresacodigo,cabrec_numrecibo
      )as YY,
      ( select 	fechacancela,cabrec_numrecibo,importesol=sum(importesol),importedolar=sum(importedolar),importesoles=sum(importesoles) from ##tmpCuentaCaja' +@NombrePC+ '
        group by cabrec_numrecibo,fechacancela ) HH
        where YY.cabrec_numrecibo=HH.cabrec_numrecibo and YY.Diferencia<>0 and YY.cabrec_numrecibo='''+@Nrecibo+''') as WW
order by 1,2'

execute(@CadDifCambio) 

Declare @cadAsientos as varchar(2000)
set @cadAsientos=''
set @cadAsientos='
	update [##tmpAsientosConta' +@NombrePC+ '] set clientecodigo=''00''
		where isnull(clientecodigo,'''')='''''
execute(@cadAsientos)
set nocount off
--exec te_GeneraTempContableLinea 'acua_molina','acua_molina','776900','676900','Desa3','01','2007','E','400433'
GO
