SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_actualizacostos_pro 'planta10','planta_casma','01/07/2010','31/07/2010','1',2.93,'01'
select decencos,* from planta_casma.dbo.movalmdet where decodigo='10342'
select * from .planta10.dbo.planilla_mensu
select * from ##xx

where mesproceso='200811' and estructuranumerolinea='030503' order by gastosdescripcion


*/

create PROC [cs_actualizacostos_bak_pro]

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
declare @anno2 varchar(4),@mes2 varchar(2)
declare @meses as varchar(20)
declare @totalingresos float ,@totalegresos float
set @anno=year(@fechaini)
set @mes =month(@fechaini)
set @anno2=year(@fechafin)
set @mes2 =month(@fechafin)
set @meses =month(@fechafin)-month(@fechaini)+1

If Exists(Select name from tempdb..sysobjects where name='##resumenxmesplantillas') 
    Drop Table ##resumenxmesplantillas 

if @tipo<>'5' -- randeo de meses detallado
begin
  If Exists(Select name from tempdb..sysobjects where name='##xx') 
    Drop Table ##xx
--print ('----')
end

If Exists(Select name from tempdb..sysobjects where name='##personal') 
    Drop Table ##personal
 
/*set @sql ='select *,soles=  round(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones +importe_gratificaciones +importe_vacaciones_compradas,2),
   dolares=  round(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones + importe_vacaciones_compradas,2)/(cast('+@tipocambio+' as float))
  INTO ##personal FROM '+@baseorigen+'.dbo.planilla_mensual a 
  WHERE  mes ='+@mes+'  AND ( anio ='+@anno+')'
*/
/*
Set @sql = 'select
personal_id, mes, anio, empresa_id, a.codigo_interno, dias_vacaciones, importe_vacaciones, dias_vacaciones_compradas, importe_vacaciones_compradas,
basico, horas_domingo, horas_rem30, horas_extra25, horas_extra35, horas_extra_00, n_horas_extra, total_extras, dominical, asig_fam, domingo_fer,
bonificacion_productividad, bonificacion_turno, bonificacion_afecta, descanso, rem_asegurable, fijo_bonificacion, id_afp, desc_afp_ao, desc_afp_cv,
desc_afp_ps, desc_svley, renta_quinta, retencion_judicial, desc_desayuno, desc_almuerzo, desc_cena, otros_descuentos, NETO_PAGAR, aport_sctr,
aport_essalud, pago_banco, cant_horas_normales, cant_horas_nocturnas, cant_horas_extras_25, cant_horas_extras_35, cant_horas_al_doble_DF, a.id_contrato,
id_tipo_trabajador_pago, banco_id, dias_feriados, nro_cta_cte, id_nacionalidad, tipocta_id, dias_permiso, dias_trabajados, importe_gratificaciones,
dias_descansomedico, desc_prestamo, dias_subsidios, importe_subsidios, tipo_subsidio, importe_permisos, dia_registro_subs, cerrar_planilla_mensual,
dias_trabajados_PE, a.seguro_vida_ley688, Id_plani_mens, a.senati, dias_trabajados_tmp, Sumi_Refrig_Ind, Sumi_supera_porcentaje, imp_feriado, id_reg_pensionario,
soles=  round(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones +importe_gratificaciones +importe_vacaciones_compradas,2),
   dolares=  round(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones + importe_vacaciones_compradas,2)/(cast('+@tipocambio+' as float))
  INTO ##personal
 FROM '+@baseorigen+'.dbo.planilla_mensual a 
	inner join '+@baseorigen+'.dbo.empresa e on a.empresa_id = e.id_empresa 	
	inner join '+@baseorigen+'.dbo.personal_contrato p on p.id_contrato = a.id_contrato
  WHERE  mes ='+@mes+'  AND ( anio ='+@anno+') 
	and e.controlar_almacen = 1 and p.id_grupo <> 33'
*/
Set @sql = 'select
personal_id, mes, anio, empresa_id, a.codigo_interno, dias_vacaciones, importe_vacaciones, dias_vacaciones_compradas, importe_vacaciones_compradas,
basico, horas_domingo, horas_rem30, horas_extra25, horas_extra35, horas_extra_00, n_horas_extra, total_extras, dominical, asig_fam, domingo_fer,
bonificacion_productividad, bonificacion_turno, bonificacion_afecta, descanso, rem_asegurable, fijo_bonificacion, id_afp, desc_afp_ao, desc_afp_cv,
desc_afp_ps, desc_svley, renta_quinta, retencion_judicial, desc_desayuno, desc_almuerzo, desc_cena, otros_descuentos, NETO_PAGAR, aport_sctr,
aport_essalud, pago_banco, cant_horas_normales, cant_horas_nocturnas, cant_horas_extras_25, cant_horas_extras_35, cant_horas_al_doble_DF, a.id_contrato,
id_tipo_trabajador_pago, banco_id, dias_feriados, nro_cta_cte, id_nacionalidad, tipocta_id, dias_permiso, dias_trabajados, importe_gratificaciones,
dias_descansomedico, desc_prestamo, dias_subsidios, importe_subsidios, tipo_subsidio, importe_permisos, dia_registro_subs, cerrar_planilla_mensual,
dias_trabajados_PE, a.seguro_vida_ley688, Id_plani_mens, a.senati, dias_trabajados_tmp, Sumi_Refrig_Ind, Sumi_supera_porcentaje, imp_feriado, id_reg_pensionario,
soles=  round(rem_asegurable,2),
dolares=  round(rem_asegurable,2)/(cast('+@tipocambio+' as float))
  INTO ##personal
 FROM '+@baseorigen+'.dbo.planilla_mensual a 
	inner join '+@baseorigen+'.dbo.empresa e on a.empresa_id = e.id_empresa 	
	inner join '+@baseorigen+'.dbo.personal_contrato p on p.id_contrato = a.id_contrato
  WHERE  mes ='+@mes+'  AND ( anio ='+@anno+') 
	and e.controlar_almacen = 1 and p.id_grupo <> 33'

