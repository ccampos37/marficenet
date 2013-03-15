SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute te_cierrecajabancos_pro 'pam','01','C','%%','%%','200801','200802','##xx4','01/01/2008','31/01/2008','3'

select * from planta_casma.dbo.te_saldosmensuales where empresacodigo='02' and tipocajabanco='C' and mesproceso='200801'
select * from planta_casma.dbo.te_saldosmensuales where empresacodigo='02' and tipocajabanco='C' and mesproceso='200802'

SELECT * FROM ##xx4 delete bmc.dbo.te_SALDOSMENSUALES
delete [bmc].dbo.te_saldosmensuales where empresacodigo='01' and tipocajabanco='B' and mesproceso >='200801' 


*/

CREATE      proc [te_cierrecajabancos_pro]

--Declare
    @base varchar(50),
    @empresa varchar(2),
    @tipo  varchar(1),
    @cajabanco varchar(2),
    @ctamoneda varchar(30),
    @mesactual varchar(6),
    @mesnuevo varchar(6),
    @computer varchar(50),
    @fechaini varchar(10),
    @fechafin varchar(10),
    @cierre varchar(1)='0'
as
declare @cadsql varchar(5000)



If @cierre<>'3'
begin  
Set @cadsql='If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
               Drop Table '+@computer+'' 
execute(@cadsql)

set @cadsql='Select descripcion= case when z1.tipocajabanco=''C'' then
               cajadescripcion else cbanco_referenciacta end,z1.*  into '+@computer+'  from
