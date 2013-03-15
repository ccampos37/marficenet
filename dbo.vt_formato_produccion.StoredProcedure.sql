SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC [vt_formato_produccion] 'ziyaz','02','%%'
select * from ziyaz.dbo.v_almacenyventas where empresacodigo='02'
select * FROM desarrollo.DBO.tabalm

*/ 

CREATE PROC [vt_formato_produccion]		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@almacen varchar(2)

AS
DECLARE @sensql nvarchar (4000)

SET @sensql = 'SELECT clienterazonsocial=case when z.tipo<>''3'' then b.clienterazonsocial 
               else c.empresadescripcion  end,
Descripcion=(case tipo when ''1'' then d.documentodescripcion 
                       when ''2''  then ''PEDIDO''
	else e.tipoordendescripcion
	end), z.* from
(
SELECT PEDIDONUMERO as [Nro Pedido],pedidofechafact as [Fecha Emision],Pedidofecha as [Fecha Entrega],
horaentrega as [Hora Entrega],pedidoentrega as [Destino],pedidotipofac as Doc,pedidonrofact as [Nro Documento],
---detpeditem as Item,
productocodigo,adescri as Producto,cantidad=detpedcantpedida-sum(isnull(decantid,0)) ,
clienteruc,tipo,a.empresacodigo,venta,almacencodigo as Origen,Solicitante,traslado
from  ['+@base+'].dbo.tabalm a
inner join ['+@base+'].dbo.v_almacenyventas b on taalma=almacencodigo 
where  a.empresacodigo='''+@empresa+'''  '
if @almacen<>'%' and @almacen<>'%%' set @sensql=@sensql+' and taalma ='''+@almacen+'''  '
set @sensql=@sensql+' and isnull(B.CATD,''NS'')<>''NI'' 
group by PEDIDONUMERO,pedidofechafact,Pedidofecha,horaentrega,pedidoentrega,pedidotipofac,pedidonrofact,
productocodigo,adescri,detpedcantpedida,venta,almacencodigo,solicitante,traslado,tipo ,clienteruC,a.empresacodigo
having detpedcantpedida-sum(isnull(decantid,0))>0 
) z
left join ['+@base+'].dbo.vt_cliente b on z.clienteruc=b.clienteruc  
left join ['+@base+'].dbo.co_multiempresas c on z.empresacodigo=c.empresacodigo
left join ['+@base+'].dbo.vt_documento d on z.Doc=d.documentocodigo 
left join ['+@base+'].dbo.co_tipodeorden e on z.Doc=e.tipoordencodigo 
 ' 

EXECUTE(@sensql)

---and b.pedidofechafact>''14/08/2011''
GO