execute(@sql)

if @tipo='1' 
begin
set @sql=' select n1=left(a.estructuranumerolinea ,2),grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),zz.tipo,
a.estructuranumerolinea, a.estructuradescripcion,zz.gastoscodigo,zz.gastosdescripcion,zz.referencia,
importesoles = zz.soles,importedolares=zz.dolares into '+@basedestino+'.dbo.##resumenxmesplantillas 
 from '+@basedestino+'.dbo.cs_estructurapresentacion a  left join  
--- gastos x provisiones
(select tipo=''E'', z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(dolares) from
(   select soles=case monedacodigo when ''02'' then (detproviimpbru+(case when detproviimpina < 0 then 0 else detproviimpina end ))* tipocambiocompra 
          else  (detproviimpbru+(case when detproviimpina < 0 then 0 else detproviimpina end )) end,
    dolares=case monedacodigo when ''01'' then (detproviimpbru+(case when detproviimpina < 0 then 0 else detproviimpina end ))/ tipocambiocompra 
          else (detproviimpbru+(case when detproviimpina < 0 then 0 else detproviimpina end )) end,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.co_cabeceraprovisiones a 
   inner join '+@basedestino+'.dbo.co_detalleprovisiones b on a.empresacodigo=b.empresacodigo and a.cabproviano=b.cabproviano and a.cabprovinumero=b.cabprovinumero
   inner join '+@basedestino+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio d on a.cabprovifchdoc=d.tipocambiofecha
   where cabprovifchconta between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabproviestado,'' '')='' '' and left(b.gastoscodigo,2) not in (''01'',''02'',''07'')
) as z group by z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion
union all
--- materiales de almacen
select tipo=''E'',c.estructuranumerolinea,c.centro_costo,rtrim(acodigo)+ '' - ''+rtrim(adescri)+ ''  '' + aunidad,referencia=sum(decantid),
   soles=sum(isnull(deprecio,0)*decantid),dolares=sum(isnull(deprecio,0)*decantid/tipocambiocompra)
   from '+@basedestino+'.dbo.movalmdet a 
   inner join '+@basedestino+'.dbo.movalmcab b  on a.dealma=b.caalma and a.detd=catd and denumdoc=canumdoc
   inner join '+@baseorigen+'.dbo.centro_costo c on a.decencos1=c.id_centro_costo
   inner join '+@basedestino+'.dbo.tabalm on dealma=taalma
   inner join '+@basedestino+'.dbo.maeart m on decodigo=acodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio f on b.cafecdoc=f.tipocambiofecha
   inner join '+@baseorigen+'.dbo.producto p on p.producto_id = m.producto_id
   inner join '+@baseorigen+'.dbo.tipo_bien t on t.tipobien_id = p.tipobien_id 
   where cafecdoc between '''+@fechaini+''' and '''+@fechafin+'''  and casitgui<>''A'' and t.categoria_id <> 1
   group by estructuranumerolinea,c.centro_costo,adescri,aunidad,acodigo
