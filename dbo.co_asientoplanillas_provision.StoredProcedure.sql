SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_actualizacostos_pro 'planta10','planta_casma','01/01/2008','31/01/2008','1',2.93,'01'

select * from ##resumenxmesplantillas order by gastosdescripcion
*/
CREATE PROC [co_asientoplanillas_provision]

@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='1',
@tipocambio varchar(10)='1',
@moneda varchar(2)='01'

as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)
declare @totalingresos float ,@totalegresos float
set @anno=year(@fechaini)
set @mes =month(@fechaini)

If Exists(Select name from tempdb..sysobjects where name='##resumenxmesplantillas') 
    Drop Table ##resumenxmesplantillas 

set @sql=' select n1=left(a.estructuranumerolinea ,2),grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),zz.tipo,
a.estructuranumerolinea, a.estructuradescripcion,zz.gastoscodigo,zz.gastosdescripcion,zz.referencia,
importesoles = zz.soles,importedolares=zz.dolares
into '+@basedestino+'.dbo.##resumenxmesplantillas 
 from '+@basedestino+'.dbo.cs_estructurapresentacion a  left join  
--- gastos x provisiones
(select tipo=''E'', z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(dolares) from
(   select soles=case monedacodigo when ''02'' then (detprovitotal-detproviimpigv)* tipocambiocompra else  (detprovitotal-detproviimpigv) end,
           dolares=case monedacodigo when ''01'' then (detprovitotal-detproviimpigv)/ tipocambiocompra else  (detprovitotal-detproviimpigv) end,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.co_cabeceraprovisiones a 
   inner join '+@basedestino+'.dbo.co_detalleprovisiones b on a.empresacodigo=b.empresacodigo and a.cabproviano=b.cabproviano and a.cabprovinumero=b.cabprovinumero
   inner join '+@basedestino+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio d on a.cabprovifchdoc=d.tipocambiofecha
   where cabprovifchdoc between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabproviestado,'' '')='' '' and left(b.gastoscodigo,2) not in (''01'',''02'',''07'')
) as z group by z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion
union all 
--kilos
select tipo=''I'',a=''010101'',lin_nombre,d.adescri,referencia=0.00,
  y=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida/144*5.5 end),
  z=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida/144*5.5 end)
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
left join '+@basedestino+'.dbo.lineas e on d.afamilia=e.fam_codigo and d.alinea=e.lin_codigo
where a.fecha_produccion >= '''+@fechaini+''' and a.fecha_proceso <='''+@fechafin+''' and id_unidad_medida_obt=4
group by lin_nombre,id_producto_obtenido,adescri 
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
select tipo=''E'', z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(z.dolares) from
(   select soles=detrec_importesoles  , dolares=detrec_importedolares,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.te_cabecerarecibos a 
   inner join '+@basedestino+'.dbo.te_detallerecibos b  on a.cabrec_numrecibo=b.cabrec_numrecibo 
   inner join '+@basedestino+'.dbo.co_gastos c on b.detrec_gastos=c.gastoscodigo
   where detrec_fechacancela between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabrec_estadoreg,'' '')='' '' and left(b.gastoscodigo,2) in (''09'')
) as z group by z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion 
) as zz on a.estructuranumerolinea=zz.estructuranumerolinea where estructuranivel=3 
'
execute(@sql+@sql1)
GO
