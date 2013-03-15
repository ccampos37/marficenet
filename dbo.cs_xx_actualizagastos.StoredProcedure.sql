SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_actualizagastos 'planta10','planta_casma','01/02/2008','29/02/2008','1'
select decencos,* from planta_casma.dbo.movalmdet where decodigo='10342'
*/
CREATE                  PROC [cs_xx_actualizagastos]
@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='1'
as
declare  @sql varchar(8000),@sql1 varchar(8000)
declare @anno varchar(4),@mes varchar(2)
declare @totalingresos float ,@totalegresos float
set @anno=year(@fechaini)
set @mes =month(@fechaini)

If Exists(Select name from tempdb..sysobjects where name='##resumenxmesplantillas') 
    Drop Table ##resumenxmesplantillas 


set @sql=' select n1=left(a.estructuranumerolinea ,2),
grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),
grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),zz.tipo,
a.estructuranumerolinea, a.estructuradescripcion,zz.gastoscodigo,zz.gastosdescripcion,zz.referencia,importe = zz.y
into '+@basedestino+'.dbo.##resumenxmesplantillas 
 from '+@basedestino+'.dbo.cs_estructurapresentacion a '
if @tipo='1'  set @sql=@sql +' left join '
if @tipo='2'  set @sql=@sql + 'inner join '
set @sql = @sql + ' 
--- gastos x provisiones
(select tipo=''E'', z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion,referencia=0.00,y=sum(z.soles) from
(   select soles=case monedacodigo when ''02'' then 
                        (detprovitotal-detproviimpigv)* tipocambiocompra   
                  else  (detprovitotal-detproviimpigv) end,
                  dolares=case monedacodigo when ''01'' then 
                        (detprovitotal-detproviimpigv)/ tipocambiocompra   
                  else  (detprovitotal-detproviimpigv) end,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.co_cabeceraprovisiones a 
   inner join '+@basedestino+'.dbo.co_detalleprovisiones b
         on a.empresacodigo=b.empresacodigo and a.cabproviano=b.cabproviano and a.cabprovinumero=b.cabprovinumero
   inner join '+@basedestino+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio d on a.cabprovifchdoc=d.tipocambiofecha
   where cabprovifchconta between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabproviestado,'' '')='' ''
   and left(b.gastoscodigo,2) not in (''01'',''02'',''07'')
) as z group by z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion
union all
--- materiales de almacen
select tipo=''E'',c.estructuranumerolineaMateriales,decodigo,adescri,referencia=sum(decantid),y=sum(isnull(deprecio,0)*decantid) from '+@basedestino+'.dbo.movalmdet a 
   inner join '+@basedestino+'.dbo.movalmcab b
         on a.dealma=b.caalma and a.detd=catd and denumdoc=canumdoc
   inner join '+@basedestino+'.dbo.ct_centrocosto c
         on dealma=c.empresacodigo and a.decencos=c.centrocostocodigo
   inner join '+@basedestino+'.dbo.tabalm on dealma=taalma
   inner join '+@basedestino+'.dbo.maeart on decodigo=acodigo
   where cafecdoc between '''+@fechaini+''' and '''+@fechafin+''' 
   and casitgui<>''A''  group by estructuranumerolineaMateriales,decodigo,adescri
union all 
--kilos
select tipo=''I'',a=''010101'',lin_nombre,d.adescri,referencia=0.00,y=sum(cantidad_obtenida)
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
left join '+@basedestino+'.dbo.lineas e on d.afamilia=e.fam_codigo and d.alinea=e.lin_codigo
where a.fecha_produccion >= '''+@fechaini+''' and a.fecha_proceso <='''+@fechafin+''' 
     and id_unidad_medida_obt=4
group by lin_nombre,id_producto_obtenido,adescri 
union all  
--- unidades
select tipo=''I'',a=''010101'',lin_nombre,d.adescri,referencia=0.00,y=sum(cantidad_obtenida/144*5.5)
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
left join '+@basedestino+'.dbo.lineas e on d.afamilia=e.fam_codigo and d.alinea=e.lin_codigo
where a.fecha_produccion >= '''+@fechaini+''' and a.fecha_proceso <='''+@fechafin+''' 
     and id_unidad_medida_obt=1
