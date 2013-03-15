SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_puntoequilibriocostos1_pro 'planta10','planta_casma','01/01/2007','31/01/2008','##PTOEQJCK','0',2.8,'01',1,0
select '*'+ltrim(str(referencia,5,0)),* from ##_resumenxdiaplantillas
drop table ##tempo
drop table ##xx
drop table ##xx1
select * from ##xx
select * from ##xx1
*/

CREATE        PROC [cs_puntoequilibriocostos1_pro]

@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@computer varchar(30),
@tipo varchar(1)='1',
@tipocambio varchar(10)='1',
@moneda varchar(2)='01',
@dias integer=1,
@semana integer=0 --1: calculo x semana

as

declare  @sql varchar(8000),@sql1 varchar(8000)
Declare @mesoperacion as integer


set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+'1'')
    Drop Table '+@computer+'1'

execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
    Drop Table '+@computer+''

execute(@sql)

--Definimos si se va a calcular para uno o varios meses
Set @mesoperacion = month(@fechafin)-month(@Fechaini)
If ((@mesoperacion+1)<7 and (@mesoperacion)>0)
  Begin
    Set @semana=1
  End
declare @mesproceso varchar(6)
-- Si es para un mes
If @mesoperacion= 0
   Begin
	execute dbo.cs_actualizacostosdiarios_pro @baseorigen,@basedestino,@fechaini,@fechafin,@tipo,@tipocambio,@moneda,@dias