union all 
--kilos
select tipo=''I'',a=''010101'',lin_nombre,d.adescri,referencia=0.00,
  y=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida * equiv_kg end),
  z=sum(case when id_unidad_medida_obt=4 then cantidad_obtenida else cantidad_obtenida * equiv_kg end)
from '+@baseorigen+'.dbo.recepcion_cab a
right join '+@baseorigen+'.dbo.recepcion_det b on a.id_recepcion=b.id_recepcion
right join '+@baseorigen+'.dbo.procesos_det c  on b.id_proceso=c.id_proceso
left join '+@basedestino+'.dbo.maeart d on c.id_producto_obtenido=d.acodigo
left join '+@basedestino+'.dbo.lineas e on d.afamilia=e.fam_codigo and d.alinea=e.lin_codigo
inner join '+@baseorigen+'.dbo.producto p on p.producto_id = d.producto_id  
where convert(smalldatetime, convert(varchar(10), a.fecha_proceso, 103), 103) between '''+@fechaini+''' and '''+@fechafin+'''
and  a.id_planta=''01'' and c.item_insertarloteincompleto=0 and c.item_momentaneo=0 and c.item_inc_transferencia=0
and p.tipoproducto_id = 9
group by lin_nombre,id_producto_obtenido,adescri 
union all  
-- personal fijo  '
set @sql1 = '
select tipo=''E'', g.estructuranumerolinea,g.grupo_ocupacional,d.centro_costo,00.00,
   soles=sum(soles),dolares=sum(dolares)
  FROM '+@baseorigen+'.dbo.##personal a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
       inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
       inner join '+@baseorigen+'.dbo.centro_costo d on  b.id_centro_costo = d.id_centro_costo 
       --inner join '+@basedestino+'.dbo.cs_procesos e on d.id_centro_costo=e.procesocodigo
       --inner join '+@basedestino+'.dbo.ct_centrocosto f  on right( rtrim(c.id_empresa),2)=f.empresacodigo and d.equivalencia = f.centrocostocodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND ( a.anio ='+@anno+')  and  b.condicion_personal = 1 
 --       and patindex(''%''+a.id_tipo_trabajador_pago+''%'',f.tipotrabajdor) = 0
group by  g.estructuranumerolinea,g.id_grupo,g.grupo_ocupacional,d.centro_costo
union all
-- SENATI  senati 
select tipo=''E'', ''020503'' ,d.empresadescripcion,''SENATI  '',00.00,
   soles=  round(sum(a.senati),2),dolares=round(sum(a.senati),2)/(cast('+@tipocambio+' as float))
  FROM '+@baseorigen+'.dbo.##personal a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d on right( rtrim(c.id_empresa),2)=d.empresacodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 and a.senati > 0 
          group by   d.empresadescripcion
union all  
-- SCRT  seguro de riesgo de trabajo
select tipo=''E'', ''020503'' ,d.empresadescripcion,''SCRT  '',00.00,
   soles=  round(sum(aport_sctr),2),dolares=round(sum(aport_sctr),2)/(cast('+@tipocambio+' as float))
  FROM '+@baseorigen+'.dbo.##personal a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d on right( rtrim(c.id_empresa),2)=d.empresacodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 and aport_sctr > 0 
          group by   d.empresadescripcion
union all  
-- essalud
select tipo=''E'', ''020503'' ,d.empresadescripcion,''ESSALUD  '',00.00,
   soles=  round(sum(aport_essalud),2),dolares=round(sum(aport_essalud),2)/(cast('+@tipocambio+' as float))
  FROM '+@baseorigen+'.dbo.##personal a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d on right( rtrim(c.id_empresa),2)=d.empresacodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 group by   d.empresadescripcion
union all  -- cts 
select tipo=''E'', ''020503'' ,d.empresadescripcion,''CTS '',00.00,
   soles= round(sum(soles),2)* 1/12,
  dolares= round(sum(soles),2)/(cast('+@tipocambio+' as float))* 1/12
  FROM '+@baseorigen+'.dbo.##personal a inner join '+@baseorigen+'.dbo.personal_contrato b
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato 
        inner join '+@baseorigen+'.dbo.personal c on  a.personal_id=c.id_personal  
        inner join '+@basedestino+'.dbo.co_multiempresas d on right( rtrim(c.id_empresa),2)=d.empresacodigo
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  a.mes ='+@mes+'  AND a.anio ='+@anno+'  and  b.condicion_personal = 1 and b.id_regimen=''T728''
         and not (d.empresacodigo=''01'' and a.id_tipo_trabajador_pago<>''03'' ) group by   d.empresadescripcion
 union all -- tesoreria
