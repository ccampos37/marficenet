SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute cs_actualizadiariopersonal_pro 'planta10','planta_casma','01/04/2008','30/04/2008','1'
select * from ##xx
drop table ##tempo
drop table ##xx

*/

CREATE              proc [cs_actualizadiariopersonal_pro]

@baseorigen  varchar(30),
@basedestino varchar(30),
@desde varchar(10),
@hasta varchar(10),
@dias int=30,
@tipo varchar(1)='1'
as

declare @sql varchar(4000),@af as numeric(18,3)
--drop table ##xx

  
set @sql=' declare @af numeric(18,3)
set @af=round((select valor=cast(valor as numeric(18,3))/10 from '+@baseorigen+'.dbo.conceptos 
where concepto_id=''0007''),2) 

create table ##tempo(dia datetime null,nro_dias_mes  decimal(18,3)  null,  imp_RMV numeric(18,3) null,empresa char(20) null , 
   id_personal char(10) null ,centro_costo char(30) null, id_centro_costo char(10) null, equivalencia char(10) null, 
   remuneracion numeric(18,3) null, asig_fam INT null,
   cant_HN  int  null,cant_HNoct int  null, cant_he25  int  null, 
   cant_he35  int  null ) 

INSERT INTO ##tempo 
SELECT b.fecha_prod,a=30.00,55,e.id_empresa,a.id_personal, left(g.grupo_ocupacional,30),
    id_centro_costo=''  '',g.estructuranumerolinea,
    c.remuneracion, a.asig_fam, sum(b.horas_normal), sum(b.horas_30),sum(b.horas_25), 
    sum(b.horas_35)
     FROM '+@baseorigen+'.dbo.Asistencia_refrigerio a 
     INNER JOIN '+@baseorigen+'.dbo.Administrativo_jornal b ON a.id_personal = b.personal_id 
              AND a.fecha_control = b.fecha_prod 
     INNER JOIN '+@baseorigen+'.dbo.Personal_contrato c ON a.id_contrato = c.id_contrato 
      INNER JOIN '+@baseorigen+'.dbo.Personal e ON b.personal_id = e.id_personal
     inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on c.id_grupo=g.id_grupo
WHERE     (b.fecha_prod >='''+@desde+''' and b.fecha_prod <='''+@hasta+''' )
group by  b.fecha_prod,e.id_empresa,a.id_personal,g.grupo_ocupacional,g.estructuranumerolinea,c.remuneracion, a.asig_fam '

EXECUTE(@sql) 

set @sql='SELECT tipo=''01'',dia=a.fecha_prod,p.id_empresa,descripcion=g.grupo_ocupacional,
   centro_costo=''  '',g.estructuranumerolinea,
  total= round(sum(a.rem_basica),2)  + round(sum(a.r_horas),2)  + round(sum(a.r_horas_domingo),2) + 
        round(sum(a.r_domingo_feriado),2) + round(sum(a.dominical_00),2)+
	round(sum(a.bonificacion_prod),2) + round(sum(a.bonificacion_turno),2) +  
        round(sum(a.bonificacion_afecta),2) + round(sum(a.fijo_bonificacion),2)+ 
        round(sum(a.descanso),2)+ round(sum(a.asig_fam),2)+              
	 round(sum(a.importe_vacaciones),2) + round(sum(a.importe_vacaciones_compradas),2)+ 
	 round(sum(a.r_horas_extra_01),2) + round(sum(a.r_horas_extra_02),2) 
   into ##xx
    FROM '+@baseorigen+'.dbo.planilla_diaria_destajo a
        inner join '+@baseorigen+'.dbo.personal_contrato b on a.personal_id = b.id_personal and a.id_contrato = b.id_contrato
        inner join  '+@baseorigen+'.dbo.personal p  on a.personal_id=p.id_personal  
       inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE  ( a.fecha_prod between '''+@desde+''' and '''+@hasta+''' ) AND  ( a.condicion_personal = 1)
      group by a.fecha_prod,p.id_empresa,g.grupo_ocupacional,g.estructuranumerolinea
UNION ALL 
 SELECT  tipo=''02'',dia=a.fecha_prod,p.id_empresa,descripcion=g.grupo_ocupacional,centro_costo=''  '',g.estructuranumerolinea,
 total= round(sum(a.basico),2) + round(sum(a.horas_rem30),2) + round(sum(a.dominical),2) + 
         round(sum(a.domingo_fer),2) +
         round(sum(a.bonificacion_productividad),2) + round(sum(a.bonificacion_turno),2) +  round(sum(a.bonificacion_afecta),2) +
          round(sum(a.fijo_bonificacion),2) + round(sum(a.descanso),2)+ round(sum(a.horas_extra25),2) + round(sum(a.horas_extra35),2) +
         round(sum(a.asig_fam),2) +
         round(sum(a.importe_vacaciones),2) + round(sum(a.importe_vacaciones_compradas),2) 
  FROM '+@baseorigen+'.dbo.planilla_diaria_jornal a
         inner join '+@baseorigen+'.dbo.personal_contrato b on a.personal_id = b.id_personal and a.id_contrato = b.id_contrato
         inner join '+@baseorigen+'.dbo.personal p on a.personal_id=p.id_personal   
         inner join  '+@baseorigen+'.dbo.grupo_ocupacional g on b.id_grupo=g.id_grupo
   WHERE ( a.fecha_prod between '''+@desde +''' and '''+@hasta+''')  AND  
         ( a.condicion_personal = 1)
group by  a.fecha_prod,p.id_empresa,g.grupo_ocupacional,g.estructuranumerolinea
union all
SELECT tipo=''03'',dia,empresa,descripcion=centro_costo,x='' '',equivalencia,
total= sum(asig_fam*imp_RMV)+ sum(round(cant_HNoct*(1.35*remuneracion/(nro_dias_mes*8)),3))+
      sum(round(cant_he25*(1.25*remuneracion/(nro_dias_mes*8)),3))+
      sum(round(cant_he35*(1.35*remuneracion/(nro_dias_mes*8)),3)) '
If @tipo='1'
   begin
     set @sql=@sql+'+sum(round((cant_HN)*(remuneracion/(nro_dias_mes*8)),3))'
   end
set @sql=@sql + ' from  ##tempo
group by dia,empresa,centro_costo,equivalencia,remuneracion,nro_dias_mes'

EXECUTE(@sql)


Drop table  ##tempo
GO
