SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXECUTE te_GeneraTempContableTransfLinea 'casma_2010','casma_2010','03','776900','676900','##xx','08','2010','001433'

select * from ##tmpCuentaCajaTransf##xx
select * from ##tmpAsientosContaTransf##xx
select * from aliter.dbo.te_cabecerarecibos where cabrec_numreciboegreso='001096'

*/

CREATE     Procedure [te_GeneraTempContableTransfLinea]
--Declare
@Base varchar(50),
@BaseConta varchar(50),
@empresa   varchar(2),
@CtaGanCambio varchar(20),
@CtaPerCambio varchar(20),
@NombrePC varchar(50),
@MesProceso varchar(2),
@AnnoProceso varchar(4),
@Ntransfer   varchar(15)
as
Declare @CadCtasEgreso varchar(6000)
Declare @CadCtasCaja varchar(6000)
Declare @CadDifCambio varchar(6000)
if exists (Select name from tempdb.dbo.sysobjects where name='##tmpCuentaCajaTransf' +@NombrePC)
  exec('drop table ##tmpCuentaCajaTransf' +@NombrePC)
set @CadCtasCaja='
select empresacodigo='''+@empresa+''',cabrec_numreciboegreso,cabrec_numrecibo, cabrec_ingsal,
detrec_item=cast(0 as varchar(3)),detrec_monedacancela as MonedaCodigo,detrec_tipodoc_concepto,
detrec_numdocumento,clientecodigo,
cuenta=case when empresacodigo<>'''+@empresa+''' then 
               case when detrec_monedacancela=''02'' then 
                        ( select conceptocuentadolar from ['+@base +'].dbo.te_conceptocaja 
                                 where conceptocodigo=detrec_tipodoc_concepto )
                           else   (select conceptocuentasoles from ['+@base+'].dbo.te_conceptocaja 
                                    where conceptocodigo=detrec_tipodoc_concepto )
                          end
              else cuenta end,                    
detrec_observacion=case when empresacodigo<>'''+@empresa+''' then 
                      ( select empresadescripcion from ['+@base+'].dbo.co_multiempresas a 
                           where a.empresacodigo=tt.empresacodigo )
                   else detrec_observacion end   ,
detrec_fechacancela as FechaEmision,detrec_fechacancela as FechaCancela,tccancela as TipoCambio,
DebeS=case when cabrec_ingsal=''E'' then cast(0.00 as float)
	else	case when detrec_monedacancela=''02'' then
                	Cast(Round(ImporteDolar*tccancela,2) as float)
                     else	Cast(Round(ImporteSoles,2) as float)
        end end,
HaberS=	case when cabrec_ingsal=''E'' then 
         	  case when detrec_monedacancela=''02''	then	
			    Cast(Round(ImporteDolar*tccancela,2) as float)
		   else	Cast(Round(ImporteSoles,2) as float)
		   end
        else cast(0.00 as float)
	end,			
DebeD=	case when cabrec_ingsal=''E''	then cast( 0.00 as float)
	else case when detrec_monedacancela=''02'' then	Cast(Round(ImporteDolar,2) as float)
	     else	Cast(Round(ImporteSoles,2)/tccancela as float)
             end
	end,
HaberD=	case when cabrec_ingsal=''E'' then case when detrec_monedacancela=''02'' 
			then	Cast(Round(ImporteDolar,2) as float)
				else	Cast(Round(ImporteSoles,2)/tccancela as float)
				end
			else	cast(0.00 as float) end,			
	ImporteSol=case when detrec_monedacancela=''02'' 
			then	Round(ImporteDolar*tccancela,2)
			else	Round(ImporteSoles,2) end,
	ImporteDolar, ImporteSoles
