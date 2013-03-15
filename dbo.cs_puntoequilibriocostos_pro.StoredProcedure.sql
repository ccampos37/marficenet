SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_puntoequilibriocostos_pro 'planta10','planta_casma','01/08/2008','31/08/2008','##PTOEQJCK','0',2.8,'01',1
select '*'+ltrim(str(referencia,5,0)),* from ##_resumenxdiaplantillas
drop table ##tempo
select * from ##xx
select * from ##xx1
*/

CREATE                        PROC [cs_puntoequilibriocostos_pro]

@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@computer varchar(30),
@tipo varchar(1)='1',
@tipocambio varchar(10)='1',
@moneda varchar(2)='01',
@dias integer=1

as

declare  @sql varchar(8000),@sql1 varchar(8000)

execute dbo.cs_actualizacostosdiarios_pro @baseorigen,@basedestino,@fechaini,@fechafin,@tipo,@tipocambio,@moneda,@dias


set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
    Drop Table '+@computer+''

execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+'1'')
    Drop Table '+@computer+'1'

execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx'')
    Drop Table ##xx'

execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx1'')
    Drop Table ##xx1'

execute(@sql)


declare @mesproceso varchar(6)
set @mesproceso=cast(year(@fechaini) as varchar(4))+ cast('0' + cast(month(@fechaini) as varchar(2)) as varchar(2))

Set @sql='select importe=( select basico= sum(round(remuneracion ,2)) FROM '+@baseorigen+'.dbo.personal_contrato a
       inner join '+@baseorigen+'.dbo.personal b on  a.id_personal=b.id_personal  
       inner join '+@baseorigen+'.dbo.grupo_ocupacional g on a.id_grupo=g.id_grupo
   WHERE  a.condicion_personal = 1 and personal_fijo=1 and ultimo_contrato=1 and g.estructuranumerolinea=x.estructuranumerolinea
   group by  g.estructuranumerolinea ),
x.* into ##xx from '+@basedestino+'.dbo.cs_estructurapresentacion x
where tipodegastosfijos=1 and tipocodigo=''P'' '
execute(@sql)
Declare @importegastofijo as float
Set @sql='select importe=(select top 1 importesoles from '+@basedestino+'.dbo.cs_resumenxmesplantillas x 
         where x.estructuranumerolinea =a.estructuranumerolinea and mesproceso<='+@mesproceso+' and isnull(importesoles,0)>0
         order by mesproceso desc),
a.* into ##xx1 from '+@basedestino+'.dbo.cs_estructurapresentacion a 
where tipodegastosfijos=1 and tipocodigo=''G'' 

--Declare @importegastofijo as float
--Set @importegastofijo=(Select sum(a.importe) from (select *  from ##xx union all select *  from ##xx1 ) a) 

/*
select a.*,y.monto from ##_resumenxdiaplantillas a
left join 
(select estructuranumerolinea,monto=sum(importe) from 
( select *  from ##xx union all select *  from ##xx1 ) z group by z.estructuranumerolinea
) y on a.estructuranumerolinea=y.estructuranumerolinea
*/

select z.dia,kilos=sum(z.kilos),ingresos=sum(z.ingresos),gastosfijos=(Select sum(a.importe) from (select *  from ##xx union all select *  from ##xx1 ) a),gastosvar=sum(z.gastosvar) 
into  '+@computer+' from
(  select dia=day(fechaoperacion),kilos=case when tipo=''I'' then sum(importesoles) else 0 end,
   ingresos=case when tipo=''I'' then sum(importesoles*dbo.fn_PrecioUnitario(ltrim(str(referencia,5,0)),fechaoperacion))else 0 end,
   gastosvar=case when tipo=''E'' then sum(importesoles)else 0 end
   from ##_resumenxdiaplantillas
   where fechaoperacion is not null
   group by fechaoperacion,tipo,n2 
) z group by z.dia '

exec(@sql)

set @sql='select top 0 * into  '+@computer+'1 from '+@computer+' '

EXECUTE(@sql)


SET @Sql='  Declare @dia integer,@ingresos float,@gastosfijos float,@gastosvar float,@kilos float
        declare @dia1 integer,@ingresos1 float,@gastosfijos1 float,@gastosvar1 float,@kilos1 float,@diaant integer
	Declare Correla cursor for 
	select dia,ingresos,gastosfijos,gastosvar,kilos from '+@computer+'
	order by dia
	Open Correla
	fetch next from Correla into @dia ,@ingresos ,@gastosfijos ,@gastosvar,@kilos
        set @ingresos1=0
        set @gastosfijos1=0
        set @gastosvar1=0
	set @kilos1 = 0
	set @diaant=@dia-1
	While @@Fetch_Status=0 
	Begin 
	   set @ingresos1=@ingresos1+@ingresos
	   set @gastosfijos1=@gastosfijos
	   set @gastosvar1=@gastosvar1+@gastosvar
           set @dia1=@dia
	   set @kilos1=@kilos1+@kilos
	   fetch next from Correla into @dia ,@ingresos ,@gastosfijos ,@gastosvar,@kilos
	   if @dia1<>@diaant 
	      begin
	        set @diaant=@dia1
	        insert into '+@computer+'1 (dia,ingresos,gastosfijos,gastosvar,kilos,mes) 
	        values ( @dia1,@ingresoS1,@gastosfijos1,@gastosvar1,@kilos1,@mes1)
	      End
	end
        Close Correla
	Deallocate Correla '

execute(@Sql)

set @sql = ' select * from '+@computer+'1' 
execute(@sql)
           /*if @dia1<>@dia 
              begin
                insert into '+@computer+'1 (dia,ingresos,gastosfijos,gastosvar,kilos) 
                     values ( @dia1,@ingresoS1,@gastosfijos1,@gastosvar1,@kilos1)
	      End*/
GO
