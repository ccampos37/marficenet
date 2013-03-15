SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [xx1] 
as
-- personal fijo    
select tipo='E', g.estructuranumerolinea,g.grupo_ocupacional,d.centro_costo,
   mes=right('0'+ltrim(str(a.mes)),2)+' '+MARFICE.dbo.fn_DescripcionMes(a.mes),  
   soles=sum(soles),dolares=sum(dolares)  
  FROM 
  (select		
personal_id, mes, anio, empresa_id, a.codigo_interno, dias_vacaciones, importe_vacaciones, dias_vacaciones_compradas, importe_vacaciones_compradas,  
basico, horas_domingo, horas_rem30, horas_extra25, horas_extra35, horas_extra_00, n_horas_extra, total_extras, dominical, asig_fam, domingo_fer,  
bonificacion_productividad, bonificacion_turno, bonificacion_afecta, descanso, rem_asegurable, fijo_bonificacion, id_afp, desc_afp_ao, desc_afp_cv,  
desc_afp_ps, desc_svley, renta_quinta, retencion_judicial, desc_desayuno, desc_almuerzo, desc_cena, otros_descuentos, NETO_PAGAR, aport_sctr,  
aport_essalud, pago_banco, cant_horas_normales, cant_horas_nocturnas, cant_horas_extras_25, cant_horas_extras_35, cant_horas_al_doble_DF, a.id_contrato,  
id_tipo_trabajador_pago, banco_id, dias_feriados, nro_cta_cte, id_nacionalidad, tipocta_id, dias_permiso, dias_trabajados, importe_gratificaciones,  
dias_descansomedico, desc_prestamo, dias_subsidios, importe_subsidios, tipo_subsidio, importe_permisos, dia_registro_subs, cerrar_planilla_mensual,  
dias_trabajados_PE, a.seguro_vida_ley688, Id_plani_mens, a.senati, dias_trabajados_tmp, Sumi_Refrig_Ind, Sumi_supera_porcentaje, imp_feriado, id_reg_pensionario,  
soles=  round(rem_asegurable,2)+aport_essalud+aport_sctr+a.senati,  
dolares=  round(rem_asegurable,2)/(cast(2.93 as float))  
 FROM planta10.dbo.planilla_mensual a   
 inner join planta10.dbo.empresa e on a.empresa_id = e.id_empresa    
 inner join planta10.dbo.personal_contrato p on p.id_contrato = a.id_contrato  
  WHERE  mes <=10  AND ( anio =2011)   
 and e.controlar_almacen = 1 and p.id_grupo <> 33
) a
 inner join planta10.dbo.personal_contrato b  
          on  a.personal_id = b.id_personal  and  a.id_contrato = b.id_contrato   
       inner join planta10.dbo.personal c on  a.personal_id=c.id_personal    
       inner join planta10.dbo.centro_costo d on  b.id_centro_costo = d.id_centro_costo   
       --inner join costos_2012.dbo.cs_procesos e on d.id_centro_costo=e.procesocodigo  
       --inner join costos_2012.dbo.ct_centrocosto f  on right( rtrim(c.id_empresa),2)=f.empresacodigo and d.equivalencia = f.centrocostocodigo  
       inner join  planta10.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo  
   WHERE  ( a.anio =2011)  and  b.condicion_personal = 1   
 --       and patindex('%'+a.id_tipo_trabajador_pago+'%',f.tipotrabajdor) = 0  
group by  g.estructuranumerolinea,g.id_grupo,g.grupo_ocupacional,d.centro_costo,a.mes
GO