group by lin_nombre,id_producto_obtenido,adescri 
union all '
set @sql1 = '
select tipo=''E'', e.lineaestructuranumero,d.centro_costo,g.grupo_ocupacional,referencia=count(*),
   total=  round(sum(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones + importe_vacaciones_compradas),2)
  FROM '+@baseorigen+'.dbo.planilla_mensual a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
       inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
       inner join '+@baseorigen+'.dbo.centro_costo d on  b.id_centro_costo = d.id_centro_costo 
       inner join '+@basedestino+'.dbo.cs_procesos e on d.id_centro_costo=e.procesocodigo
       inner join '+@basedestino+'.dbo.ct_centrocosto f 
          on right( rtrim(c.id_empresa),2)=f.empresacodigo and d.equivalencia = f.centrocostocodigo 
       inner join '+@baseorigen+'.dbo.Grupo_ocupacional g on b.id_grupo=g.id_grupo 
   WHERE  a.mes ='+@mes+'  AND ( a.anio ='+@anno+')  and b.condicion_personal = 1 
        and patindex(''%''+a.id_tipo_trabajador_pago+''%'',f.tipotrabajdor) = 0
group by  e.lineaestructuranumero,d.centro_costo,g.grupo_ocupacional
union all
-- personal de destajo
select tipo=''E'', e.estructuranumerolinea,d.centro_costo,f.grupo_ocupacional,referencia=count(*),
   total=  round(sum(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones + importe_vacaciones_compradas),2)
  FROM '+@baseorigen+'.dbo.planilla_mensual a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
       inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
       inner join '+@baseorigen+'.dbo.centro_costo d on  b.id_centro_costo = d.id_centro_costo 
       inner join '+@basedestino+'.dbo.ct_centrocosto e
           on right( rtrim(c.id_empresa),2)=e.empresacodigo and d.equivalencia = e.centrocostocodigo  
       inner join '+@baseorigen+'.dbo.Grupo_ocupacional f on b.id_grupo=f.id_grupo 
   WHERE  a.mes ='+@mes+'  AND ( a.anio ='+@anno+')  and b.condicion_personal = 1 
        and patindex(''%''+a.id_tipo_trabajador_pago+''%'',e.tipotrabajdor) > 0
group by   e.estructuranumerolinea,d.centro_costo,f.grupo_ocupacional
union all
-- essalud
select tipo=''E'', ''030503'' ,d.empresadescripcion,
     id_tipo_trabajador_pago= case a.id_tipo_trabajador_pago  when ''01'' then 
                                 ''DESTAJO'' else
                                   case a.id_tipo_trabajador_pago when ''02'' then ''JORNAL'' 
                               else '' EMPLEADO '' end end ,00.00,
   total=  round(sum(aport_essalud),2)
  FROM '+@baseorigen+'.dbo.planilla_mensual a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d
           on right( rtrim(c.id_empresa),2)=d.empresacodigo   
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 
group by   d.empresadescripcion,a.id_tipo_trabajador_pago
union all
select tipo=''E'', z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,y=sum(z.soles) from
(   select soles=detrec_importesoles  ,
           dolares=detrec_importedolares,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.te_cabecerarecibos a 
   inner join '+@basedestino+'.dbo.te_detallerecibos b
         on a.cabrec_numrecibo=b.cabrec_numrecibo 
   inner join '+@basedestino+'.dbo.co_gastos c on b.detrec_gastos=c.gastoscodigo
   where detrec_fechacancela between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabrec_estadoreg,'' '')='' ''
   and left(b.detrec_gastos,2)  in (''09'')
   
) as z 
group by z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion 
) as zz
on a.estructuranumerolinea=zz.estructuranumerolinea where estructuranivel=3 
'
execute(@sql+@sql1)

set @sql= ' delete '+@basedestino+'.dbo.cs_resumenxmesplantillas where mesproceso =
ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) 

insert '+@basedestino+'.dbo.cs_resumenxmesplantillas 
select x=ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)),* ,0.00
from '+@basedestino+'.dbo.##resumenxmesplantillas 

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importe/(select x=sum(importe)*1.00  from '+@basedestino+'.dbo.cs_resumenxmesplantillas where tipo=''I'' and 
    mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''I''

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importe/(select x=sum(importe)*1.00  from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
                                where tipo=''E'' and  mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''E'''

execute (@sql)

set @sql='select * from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  '
execute(@sql)
GO
