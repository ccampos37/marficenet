SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [cs_veriimpordata_rpt]
--Declare 
	@compu varchar(50)
/*Se verifica que todos los registros que estan en cabecera head_orden tambien
  se encuentren en el detalle*/
/*Set @compu='desarrollo4'*/
As
Declare @sqlcad varchar(8000)
Set @sqlcad=''+
'Select * from 
(
select coderror=''01'',cadena=''cod_orden= ''+cod_orden,
       tabla=''Head_orden_XX_XXXX - Det_Orden_XX_XXXX '',mesxx 
from ##tmp_headorden'+@compu+' 
      
where cod_orden not in (
select distinct cod_orden from ##tmp_Detorden'+@compu+' )
union all '+char(13) 
/*
Partidas que no tienen control de tiempos
*/
Set @sqlcad=@sqlcad + 
'select distinct
    coderror=''02'', cadena=''cod_orden= ''+ cod_orden+'' ; Cod_Partida= ''+ Cod_Partida,
    tabla=''Det_Orden_XX_XXXX - CTRL_XX_XXXX '',mesxx  
from ##tmp_Detorden'+@compu+' 
where cod_orden not in (
select distinct b.cod_orden 
from ##tmp_CTRLorden'+@compu+' A
inner join  ##tmp_Detorden'+@compu+' B
		on A.Cod_Partida=B.Cod_Partida ) '+char(13)
/*
Ordenes que no estan en la tabla quimico_partes tabla
donde se sacan los importes consumidos por cada orden
*/
Set @sqlcad=@sqlcad + 
'union all
select coderror=''03'',cadena=''cod_orden= ''+cod_orden,
       tabla=''Head_orden_XX_XXXX - Quimicopartes_XX_XXXX '',mesxx    
from ##tmp_headorden'+@compu+' 
where cod_orden not in (
select distinct cod_orden 
from ##tmp_quimicopartes'+@compu+'  )
) a
order by coderror,cadena '
Exec(@sqlcad)
GO
