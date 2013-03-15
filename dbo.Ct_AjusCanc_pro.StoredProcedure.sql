SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop    Proc Ct_AjusCanc_pro
*/
CREATE      Proc [Ct_AjusCanc_pro]
@Servidor         Varchar(50),         
@Base             Varchar(50), 
@empresa 	  varchar(2),
@Ano              Varchar(4),
@Mes              Varchar(2),
@Asiento          Varchar(3),
@SubAsiento       Varchar(4),
@User 			  Varchar(50)     
/*
Set @Servidor='Desarrollo4'
Set @Base='CONTAPRUEBA' 
Set @Mes='09'
Set @Ano='2002' 
Set @Asiento='060'
Set @SubAsiento='0002'
Set @User='Hola'
*/
AS
Declare @SqlCad1 Varchar(8000),@SqlCad2 varchar(8000)
Set @SqlCad1='
Declare
@CtaAjusteGanacia varchar(20),
@CtaAjustePerdida varchar(20),
@NumComprob Varchar(20),
@Maximo Int
SET NOCOUNT ON
Select @Maximo=Isnull(Max(Cast(Right(cabcomprobnumero,5) as Int)),0)+1 from '+'['+@Base+'].dbo.ct_cabcomprob'+@ano+'
Where empresacodigo='''+@empresa+''' and asientocodigo='''+@Asiento+'''
Select @Maximo=
         Case When isnull(asientonumcorr'+@Mes+',0)+1 > @Maximo 
         Then isnull(asientonumcorr'+@Mes+',0)+1 else @Maximo end 
         from ''['+@Base+'].dbo.ct_Asiento  
Where empresacodigo='''+@empresa+''' and asientocodigo='''+@Asiento+'''
Set @NumComprob='''+@mes+@Asiento+'''+replicate(''0'',5-len(@Maximo))+rtrim(Cast(@Maximo as varchar(5)))
select @CtaAjusteGanacia=sistemactaajustehab,@CtaAjustePerdida=sistemactaajustedeb 
from ''['+@Base+'].dbo.ct_sistema where empresacodigo='''+@empresa+''' 
Declare @UtimaFechaMes as datetime
Set @UtimaFechaMes=dateadd(day,-1,cast('+Cast(dbo.fn_datenumber(1,(cast(@mes as int)+1),(cast(@Ano as int))) as Varchar(10))+' as datetime))
Select *, 
	Cuenta=Case when indi in(''H'',''D'') then 
				Case when indi=''H'' then	
		             case when DiferxCambio < 0  then @CtaAjustePerdida  else @CtaAjusteGanacia end 
        		  Else
              		case when DiferxCambio < 0 then @CtaAjusteGanacia  else @CtaAjustePerdida end
                end       
           Else cuentacodigo End,            
    Debe=Abs(Case when indi in(''H'',''D'') then 			 	
			   Case When indi=''H'' then  	
        	   		case when DiferxCambio < 0 then DiferxCambio  else 0 end 
                 Else
                    case when DiferxCambio > 0 then DiferxCambio  else 0 end 
               End                 
            else  
			   Case When detcomprobhaber > 0  then  	
        	   		case when DiferxCambio < 0 then 0  else  DiferxCambio end 
                 Else
                    case when DiferxCambio > 0 then 0 else DiferxCambio end 
               End                               
		  End),               	
    Haber=Abs(Case when indi in(''H'',''D'') then 			 	
			   Case When indi=''D'' then  	
        	   		case when DiferxCambio < 0 then DiferxCambio  else 0 end 
                 Else
                    case when DiferxCambio > 0 then DiferxCambio  else 0 end 
               End                 
            else  
			   Case When detcomprobhaber > 0  then  	
        	   		case when DiferxCambio < 0 then DiferxCambio  else 0   end 
                 Else
                    case when DiferxCambio > 0 then DiferxCambio else 0  end 
               End                               
		  End), 
  ID=IDENTITY(int, 1,1) 	
  INTO #tempoAjuste  
