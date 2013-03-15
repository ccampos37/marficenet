SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_actualizacostos_pro 'planta10','planta_casma','01/01/2008','31/01/2008','1',2.93,'01'
select decencos,* from planta_casma.dbo.movalmdet where decodigo='10342'
*/

create   PROC [cs_actualizacostosexport_pro]
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

if @tipo='1' 
begin
set @sql=' select n1=left(a.estructuranumerolinea ,2),grupo1=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,2)=b.estructuranumerolinea),
n2=left(a.estructuranumerolinea ,4),grupo2=(select estructuradescripcion from '+@basedestino+'.dbo.cs_estructurapresentacion b
        where left(a.estructuranumerolinea ,4)=b.estructuranumerolinea),zz.tipo,
a.estructuranumerolinea, a.estructuradescripcion,zz.gastoscodigo,zz.gastosdescripcion,zz.referencia,
importesoles = zz.soles,importedolares=zz.dolares
into '+@basedestino+'.dbo.##resumenxmesplantillas 
 from '+@basedestino+'.dbo.cs_plantillaexport  left join  
--- gastos x provisiones
(select tipo=''E'', z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(dolares) from
(   select soles=case monedacodigo when ''02'' then (detprovitotal-detproviimpigv)* tipocambiocompra else  (detprovitotal-detproviimpigv) end,
           dolares=case monedacodigo when ''01'' then (detprovitotal-detproviimpigv)/ tipocambiocompra else  (detprovitotal-detproviimpigv) end,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.co_cabeceraprovisiones a 
   inner join '+@basedestino+'.dbo.co_detalleprovisiones b on a.empresacodigo=b.empresacodigo and a.cabproviano=b.cabproviano and a.cabprovinumero=b.cabprovinumero
   inner join '+@basedestino+'.dbo.co_gastos c on b.gastoscodigo=c.gastoscodigo
   inner join '+@basedestino+'.dbo.ct_tipocambio d on a.cabprovifchdoc=d.tipocambiofecha
   where cabprovifchdoc between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabproviestado,'' '')='' '' and left(b.gastoscodigo,2) not in (''01'',''07'')
) as z group by z.estructuranumerolinea,z.gastoscodigo,z.gastosdescripcion
union all
select tipo=''E'', z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,soles=sum(z.soles),dolares=sum(z.dolares) from
(   select soles=detrec_importesoles  , dolares=detrec_importedolares,
b.*,c.gastosdescripcion,c.estructuranumerolinea from '+@basedestino+'.dbo.te_cabecerarecibos a 
   inner join '+@basedestino+'.dbo.te_detallerecibos b  on a.cabrec_numrecibo=b.cabrec_numrecibo 
   inner join '+@basedestino+'.dbo.co_gastos c on b.detrec_gastos=c.gastoscodigo
   where detrec_fechacancela between '''+@fechaini+''' and '''+@fechafin+''' 
   and isnull(cabrec_estadoreg,'' '')='' '' and left(c.gastoscodigo,2) in (''09'')
) as z group by z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion 
) as zz on a.estructuranumerolinea=zz.estructuranumerolinea where estructuranivel=3 
'
execute(@sql+@sql1)

set @sql= ' delete '+@basedestino+'.dbo.cs_resumenxmesplantillas where mesproceso =
ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) 

insert '+@basedestino+'.dbo.cs_resumenxmesplantillas 
select x=ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)),* ,0.00
from '+@basedestino+'.dbo.##resumenxmesplantillas 

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles)*1.00  from '+@basedestino+'.dbo.cs_resumenxmesplantillas where tipo=''I'' and 
    mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2)) and tipo=''I''

update '+@basedestino+'.dbo.cs_resumenxmesplantillas 
set porcentaje=(importesoles/(select x=sum(importesoles)*1.00  from '+@basedestino+'.dbo.cs_resumenxmesplantillas
        where tipo=''E'' and  mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))))*100 
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
set @sql='select tipomov=isnull(tipo,''X''),
             importes=case when '''+@moneda+'''=''01'' then importesoles else importedolares end,
              * from '+@basedestino+'.dbo.cs_resumenxmesplantillas 
where mesproceso =ltrim(str('+@anno+')+right(''00''+ltrim(str('+@mes+')) ,2))  and importesoles > 0
 order  by n1,n2,estructuranumerolinea '
execute(@sql)
GO
