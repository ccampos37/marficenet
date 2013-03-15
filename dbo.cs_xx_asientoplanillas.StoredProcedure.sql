SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_asientoplanillas 'planta10','planta_casma','%%','2008','1','%%'
*/
CREATE  proc [cs_xx_asientoplanillas]
@baseorigen varchar(50),
@basedestino varchar(100),
@empresa varchar(2),
@anno varchar(4),
@mes varchar(2),
@tipo varchar(2)
as
declare @sql  varchar(4000)
set @sql='select e.empresadescripcion, 
tipotrabajador=case  a.id_tipo_trabajador_pago when ''03'' then ''EMPLEADO''
          else ''OBRERO '' end  ,
tipojornal=case  a.id_tipo_trabajador_pago when ''01'' then ''DESTAJO ''
          else case  a.id_tipo_trabajador_pago when ''02'' then ''JORNAL '' 
          else ''ADMINISTRATIVO '' end end ,
d.equivalencia,
  round(sum(basico) + sum(horas_rem30) +sum(dominical),2) as basico_mensual,
  round(sum(total_extras),2)  as horas_extras,
  round(sum(bonificacion_productividad) + sum(bonificacion_turno) + sum(bonificacion_afecta)  + sum(fijo_bonificacion),2) as Bonificaciones,
  round(sum(domingo_fer) + sum(horas_domingo),2)   as domingo_feriados,
  round(sum(a.asig_fam),2) as asig_fam,
  round(sum(descanso),2) as descanso_medico,
  round(sum(importe_vacaciones) + sum(importe_vacaciones_compradas),2)  as vacaciones,
  round(sum(Aport_ESSALUD),2) as Aport_ESSALUD
  FROM '+@baseorigen+'.dbo.planilla_mensual a,   
       '+@baseorigen+'.dbo.personal_contrato b,
       '+@baseorigen+'.dbo.personal c,
       '+@baseorigen+'.dbo.centro_costo d , 
       '+@basedestino+'.dbo.co_multiempresas e  
   WHERE ( a.personal_id = b.id_personal ) and  
         ( a.id_contrato = b.id_contrato ) and  
         ( b.id_centro_costo = d.id_centro_costo ) and
         ( a.mes ='+@mes+' ) AND
         ( a.anio ='+@anno+')  and
         right( rtrim(c.id_empresa),2) like ('''+@empresa+''')  and
           c.id_personal = a.personal_id and
           right( rtrim(c.id_empresa),2)=e.empresacodigo and 
           b.condicion_personal = 1 and
           a.id_tipo_trabajador_pago like ('''+@tipo+''')
group by e.empresadescripcion,a.id_tipo_trabajador_pago,d.equivalencia'
execute(@sql)
GO