set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+''') 
    Drop Table '+@computer+''
execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx'')
    Drop Table ##xx'
execute(@sql)

set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx1'')
    Drop Table ##xx1'
execute(@sql)

	set @mesproceso=cast(year(@fechaini) as varchar(4))+ cast('0' + cast(month(@fechaini) as varchar(2)) as varchar(2))

	Set @sql='select importe=( select basico= sum(round(remuneracion ,2)) FROM '+@baseorigen+'.dbo.personal_contrato a
       	inner join '+@baseorigen+'.dbo.personal b on  a.id_personal=b.id_personal  
      	 inner join '+@baseorigen+'.dbo.grupo_ocupacional g on a.id_grupo=g.id_grupo
   	WHERE  a.condicion_personal = 1 and personal_fijo=1 and ultimo_contrato=1 and g.estructuranumerolinea=x.estructuranumerolinea
  	 group by  g.estructuranumerolinea ),
	x.* into ##xx from '+@basedestino+'.dbo.cs_estructurapresentacion x
	where tipodegastosfijos=1 and tipocodigo=''P'' '
	exec(@sql)

	Set @sql='select importe=(select top 1 importesoles from '+@basedestino+'.dbo.cs_resumenxmesplantillas x 
         	where x.estructuranumerolinea =a.estructuranumerolinea and mesproceso<='+@mesproceso+' and isnull(importesoles,0)>0
         	order by mesproceso desc),
	a.* into ##xx1 from '+@basedestino+'.dbo.cs_estructurapresentacion a 
	where tipodegastosfijos=1 and tipocodigo=''G'' 
	'

	Set @sql= @sql +'  Select '+cast(@mesoperacion as varchar)+' as mes,z.dia,kilos=sum(z.kilos),ingresos=sum(z.ingresos),
	gastosfijos=(Select sum(a.importe) from (select *  from ##xx union all select *  from ##xx1 ) a),gastosvar=sum(z.gastosvar)
	into  '+@computer+' from
	(  select dia=day(fechaoperacion),kilos=case when tipo=''I'' then sum(importesoles) else 0 end,
	ingresos=case when tipo=''I'' then sum(importesoles*dbo.fn_PrecioUnitario(ltrim(str(referencia,5,0)),fechaoperacion))else 0 end,
	   gastosvar=case when tipo=''E'' then sum(importesoles)else 0 end
   	from ##_resumenxdiaplantillas
   	where fechaoperacion is not null
   	group by fechaoperacion,tipo,n2 
	) z   group by z.dia'

	exec(@sql)

   End  --Para un mes

-- Si es para varios meses
Declare @anno as integer
Declare @sw as integer
Declare @Fechaf as varchar(10)
Declare @Fechai as varchar(10)
Set @sw=1
If @mesoperacion<> 0
   Begin
       Set @mesoperacion = month(@fechaini)
       Set @anno = year(@fechaini)
      While @mesoperacion <= month(@fechafin) Or @anno>year(@fechafin)
        Begin
	Set @Fechaf = dbo.Fn_UltDiaMes(@mesoperacion,@anno)
	Set @Fechai = '01/'+cast(@mesoperacion as varchar)+'/'+cast(@anno as varchar)
	execute dbo.cs_actualizacostosdiarios_pro @baseorigen,@basedestino,@Fechai,@Fechaf,@tipo,@tipocambio,@moneda,@dias

	set @mesproceso=cast(@anno as varchar(4))+ right('0' + cast(@mesoperacion as varchar(2)),2)

	set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx'')
	    Drop Table ##xx'
	execute(@sql)

	set @sql =' If Exists(Select name from tempdb..sysobjects where name=''##xx1'')
	    Drop Table ##xx1'
	execute(@sql)

	set @sql =' If Exists(Select name from tempdb..sysobjects where name='''+@computer+'2'') 
	    Drop Table '+@computer+'2'
	execute(@sql)

	Set @sql='select importe=( select basico= sum(round(remuneracion ,2)) FROM '+@baseorigen+'.dbo.personal_contrato a
       	inner join '+@baseorigen+'.dbo.personal b on  a.id_personal=b.id_personal  
      	 inner join '+@baseorigen+'.dbo.grupo_ocupacional g on a.id_grupo=g.id_grupo
   	WHERE  a.condicion_personal = 1 and personal_fijo=1 and ultimo_contrato=1 and g.estructuranumerolinea=x.estructuranumerolinea
  	 group by  g.estructuranumerolinea ),
	x.* into ##xx from '+@basedestino+'.dbo.cs_estructurapresentacion x
	where tipodegastosfijos=1 and tipocodigo=''P'' '
	exec(@sql)

	Set @sql='select importe=(select top 1 importesoles from '+@basedestino+'.dbo.cs_resumenxmesplantillas x 
         	where x.estructuranumerolinea =a.estructuranumerolinea and mesproceso<='+@mesproceso+' and isnull(importesoles,0)>0
         	order by mesproceso desc),
	a.* into ##xx1 from '+@basedestino+'.dbo.cs_estructurapresentacion a 
	where tipodegastosfijos=1 and tipocodigo=''G'' 
	'

	If @semana =1
	   Begin  
		Set @sql= @sql + '  Select z.mes,z.semana as dia,'
	   End
	Else
	   Begin
		Set @sql= @sql + '  Select  '+cast(@semana as varchar)+' as mes,'+cast(@mesoperacion as varchar)+' as dia,'
	   End
	
	Set @sql= @sql +'kilos=sum(z.kilos),ingresos=sum(z.ingresos),
	gastosfijos=(Select sum(a.importe) from (select *  from ##xx union all select *  from ##xx1 ) a),gastosvar=sum(z.gastosvar)
	into  '+@computer+'2 from
	(  select dia=day(fechaoperacion),kilos=case when tipo=''I'' then sum(importesoles) else 0 end,
	ingresos=case when tipo=''I'' then sum(importesoles*dbo.fn_PrecioUnitario(ltrim(str(referencia,5,0)),fechaoperacion))else 0 end,
	   gastosvar=case when tipo=''E'' then sum(importesoles)else 0 end,
   	Case When day(fechaoperacion)<8 Then ''1'' When day(fechaoperacion)>7 And day(fechaoperacion)<15 Then ''2'' 
   	When day(fechaoperacion)>14 And day(fechaoperacion)<22 Then ''3'' When day(fechaoperacion)>21 Then ''4'' End as semana, '+cast(@mesoperacion as varchar)+' as mes
   	from ##_resumenxdiaplantillas
   	where fechaoperacion is not null
   	group by fechaoperacion,tipo,n2 
	) z  '
	If @semana =1
	   Begin  
		Set @sql= @sql + ' group by z.mes,z.semana '
	   End
	Else
	   Begin  
		Set @sql= @sql + ' group by z.mes'
	   End

	execute(@sql)

	If @mesoperacion=12 And @anno < year(@fechafin)
	   Begin
		Set @mesoperacion=1
		Set @anno = @anno+1
	   End
	Else
	   Begin
		Set @mesoperacion= @mesoperacion+1
	   End
	If @sw=1
	  Begin
		set @sql='select top 0 * into  '+@computer+' from '+@computer+'2 '
		EXECUTE(@sql)
		Set @sw=0
	  End

	Set @sql ='Insert Into '+@computer+'  Select  mes,dia,kilos,ingresos,gastosfijos,gastosvar From  '+@computer+'2 '
	EXECUTE(@sql)

        End --While

   End  --Para varios meses

set @sql='select top 0 * into  '+@computer+'1 from '+@computer+' '
EXECUTE(@sql)

SET @Sql='  Declare @dia integer,@ingresos float,@gastosfijos float,@gastosvar float, @kilos float,@mes integer
	declare @dia1 integer,@ingresos1 float,@gastosfijos1 float,@gastosvar1 float, @kilos1 float,@diaant integer,@mes1 integer
	Declare Correla cursor for 
	select dia,ingresos,gastosfijos,gastosvar,kilos,mes from '+@computer+'
	order by mes,dia
	Open Correla
	fetch next from Correla into @dia ,@ingresos ,@gastosfijos ,@gastosvar,@kilos,@mes
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
	   set @mes1 = (@mes*10)+@dia
	   fetch next from Correla into @dia ,@ingresos ,@gastosfijos ,@gastosvar,@kilos,@mes
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
GO
