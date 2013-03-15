SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute cs_xx_generatesoreria 'planta10','planta_casma','01/01/2008','31/01/2008','1'
*/
CREATE proc [cs_xx_generatesoreria]
@baseorigen varchar(50),
@basedestino varchar(50),
@fechaini varchar(10),
@fechafin varchar(10),
@tipo varchar(1)='1'
as
declare @sql varchar(4000)
set @sql = 'select tipo=''E'', z.estructuranumerolinea,z.detrec_gastos,descripcion='' Tesoreria - ''+z.gastosdescripcion,referencia=0.00,y=sum(z.soles) from
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
group by z.estructuranumerolinea,z.detrec_gastos,z.gastosdescripcion '
execute(@sql)
GO
