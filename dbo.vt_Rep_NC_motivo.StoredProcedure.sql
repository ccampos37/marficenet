SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec [vt_Rep_NC_motivo] 'ziyaz','03','01/01/2008','01/12/2009','A'

*/
CREATE          PROCEDURE [vt_Rep_NC_motivo]
@base varchar(50),
@empresa char(2),
@fecdesde varchar(10),
@fechasta varchar(10),
@tipo varchar(1)
AS
DECLARE @sensql nvarchar (4000)
declare @filtro varchar (100)
declare @filtro2 varchar (200)
if @tipo='T' 
  begin
	SET @sensql = N'
	select 
		A.pedidotipofac,A.pedidonrofact,A.clientecodigo,
		A.clienterazonsocial,a.pedidototneto,C.conceptocodigo,
		C.conceptodescripcion,B.CARGOAPEFECEMI
	from ['+@base+'].dbo.vt_pedido A
		inner join 
		['+@base+'].dbo.vt_cargo B
			on a.empresacodigo=b.empresacodigo and a.clientecodigo=b.clientecodigo and B.documentocargo=A.pedidotipofac and 
			   B.cargonumdoc=A.pedidonrofact 
		inner join 
		['+@base+'].dbo.cc_conceptos C
			on C.conceptocodigo=B.conceptocodigo
		inner join ['+@base+'].dbo.cc_parametro D
			on B.documentocargo=D.tdocumentonotaabono or
		   	B.documentocargo=D.tdocumentonotacargo 
	WHERE a.empresacodigo='''+@empresa+''' and 
		B.CARGOAPEFECEMI BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	ORDER BY A.pedidotipofac,A.pedidonrofact'
	
	exec (@sensql)
  end
If @tipo <>'T'
Begin
	if @tipo='A'  set @filtro=' B.documentocargo=D.tdocumentonotaabono '
	if @tipo='C'  set @filtro='B.documentocargo=D.tdocumentonotacargo'
		
	set @sensql = N'
	select 
		A.pedidotipofac,A.pedidonrofact,A.clientecodigo,
		A.clienterazonsocial,a.pedidototneto ,C.conceptocodigo,
		C.conceptodescripcion,B.CARGOAPEFECEMI
	from ['+@base+'].dbo.vt_pedido A
		inner join ['+@base+'].dbo.vt_cargo B
			on a.empresacodigo=b.empresacodigo and B.documentocargo=A.pedidotipofac and 
			   B.cargonumdoc=A.pedidonrofact 
		inner join ['+@base+'].dbo.cc_conceptos C
			on C.conceptocodigo=B.conceptocodigo
		inner join ['+@base+'].dbo.cc_parametro D
			on '+@filtro+' 
	WHERE a.empresacodigo='''+@empresa+''' and     
		B.CARGOAPEFECEMI BETWEEN '''+@fecdesde+''' and '''+@fechasta+'''
	ORDER BY A.pedidotipofac,A.pedidonrofact'
	exec (@sensql)
end
return
GO