(  select z2.empresacodigo,z2.tipocajabanco,z2.cajabanco,z2.moneda,z2.yy,
               saldoinicial=sum(z2.saldoinicial),totalIngresos=sum(z2.totalIngresos),
	       totalegresos=sum(z2.totalegresos),saldofinal=sum(z2.saldofinal)
   from 
 ( ( select  zz.empresacodigo,zz.tipocajabanco,zz.cajabanco,zz.moneda,zz.monedacodigo,zz.detrec_numctacte,zz.yy,
           saldoinicial=0,
           totalIngresos=round(case when zz.monedacodigo=''01'' then solesingresos else dolaresingresos end,2),
           totalegresos= round(case when zz.monedacodigo=''01'' then solesegresos else dolaresegresos end,2) , 
           saldofinal =case when  zz.monedacodigo=''01'' then round(solesingresos,2)-round(solesegresos,2) 
                             else round(dolaresingresos,2)-round(dolaresegresos,2) end  
           from ( select b.empresacodigo,tipocajabanco=a.detrec_tipocajabanco,cajabanco=a.detrec_cajabanco1, moneda=a.ctamoneda,
		monedacodigo=a.detrec_monedacancela,a.detrec_numctacte,yy,
              	solesingresos = round(sum(case when a.detrec_monedacancela=''01'' then case when b.cabrec_ingsal=''I'' then a.detrec_importesoles else 0 end else 0 end),2) ,
		solesegresos = round(sum(case when a.detrec_monedacancela=''01'' then case when b.cabrec_ingsal=''E'' then a.detrec_importesoles else 0 end else 0 end),2) ,
		dolaresingresos = round(sum(case when a.detrec_monedacancela=''02'' then case when b.cabrec_ingsal=''I'' then a.detrec_importedolares else 0 end else 0 end),2),
		dolaresegresos = round(sum(case when a.detrec_monedacancela=''02'' then case when b.cabrec_ingsal=''E'' then a.detrec_importedolares else 0 end else 0 end),2)
		from ( select '''+@mesactual +''' as yy,ctamoneda= (case when detrec_tipocajabanco=''C'' then a.detrec_monedacancela else a.detrec_numctacte end ),a.* 
			from [' +@base+ '].dbo.te_detallerecibos a where  isnull(detalle_no_saldos,0)<>1 and Detrec_fechacancela between ''' +@fechaini+ ''' and '''+@fechafin+'''
				and detrec_tipocajabanco = '''+@tipo+''' and detrec_cajabanco1 like '''+@cajabanco+''''
                  			If @tipo='C' set @cadsql=@cadsql+ ' and detrec_monedacancela like '''+@ctamoneda+''' ) as a '
				If @tipo='B' set @cadsql=@cadsql+ ' and detrec_numctacte like '''+@ctamoneda+''' ) as a '
set @cadsql=@cadsql+ ' inner join [' +@base+ '].dbo.te_cabecerarecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo 
			where isnull(b.cabrec_estadoreg,0)<>1 and b.empresacodigo='''+@empresa+''' 
			group by b.empresacodigo,yy,a.detrec_tipocajabanco,a.detrec_cajabanco1,a.ctamoneda ,a.detrec_numctacte,a.detrec_monedacancela  	) zz )
     union
    ( select empresacodigo,tipocajabanco,CajaBancoCodigo,MonedaCuenta, MonedaCuenta,'''', mesproceso ,
 			saldoinicial,0,0,saldofinal=saldoinicial
                   from [' +@base+ '].dbo.te_saldosmensuales Where empresacodigo='''+@empresa+''' and mesproceso='''+@mesactual +''' ) 
 ) z2 Group by z2.empresacodigo,z2.tipocajabanco,z2.cajabanco,z2.moneda,z2.yy) z1
left join [' +@base+ '].dbo.te_codigocaja c on z1.cajabanco=c.cajacodigo 
                     and z1.tipocajabanco=''C''
left join [' +@base+ '].dbo.te_cuentabancos d on z1.cajabanco=d.cbanco_codigo 
       	             and z1.moneda=d.cbanco_numero and z1.tipocajabanco=''B'' '
execute(@cadsql)

end
   
If @cierre='0'  --un solo registro
begin
   Set @cadsql=' delete ['+@base+'].dbo.te_saldosmensuales where  empresacodigo='''+@empresa+''' and tipocajabanco='''+@tipo+''' and cajabanco='+@cajabanco+' 
                      and monedacuenta='+@ctamoneda+' and mesproceso >='''+@mesactual+''''
   execute(@cadsql)

end
If @cierre='1' and @tipo='C'   --todos los registros
begin
   Set @cadsql=' delete  ['+@base+'].dbo.te_saldosmensuales 
               where empresacodigo='''+@empresa+''' and tipocajabanco='''+@tipo+''' 
               and mesproceso >='''+@mesactual+''' '
   
execute(@cadsql)
end
If @cierre='1' and @tipo='B'   --todos los registros
begin
   Set @cadsql=' delete ['+@base+'].dbo.te_saldosmensuales where empresacodigo='''+@empresa+''' and tipocajabanco='''+@tipo+''' 
                 and mesproceso >='''+@mesactual+''''
execute(@cadsql)
end


If @cierre='3'  ---cierre del mes
begin
set @cadsql=' insert into ['+@base+'].dbo.te_saldosmensuales 
              ( empresacodigo,tipocajabanco,CajaBancoCodigo,MonedaCuenta,mesproceso ,Monedacodigo,
 		saldoinicial, ingresosmes, egresosmes, fechaact,usuariocodigo )
		select empresacodigo,tipocajabanco,cajabanco,moneda,yy,moneda,
		isnull(saldoinicial,0),isnull(totalIngresos,0),isnull(totalegresos,0),getdate(),''sa''
               from '+@computer+'' 
set @cadsql=@cadsql+ ' insert into ['+@base+'].dbo.te_saldosmensuales  
             ( empresacodigo,tipocajabanco,CajaBancoCodigo,Monedacuenta,mesproceso ,Monedacodigo,
 		saldoinicial, ingresosmes, egresosmes, fechaact,usuariocodigo )
			select empresacodigo,tipocajabanco,cajabanco,moneda,'''+@mesnuevo+''',moneda,
		saldo=isnull(saldoinicial,0)+isnull(totalIngresos,0)-isnull(totalegresos,0),0,0,getdate(),''sa''
               from '+@computer+'' 

EXECUTE(@cadsql)

end

SET QUOTED_IDENTIFIER OFF
GO
