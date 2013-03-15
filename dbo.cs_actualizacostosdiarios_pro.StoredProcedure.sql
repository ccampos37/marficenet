SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_actualizacostosdiarios_pro 'planta10','planta_casma','10/01/2009','10/01/2009','1',2.8,'01',1
select * from ##resumenxmesplantillas
select * from ##_resumenxdiaplantillas
drop table ##tempo
*/

CREATE                           PROC [cs_actualizacostosdiarios_pro]

@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='1',
@tipocambio varchar(10)='1',
@moneda varchar(2)='01',
@dias integer=1

as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)
declare @totalingresos float ,@totalegresos float
set @anno=year(@fechaini)
set @mes =month(@fechaini)

If Exists(Select name from tempdb..sysobjects where name='##resumenxmesplantillas') 
    Drop Table ##resumenxmesplantillas 

If Exists(Select name from tempdb..sysobjects where name='##_resumenxdiaplantillas') 
    Drop Table ##_resumenxdiaplantillas 

If Exists(Select name from tempdb..sysobjects where name='##xx') 
    Drop Table ##xx 

execute cs_actualizadiariopersonal_pro @baseorigen,@basedestino,@fechaini,@fechafin,@dias,@tipo


set @sql=' select n1=left(a.estructuranumerolinea ,2),grupo1=(select estructuradescripcion 
from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),grupo2=(select estructuradescripcion 
from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),zz.tipo,
a.estructuranumerolinea, a.estructuradescripcion,zz.gastoscodigo,zz.gastosdescripcion,zz.referencia,
importesoles = zz.soles,importedolares=zz.dolares,porcentaje=00.00,zz.dia
into '+@basedestino+'.dbo.##resumenxmesplantillas 
 from '+@basedestino+'.dbo.cs_estructurapresentacion a  left join  
--- gastos x provisiones
(select tipo=''E'',dia=z.cabprovifchdoc, z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(dolares) from
(   select cabprovifchdoc,soles=case monedacodigo when ''02'' then (detprovitotal-detproviimpigv)* tipocambiocompra else  (detprovitotal-detproviimpigv) end,
           dolares=case monedacodigo when ''01'' then (detprovitotal-detproviimpigv)/ tipocambiocompra else  (detprovitotal-detproviimpigv) end,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.co_cabeceraprovisiones a 
   inner join '+@basedestino+'.dbo.co_detalleprovisiones b on a.empresacodigo=b.empresacodigo and a.cabproviano=b.cabproviano and a.cabprovinumero=b.cabprovinumero
   inner join '+@basedestino+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio d on a.cabprovifchdoc=d.tipocambiofecha
   where cabprovifchdoc between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabproviestado,'' '')='' '' and left(b.gastoscodigo,2) not in (''01'',''02'',''07'')
) as z group by z.cabprovifchdoc,z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion
union all
--- materiales de almacen
select tipo=''E'',dia=cafecdoc,c.estructuranumerolinea,c.centro_costo,rtrim(acodigo)+ '' - ''+rtrim(adescri)+ ''  '' + aunidad,referencia=sum(decantid),
   soles=sum(isnull(deprecio,0)*decantid),dolares=sum(isnull(deprecio,0)*decantid/tipocambiocompra)
   from '+@basedestino+'.dbo.movalmdet a 
   inner join '+@basedestino+'.dbo.movalmcab b  on a.dealma=b.caalma and a.detd=catd and denumdoc=canumdoc
   inner join '+@baseorigen+'.dbo.centro_costo c on a.decencos1=c.id_centro_costo
   inner join '+@basedestino+'.dbo.tabalm on dealma=taalma
   inner join '+@basedestino+'.dbo.maeart on decodigo=acodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio f on b.cafecdoc=f.tipocambiofecha
   where cafecdoc between '''+@fechaini+''' and '''+@fechafin+'''  and casitgui<>''A''  
group by cafecdoc,estructuranumerolinea,c.centro_costo,adescri,aunidad,acodigo