from	
(Select 
	AA.*,
    ValorSuma=Case When detcomprobhaber > 0 
                   then isnull(Sdebe,0)
                   Else isnull(Shaber,0) end +
                 Case When detcomprobhaber > 0 
                   then isnull(SajusteHaber,0) - isnull(SajusteDebe,0)
                 Else isnull(SajusteDebe,0) - isnull(SajusteHaber,0)  end,
    Valor=Case When  detcomprobhaber > 0 
						then  detcomprobhaber
               Else detcomprobdebe End, 
    DiferxCambio=(Case When  detcomprobhaber > 0 
						then  detcomprobhaber
                	   Else detcomprobdebe End 
                   -                 
                 (Case When detcomprobhaber > 0 
                   then isnull(Sdebe,0)
                   Else isnull(Shaber,0) end +
                 Case When detcomprobhaber > 0 
                   then isnull(SajusteHaber,0) - isnull(SajusteDebe,0)
                 Else isnull(SajusteDebe,0) - isnull(SajusteHaber,0)  end))*-1 
From 
(
select A.*,
      Indi=''C''   
from ''['+@Base+'].dbo.ct_detcomprob'+@ano+' A,'+'['+@Base+'].dbo.ct_cuenta B
where
	a.empresacodigo=b.empresacodigo and
        A.cuentacodigo=B.cuentacodigo And 
	B.tipoajuste=''01'' and A.monedacodigo=''02'' and 	
	operacioncodigo=''01'' and 
        a.empresacodigo='''+@empresa+'''
	
Union 
All
select A.*,
	   Indi=Case when detcomprobdebe >0 then ''D'' else ''H'' end 	
from  '+'['+@Base+'].dbo.ct_detcomprob'+@ano+' A,'+'['+@Base+'].dbo.ct_cuenta B
where
	a.empresacodigo='''+@empresa+''' and
	a.empresacodigo=b.empresacodigo and
        A.cuentacodigo=B.cuentacodigo And 
	B.tipoajuste=''01'' and A.monedacodigo=''02'' and 	
	operacioncodigo=''01''  ) as AA,
    (select A.analiticocodigo,	   
	   A.documentocodigo,A.detcomprobnumdocumento,	
	   Sdebe=Sum((Case When A.detcomprobussdebe > 0 and A.detcomprobdebe > 0 then A.detcomprobdebe else 0 end)),
       Shaber=Sum((Case When A.detcomprobusshaber > 0 and A.detcomprobhaber > 0 then A.detcomprobhaber else 0 end)), 
	   Sdebeuss=Sum((Case When A.detcomprobdebe  > 0 and A.detcomprobussdebe > 0 then A.detcomprobussdebe else 0 end)),
	   Shaberuss=Sum((Case When A.detcomprobhaber  > 0 and A.detcomprobusshaber > 0 then A.detcomprobusshaber else 0 end)),	
       SajusteDebe=Sum((Case When A.detcomprobdebe > 0 and A.detcomprobussdebe=0  then A.detcomprobdebe else 0 end)),
	   SajusteHaber=Sum((Case When A.detcomprobhaber  > 0 and A.detcomprobusshaber=0 then A.detcomprobhaber else 0 end))				             
	   from '+'['+@Base+'].dbo.ct_detcomprob'+@Ano+' A,'+'['+@Base+'].dbo.ct_cuenta B        
	where
	a.empresacodigo='''+@empresa+''' and
	a.empresacodigo=b.empresacodigo and
        A.cuentacodigo=B.cuentacodigo and 
    	B.tipoajuste=''01'' and operacioncodigo <>''01'' 
        and A.cabcomprobmes <='+@Mes+'
 
	Group by A.analiticocodigo,	   
	     A.documentocodigo,A.detcomprobnumdocumento
) as BB
	Where 
    AA.analiticocodigo=BB.analiticocodigo and 
    AA.documentocodigo=BB.documentocodigo and   
    AA.detcomprobnumdocumento=BB.detcomprobnumdocumento and
    AA.cabcomprobmes <='+@Mes+' and 
    (case when detcomprobusshaber > 0 then detcomprobusshaber else detcomprobussdebe end)- 
    (case when detcomprobusshaber > 0 then isnull(Sdebeuss,0) else isnull(Shaberuss,0)end)=0 and     
    (case when detcomprobhaber > 0 then detcomprobhaber else detcomprobdebe end)- 
    (case when detcomprobhaber > 0 then isnull(Sdebe,0) else isnull(Shaber,0)end+ 
     Case When detcomprobhaber > 0 then isnull(SajusteHaber,0)- isnull(SajusteDebe,0) 
                            Else isnull(SajusteDebe,0) - isnull(SajusteHaber,0)  end)     
    <>0 
 ) as ZZ