select tipo=''E'', z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(z.dolares) from
(   select soles=detrec_importesoles  , dolares=detrec_importedolares,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.te_cabecerarecibos a 
   inner join '+@basedestino+'.dbo.te_detallerecibos b  on a.cabrec_numrecibo=b.cabrec_numrecibo 
   inner join '+@basedestino+'.dbo.co_gastos c on b.detrec_gastos=c.gastoscodigo
   where detrec_fechacancela between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabrec_estadoreg,'' '')='' '' and left(c.gastoscodigo,2) in (''09'')
) as z group by z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion 
) as zz on a.estructuranumerolinea=zz.estructuranumerolinea where estructuranivel=3'

Execute(@sql+@sql1)

--print 'hola2' 

set @sql= ' delete '+@basedestino+'.dbo.cs_resumenxmesplantillas where mesproceso =
ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) 

insert '+@basedestino+'.dbo.cs_resumenxmesplantillas 
select x=ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)),* ,0.00,getdate()
from '+@basedestino+'.dbo.##resumenxmesplantillas 

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles) from '+@basedestino+'.dbo.cs_resumenxmesplantillas where tipo=''I'' and 
    mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''I''

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles) from '+@basedestino+'.dbo.cs_resumenxmesplantillas where tipo=''E'' and  
    mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''E'''

execute (@sql)

end


if @tipo='2' 
set @sql='select tipomov=isnull(tipo,''X''),
             importes=isnull(case when '''+@moneda+'''=''01'' then importesoles else importedolares end,0),
              * from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  
 order  by n1,n2,estructuranumerolinea '

if @tipo='3' 
set @sql='select z.n1,z.n2,z.grupo1,z.grupo2,z.tipomov,z.tipo,z.estructuranumerolinea,z.estructuradescripcion,
z.gastoscodigo,z.gastosdescripcion,importes,z.referencia,porcentaje from
(
select tipomov=isnull(tipo,''X''),
             importes=case when '''+@moneda+'''=''01'' then importesoles else importedolares end,
              * from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  and importesoles > 0
) z
 order  by z.n1,z.n2,z.estructuranumerolinea'

if @tipo='4'  -- rango de meses
set @sql='select tipomov=isnull(tipo,''X''),
             importes=case when '''+@moneda+'''=''01'' then importesoles else importedolares end,
              * into ##xx  from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso >=ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) 
      and  mesproceso <=ltrim(str('+@anno2+')+right(''00''+ltrim(str('+@mes2+')) ,2)) 
      and  tipo<>''X'' and  importesoles > 0
      order  by n1,n2,estructuranumerolinea

update ##xx
set porcentaje=(importesoles*100.00/(select x=sum(importesoles) from ##xx where tipo=''I'') )  
where tipo=''I''

update ##xx
set porcentaje=(importesoles*100.00/(select x=sum(importesoles) from ##xx where tipo=''E'' ) )
where tipo=''E''

select * from ##xx order  by n1,n2,estructuranumerolinea '


if @tipo='5' -- rango de meses detallado
set @sql='select z.n1,z.n2,z.grupo1,z.grupo2,z.tipomov,z.tipo,z.estructuranumerolinea,
z.estructuradescripcion,z.gastoscodigo,z.gastosdescripcion,importes=sum(importes),
referencia=sum(referencia),
porcentaje=sum(porcentaje) from
(
select z.n1,z.n2,z.grupo1,z.grupo2,z.tipomov,z.tipo,z.estructuranumerolinea,
z.estructuradescripcion,z.referencia,z.porcentaje,z.importes,
gastoscodigo=case when isnull(b.producto_id,'''')='''' then z.gastoscodigo else
str(d.categoria_id,10,0) end ,
gastosdescripcion = case when isnull(b.producto_id,'''')='''' then z.gastosdescripcion else 
d.descripcion end from ##xx z
left join '+@baseorigen+'.dbo.producto b on left(z.gastosdescripcion,5)=str(b.producto_id,5,0)
left join  '+@baseorigen+'.dbo.tipo_bien c on b.tipobien_id=c.tipobien_id
left join  '+@baseorigen+'.dbo.categoria d on c.categoria_id=d.categoria_id

where importesoles > 0 

) z
group by z.n1,z.n2,z.grupo1,z.grupo2,z.tipomov,z.tipo,
z.estructuranumerolinea,z.estructuradescripcion,z.gastoscodigo,z.gastosdescripcion
 order  by n1,n2,estructuranumerolinea,gastoscodigo,gastosdescripcion'

execute(@sql)

--select * from planta_casma.dbo.cs_resumenxmesplantillas
GO
