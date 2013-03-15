SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [xx]
as
select tipo='E',c.estructuranumerolinea,ca.descripcion,
   mes=right('0'+ltrim(str(month(cafecdoc))),2)+' '+MARFICE.dbo.fn_DescripcionMes(MONTH(CAFECDOC)),adescri,referencia=sum(decantid),  
   soles=sum(isnull(deprecio,0)*decantid),dolares=sum(isnull(deprecio,0)*decantid/tipocambiocompra)  
   from costos_2012.dbo.movalmdet a   
   inner join costos_2012.dbo.movalmcab b  on a.dealma=b.caalma and a.detd=catd and denumdoc=canumdoc  
   inner join planta10.dbo.centro_costo c on a.decencos1=c.id_centro_costo  
   inner join costos_2012.dbo.tabalm on dealma=taalma  
   inner join costos_2012.dbo.maeart m on decodigo=acodigo  
   inner join costos_2012.dbo.ct_tipocambio f on b.cafecdoc=f.tipocambiofecha  
   inner join planta10.dbo.producto p on m.producto_id = p.producto_id  
   inner join planta10.dbo.categoria ca on p.categoria2_id  = ca.categoria_id  
   where cafecdoc between '01/01/2011' and '31/10/2011'  and casitgui<>'A' and p.categoria2_id <> 1  
   group by estructuranumerolinea,ca.descripcion, MONTH(cafecdoc), ADESCRI  , p.categoria2_id 
   order by 1 desc
GO