Order by ZZ.documentocodigo,ZZ.detcomprobnumdocumento 
'
Set @SqlCad2='
If (select count(*) from #tempoAjuste where DiferxCambio <> 0  )=0  
Begin
	Select Msg=''No Existen Registro para Ajustar'' 
End 
Else
Begin
/*Generar  Cabecera de Comprobante*/
	Insert Into '+/*['+@Servidor+'].*/'['+@Base+'].dbo.ct_cabcomprob'+@ano+'
	(empresacodigo,cabcomprobmes, cabcomprobnumero,asientocodigo, subasientocodigo,
	 cabcomprobfeccontable,cabcomprobglosa,cabcomprobtotdebe, cabcomprobtothaber, 
	 cabcomprobtotussdebe, cabcomprobtotusshaber, cabcomprobgrabada, cabcomprobnref,
	 estcomprobcodigo,cabcomprobobservaciones,usuariocodigo, fechaact) 
	Select '+@empresa+','+@mes+',@NumComprob,'''+@asiento+''','''+@subasiento+''',@UtimaFechaMes,''AJUSTE DE CANCELADOS '+@MES+''',
	       sum(Debe),sum(Haber),0,0,0,'''',''03'','''','''+@User+''',getdate() 	
	From #tempoAjuste
	/*Fin de Generar Cabecera*/
	/*Generar Detalle*/
	Insert Into '+/*['+@Servidor+'].*/'['+@Base+'].dbo.ct_detcomprob'+@Ano+'
	(empresacodigo,cabcomprobmes, cabcomprobnumero,asientocodigo,subasientocodigo,detcomprobitem,
	 analiticocodigo,detcomprobruc,monedacodigo, centrocostocodigo,
	 operacioncodigo,cuentacodigo, 
	 documentocodigo,detcomprobnumdocumento,detcomprobfechaemision,detcomprobfechavencimiento,
	 detcomprobglosa, detcomprobdebe, detcomprobhaber, detcomprobusshaber, detcomprobussdebe,
	 detcomprobtipocambio,detcomprobauto, detcomprobformacambio,
	 detcomprobajusteuser, plantillaasientoinafecto, tipdocref, detcomprobnumref,
	 detcomprobconci)
	
	select '+@empresa+','+@mes+',@NumComprob,'''+@asiento+''','''+@subasiento+''',
        detcomprobitem=Replicate(''0'',5-len(id)) + rtrim(cast((id) as varchar(5))),  
	analiticocodigo,detcomprobruc,''01'',''00'',
	''02'',Cuenta,
	documentocodigo,detcomprobnumdocumento,@UtimaFechaMes,Null, 
	''AJUSTE DE CANCELADOS '+@MES+''', Debe, Haber, 0,0,
	0,0,''02'',
	0,0,''00'' , '''', null
	from #tempoAjuste
	/*Fin de Generar Detalle*/ 
	Update '+'['+@Base+'].dbo.ct_Asiento
	Set asientonumcorr'+@mes+'=@Maximo
	Where empresacodigo='''+@empresa+''' and asientocodigo='''+@Asiento+'''
End 
SET NOCOUNT OFF
'
Execute (@SqlCad1+@SqlCad2)
GO