union all 
--kilos
select tipo=''I'',dia=convert(smalldatetime, convert(varchar(10), a.fecha_proceso, 103), 103),a=''010101'',lin_nombre,d.adescri,referencia=c.id_producto_obtenido,
  y=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida/144*5.5 end),
  z=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida/144*5.5 end)
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
left join '+@basedestino+'.dbo.lineas e on d.afamilia=e.fam_codigo and d.alinea=e.lin_codigo
--left join '+@baseorigen+'.dbo.concepto_pago f on c.id_producto_obtenido=f.id_concepto

where convert(smalldatetime, convert(varchar(10), a.fecha_proceso, 103), 103) between '''+@fechaini+''' and '''+@fechafin+'''
and  a.id_planta=''01'' and c.item_insertarloteincompleto=0 and c.item_momentaneo=0 and c.item_inc_transferencia=0
group by convert(smalldatetime, convert(varchar(10), a.fecha_proceso, 103), 103),lin_nombre,id_producto_obtenido,adescri 
union all  '

set @sql1 = '
-- personal de destajo
select tipo=''E'', a.dia,a.estructuranumerolinea,a.descripcion,''100,00'',00.00,
   soles=  round(sum(total),2),00.00
  FROM '+@baseorigen+'.dbo.##xx a  
group by   a.dia,a.estructuranumerolinea,a.descripcion
union all
/*
select tipo=''E'',a.dia, a.estructuranumerolinea,a.descripcion,''100.00'',00.00,
   soles=  round(sum(total),2),00.00
  FROM '+@baseorigen+'.dbo.##xx a  where a.tipo=''01''
group by   a.dia,a.estructuranumerolinea,a.descripcion
union all

-- essalud
select tipo=''E'', ''030503'' ,d.empresadescripcion,g.grupo_ocupacional,00.00,
   soles=  round(sum(aport_essalud),2),dolares=round(sum(aport_essalud),2)/(cast('+@tipocambio+' as float))
  FROM '+@baseorigen+'.dbo.planilla_mensual a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d on right( rtrim(c.id_empresa),2)=d.empresacodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 group by   d.empresadescripcion,g.grupo_ocupacional
union all
*/
select tipo=''E'', z.detrec_fechacancela,z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(z.dolares) from
(   select soles=detrec_importesoles  , dolares=detrec_importedolares,
   b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.te_cabecerarecibos a 
   inner join '+@basedestino+'.dbo.te_detallerecibos b  on a.cabrec_numrecibo=b.cabrec_numrecibo 
   inner join '+@basedestino+'.dbo.co_gastos c on b.detrec_gastos=c.gastoscodigo
   where detrec_fechacancela between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabrec_estadoreg,'' '')='' '' and left(c.gastoscodigo,2) in (''09'')
) as z group by z.detrec_fechacancela,z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion 
) as zz on a.estructuranumerolinea=zz.estructuranumerolinea where estructuranivel=3 
'
EXECUTE(@sql+@sql1)

set @sql= ' select top 0 * into '+@basedestino+'.dbo.##_resumenxdiaplantillas 
from '+@basedestino+'.dbo.cs_resumenxmesplantillas where mesproceso =
ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) 

insert '+@basedestino+'.dbo.##_resumenxdiaplantillas 
select x=ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)),* 
from '+@basedestino+'.dbo.##resumenxmesplantillas 

update '+@basedestino+'.dbo.##_resumenxdiaplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles)*1.00  
from '+@basedestino+'.dbo.##_resumenxdiaplantillas where tipo=''I'' and 
    mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''I''

update '+@basedestino+'.dbo.##_resumenxdiaplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles)*1.00  
from '+@basedestino+'.dbo.##_resumenxdiaplantillas
        where tipo=''E'' and  mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''E'''

execute (@sql)

if @tipo=1
begin
set @sql='select tipomov=isnull(tipo,''X''),
             importes=case when '''+@moneda+'''=''01'' then isnull(importesoles,0) 
                     else isnull(importedolares,0) end,
              * from '+@basedestino+'.dbo.##_resumenxdiaplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  
 order  by n1,n2,estructuranumerolinea '

execute(@sql)
end
GO
