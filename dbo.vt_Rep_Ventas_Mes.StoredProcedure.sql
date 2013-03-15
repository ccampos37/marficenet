SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE         PROCEDURE [vt_Rep_Ventas_Mes]
@bdatos varchar(50),
@codalmacen varchar(4),
@fecdesde varchar(10),
@fechasta varchar(10)
--'@tipo varchar(5)
AS
DECLARE @sensql nvarchar (4000)
DECLARE @canje varchar (2)
DECLARE @condi varchar (2)
DECLARE @f varchar (2)
DECLARE @c varchar (2)
set @canje ='04'
set @condi ='0'
set @f ='F'
set @c ='C'
SET @sensql = N'
		
drop table ['+@bdatos+'].dbo.tmpventa
		
select '''+@f+''' as tipo,A.puntovtacodigo,A.pedidotipofac,D.documentodescripcion,sum(B.detpedcantpedida) as Total
	into ['+@bdatos+'].dbo.tmpventa
  from ['+@bdatos+'].dbo.vt_pedido A
	inner join ['+@bdatos+'].dbo.vt_detallepedido B
	on B.pedidonumero=A.pedidonumero
	inner join ['+@bdatos+'].dbo.VT_DOCUMENTO D
	on D.documentocodigo=A.PEDIDOTIPOFAC
  where  A.modovtacodigo<>'''+@canje+''' 
	and A.pedidocondicionfactura='''+@condi+'''
	and A.pedidofechafact between '''+@fecdesde+''' and '''+@fechasta+'''
	and A.almacencodigo='''+@codalmacen+'''
  group by A.puntovtacodigo,A.pedidotipofac,D.documentodescripcion
	order by A.pedidotipofac
		
insert ['+@bdatos+'].dbo.tmpventa
	select '''+@c+''', A.puntovtacodigo, A.pedidotipofac,C.modovtadescripcion, sum(B.detpedcantpedida) 
	from ['+@bdatos+'].dbo.vt_pedido A
	inner join ['+@bdatos+'].dbo.vt_detallepedido B
	on B.pedidonumero= A.pedidonumero
	inner join ['+@bdatos+'].dbo.vt_modoventa C
	on A.modovtacodigo =C.modovtacodigo
	where  A.modovtacodigo='''+@canje+''' 
	and A.pedidocondicionfactura='''+@condi+'''
	and A.pedidofechafact between '''+@fecdesde+''' and '''+@fechasta+'''
	and A.almacencodigo='''+@codalmacen+'''
	group by A.puntovtacodigo, A.pedidotipofac,C.modovtadescripcion
		order by A.pedidotipofac
		
		select * from ['+@bdatos+'].dbo.tmpventa
	'
--print	(@sensql)
execute (@sensql)
--ORDER BY A.pedidotipofac,A.pedidonrofact
-----and A.puntovtacodigo='''+@codalmacen+'''
-- execute vt_Rep_Ventas_Mes 'ziyaz','01','01/08/2008','30/10/2008'
GO