into ##tmpCuentaCajaTransf' +@NombrePC+ '
from
(Select XX.*,  	tccancela=case when XX.detrec_monedacancela=''02'' then	
                               isnull((select tipocambioventa from [' +@BaseConta+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=XX.detrec_fechacancela),0)
			else 1 end
from (select 	distinct empresacodigo,ZZ.cabrec_numreciboegreso,ZZ.cabrec_numrecibo,ZZ.cabrec_ingsal, 
        ZZ.ImporteSoles,ZZ.ImporteDolar,YY.detrec_monedacancela,YY.detrec_cajabanco1,YY.detrec_numctacte,
	YY.detrec_tipocajabanco,
	cuenta=	case when YY.detrec_tipocajabanco=''C'' then 
			  case when detrec_monedacancela=''01'' then
				    (select C.cajacuentasoles from [' +@Base+ '].dbo.te_codigocaja C where C.cajacodigo=YY.detrec_cajabanco1)
			else
			            (select C.cajacuentadolares from [' +@Base+ '].dbo.te_codigocaja C where C.cajacodigo=YY.detrec_cajabanco1)
			end
		else
		         (select cbanco_cuenta from [' +@Base+ '].dbo.te_cuentabancos
				where cbanco_codigo=YY.detrec_cajabanco1 and monedacodigo=YY.detrec_monedacancela and cbanco_numero=YY.detrec_numctacte)
		end,
	detrec_tdqc=(select top 1 A.detrec_tdqc from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=YY.cabrec_numrecibo),
	detrec_ndqc=(select top 1 A.detrec_ndqc from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=YY.cabrec_numrecibo),
	detrec_observacion=(select top 1 A.detrec_observacion from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=YY.cabrec_numrecibo),
	detrec_fechacancela=(select top 1 A.detrec_fechacancela from [' +@Base+ '].dbo.te_detallerecibos A where A.cabrec_numrecibo=YY.cabrec_numrecibo),
	detrec_tipodoc_concepto,detrec_numdocumento,
	clientecodigo=(select top 1 clientecodigo from [' +@Base+ '].dbo.te_cabecerarecibos A where A.cabrec_numrecibo=YY.cabrec_numrecibo)
from (select 	cc.empresacodigo,CC.cabrec_numreciboegreso,
	bb.cabrec_numrecibo,cc.cabrec_ingsal,ImporteSoles=sum(bb.detrec_importesoles),ImporteDolar=sum(bb.detrec_importedolares) 
	from [' +@Base+ '].dbo.te_detallerecibos bb,  [' +@Base+ '].dbo.te_cabecerarecibos cc	
	where bb.cabrec_numrecibo=cc.cabrec_numrecibo and isnull(cc.cabrec_estadoreg,1)<>''1'' and
		 isnull(cc.cabrec_transferenciaautomatico,0)=''1''	and 
		month(bb.detrec_fechacancela)=' +@MesProceso+' and year(bb.detrec_fechacancela)=' +@AnnoProceso+ ' 
	group by cc.empresacodigo,cc.empresacodigo,CC.cabrec_numreciboegreso,bb.cabrec_numrecibo,cc.cabrec_ingsal ) as ZZ,
	[' +@Base+ '].dbo.te_detallerecibos YY	
where 	ZZ.cabrec_numrecibo=YY.cabrec_numrecibo and ZZ.cabrec_numreciboegreso='''+@Ntransfer+''' ) as XX ) as TT
order by 1'

execute(@CadCtasCaja)

/*Actualizar los Nº de Item*/

DECLARE @cabrec_numreciboegreso varchar(10)
Declare @cabrec_numrecibo varchar(10)
Declare @Conta int
Declare @NumTransf varchar(10)	
   exec('DECLARE tablas CURSOR FOR 
      	SELECT cabrec_numreciboegreso,cabrec_numrecibo from ##tmpCuentaCajaTransf' +@NombrePC+ ' ORDER BY 1')
	OPEN tablas
	/* Leer cada registro del cursor  */
	FETCH NEXT FROM tablas INTO @cabrec_numreciboegreso,@cabrec_numrecibo
   Set @NumTransf=@cabrec_numreciboegreso
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @cadsql varchar(1500)
		if @NumTransf=@cabrec_numreciboegreso
		begin
			set @conta=@conta+1
		end
		if @NumTransf<>@cabrec_numreciboegreso
		begin
			set @conta=1
			set @NumTransf=@cabrec_numreciboegreso
		end
		set @cadsql='Update ##tmpCuentaCajaTransf' +@NombrePC+ ' Set detrec_item=' +cast(@conta as varchar(3))+ '
				where cabrec_numreciboegreso=' + @cabrec_numreciboegreso+ ' and cabrec_numrecibo=' +@cabrec_numrecibo 
		exec(@cadsql)
	 	FETCH NEXT FROM tablas INTO @cabrec_numreciboegreso,@cabrec_numrecibo
   END
	CLOSE tablas
	DEALLOCATE tablas
   set @cadsql='
	update [##tmpCuentaCajaTransf' +@NombrePC+ '] Set detrec_item=1 
	where  
		cabrec_numreciboegreso=(select min(cabrec_numreciboegreso) from [##tmpCuentaCajaTransf' +@NombrePC+ ']) and
		cabrec_numrecibo=(select cabrec_numrecibo from [##tmpCuentaCajaTransf' + @NombrePC+ ']
			where cabrec_numreciboegreso in
				(select min(cabrec_numreciboegreso) from [##tmpCuentaCajaTransf' +@NombrePC+ ']) and 
					cabrec_ingsal=''I'')
	update [##tmpCuentaCajaTransf' +@NombrePC+ '] Set detrec_item=2 
	where  
		cabrec_numreciboegreso=(select min(cabrec_numreciboegreso) from [##tmpCuentaCajaTransf' +@NombrePC+ ']) and
		cabrec_numrecibo=(select cabrec_numrecibo from [##tmpCuentaCajaTransf' + @NombrePC+ ']
			where cabrec_numreciboegreso in
				(select min(cabrec_numreciboegreso) from [##tmpCuentaCajaTransf' +@NombrePC+ ']) and 
					cabrec_ingsal=''E'')'
	
	exec(@cadsql)
set @cadsql='
	update  [##tmpCuentaCajaTransf' +@NombrePC+ '] Set detrec_numdocumento=b.detrec_numdocumento
		from [##tmpCuentaCajaTransf' +@NombrePC+ '] a,
				[' +@Base+ '].dbo.te_detallerecibos b
		where a.cabrec_numrecibo=b.cabrec_numrecibo and a.cabrec_ingsal=''I'''
exec(@cadsql)
if exists (Select name from tempdb.dbo.sysobjects where name='##tmpAsientosTransf' +@NombrePC)
  exec('drop table ##tmpAsientosTransf' +@NombrePC)
set @CadDifCambio=
	'select * into ##tmpAsientosTransf' +@NombrePC+ ' from 
(select * from ##tmpCuentaCajaTransf' +@NombrePC+ '    union all
		select * from 
(select distinct hh.empresacodigo,
	HH.cabrec_numreciboegreso,
	HH.cabrec_numrecibo,
   HH.cabrec_ingsal,
	detrec_item=(select max(detrec_item) from ##tmpCuentaCajaTransf' +@NombrePC+ ' A where cabrec_numreciboegreso=YY.cabrec_numreciboegreso)+1  ,
	MonedaCodigo=''01'',HH.detrec_tipodoc_concepto, 
	HH.detrec_numdocumento,HH.clientecodigo,   
	cuenta= 
  		case when YY.diferencia>0 then ' +@CtaGanCambio+ ' else ' +@CtaPerCambio +' end,
	HH.detrec_observacion,
	HH.FechaEmision,
	HH.FechaCancela,HH.TipoCambio,		
	DebeS=
		case when YY.diferencia<0 then round(abs(YY.Diferencia),2) else 0 end,
	HaberS=
		case when YY.diferencia>0 then Round(abs(YY.Diferencia),2) else 0 end,
	DebeD=
		case when YY.diferencia<0 
			then case when YY.diferencia<0 then round(abs(YY.Diferencia)/HH.TipoCambio,2) else 0 end
			else case when YY.diferencia<0 then round(abs(YY.Diferencia),2) else 0 end
	end,
	HaberD=
		case when HH.TipoCambio>0 
			then	case when YY.diferencia>0 then round(YY.Diferencia/HH.TipoCambio,2) else 0 end
			else  case when YY.diferencia>0 then round(YY.Diferencia,2) else 0 end
		end,
	HH.ImporteSol,
	HH.ImporteDolar,
	HH.ImporteSoles                                         
from                                                 
	(select cabrec_numreciboegreso,Diferencia=Round(sum(DebeS),2)-Round(Sum(HaberS),2) from 
		(select cabrec_numreciboegreso,DebeS,HaberS from ##tmpCuentaCajaTransf' +@NombrePC+ ')as ZZ
			group by cabrec_numreciboegreso
         having Round(sum(DebeS),2)-Round(Sum(HaberS),2)<>0 )as YY,
	##tmpCuentaCajaTransf' +@NombrePC+ ' HH
where YY.Diferencia<>0 and  YY.cabrec_numreciboegreso=HH.cabrec_numreciboegreso and HH.cabrec_ingsal=''E'') as WW ) as ZZ
order by 1'

execute (@CadDifCambio)

Declare @cadAsientos as varchar(2000)

set @cadAsientos='
	update [##tmpAsientosTransf' +@NombrePC+ '] set clientecodigo=''00''
		where isnull(clientecodigo,'''')='''''
exec(@cadAsientos)
if exists (Select name from tempdb.dbo.sysobjects where name='##tmpAsientosContaTransf' +@NombrePC)
  exec('drop table ##tmpAsientosContaTransf' +@NombrePC)

set @cadAsientos='
  select empresacodigo,cabrec_numrecibo=cabrec_numreciboegreso,detrec_item,MonedaCodigo,detrec_tipodoc_concepto,
			detrec_numdocumento,clientecodigo,cuenta,detrec_observacion,
         FechaEmision,FechaCancela,TipoCambio,DebeS,HaberS,DebeD,HaberD,
         ImporteSol,ImporteDolar,ImporteSoles
		into ##tmpAsientosContaTransf' +@NombrePC+ ' 
  from 
		##tmpAsientosTransf' +@NombrePC 
execute(@cadAsientos)
--exec te_GeneraTempContableTransf 'camtex_tinto','Contaprueba','776101','976101','Desarrollo3','04','2003'















set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
