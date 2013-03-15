SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_Generacioncostoplanillas 'planta10','planta_casma','01/01/2008','31/01/2008','1'
*/
CREATE proc [cs_xx_Generacioncostoplanillas]
@baseorigen varchar(50),
@basedestino varchar(100),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)
as
declare @sql  varchar(4000),@empresa varchar(2)
declare @anno varchar(4),@mes varchar(2)
set @anno=year(@fechaini)
set @mes =month(@fechaini)
set @sql='select  e.estructuranumerolinea,d.equivalencia,e.centrocostodescripcion,
   total=  round(sum(basico + horas_rem30+dominical+total_extras+bonificacion_productividad + bonificacion_turno + 
        bonificacion_afecta  + fijo_bonificacion+domingo_fer+ horas_domingo+a.asig_fam+
        descanso+importe_vacaciones + importe_vacaciones_compradas),2)
  FROM '+@baseorigen+'.dbo.planilla_mensual a,   
       '+@baseorigen+'.dbo.personal_contrato b,
       '+@baseorigen+'.dbo.personal c,
       '+@baseorigen+'.dbo.centro_costo d , 
       '+@basedestino+'.dbo.ct_centrocosto e  
   WHERE ( a.personal_id = b.id_personal ) and  
         ( a.id_contrato = b.id_contrato ) and  
         ( b.id_centro_costo = d.id_centro_costo ) and
           right( rtrim(c.id_empresa),2)=e.empresacodigo and d.equivalencia = e.centrocostocodigo and 
         ( a.mes ='+@mes+' ) AND
         ( a.anio ='+@anno+')  and
         c.id_personal = a.personal_id and
         b.condicion_personal = 1 
group by   e.estructuranumerolinea,d.equivalencia,e.centrocostodescripcion order by 2'
execute(@sql)
GO
