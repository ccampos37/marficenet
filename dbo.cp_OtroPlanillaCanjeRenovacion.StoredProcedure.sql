SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [cp_OtroPlanillaCanjeRenovacion] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10),
@fechasta varchar(10),
@codvendedor nvarchar(3),
@codcliente nvarchar(20),
@opcion varchar(1)  /*1=Canje 2=Renovación*/
AS
DECLARE @sensql nvarchar (4000)
Declare @cadsql varchar(300)
if @opcion='1'
	begin
		set @cadsql=' d.tplanillacanjes=''1'''
	end
else
	begin
		set @cadsql=' d.tplanillarenovar=''1'''
	end
set @sensql=' 
select 	A.*,
	ZZ.*,
	e.clienterazonsocial,
	f.tdocumentodesccorta as DescDocAbono,
	g.monedasimbolo as MonAbono,
	h.tdocumentodesccorta as DescDocCargo,
	i.monedasimbolo as MonCargo,
	cargofechaemision=(select cargoapefecemi from [' + @base+ '].dbo.cp_cargo M where 
	M.documentocargo=A.documentoabono and M.cargonumdoc=A.abononumdoc and M.clientecodigo=A.abonocancli),
	cargofechavenci=(select cargoapefecvct from [' + @base+ '].dbo.cp_cargo M where 
	M.documentocargo=A.documentoabono and M.cargonumdoc=A.abononumdoc and M.clientecodigo=A.abonocancli),
	TDRef=isnull( (select pedidotiporefe from [' + @base+ '].dbo.vt_pedido M where
	M.pedidotipofac=A.documentoabono and M.pedidonrofact=A.abononumdoc),''''),
	NDRef=isnull( (select pedidonrorefe from [' + @base+ '].dbo.vt_pedido M where
	M.pedidotipofac=A.documentoabono and M.pedidonrofact=A.abononumdoc),'''')
	from [' + @base+ '].dbo.cp_abono A,
	     (select 	A.* from [' + @base+ '].dbo.cp_cargo A,
		[' + @base+ '].dbo.cp_tipoplanilla d
	     where  
		floor(cast(A.cargoapefecemi as real)) >=' +cast(dbo.fn_datenumber(day(@fecdesde),month(@fecdesde),year(@fecdesde)) as varchar(20)) + ' AND 
		floor(cast(A.cargoapefecemi as real)) <=' +cast(dbo.fn_datenumber(day(@fechasta),month(@fechasta),year(@fechasta)) as varchar(20)) + ' AND
		isnull(cargoapeflgreg,0)<>1 and
		A.abonotipoplanilla=d.tplanillacodigo and '
		+@cadsql+  ' and
		A.clientecodigo like ''%'') as ZZ,
	[' + @base+ '].dbo.cp_proveedor e,
	[' + @base+ '].dbo.cp_tipodocumento f,
	[' + @base+ '].dbo.gr_moneda g,
	[' + @base+ '].dbo.cp_tipodocumento h,
	[' + @base+ '].dbo.gr_moneda i
	where 	A.abononumplanilla=ZZ.abononumplanilla and 
		A.abonotipoplanilla=ZZ.abonotipoplanilla and
		A.abononumplanilla like ''%'' and
		isnull(A.abonocanflreg,0)<>1 and
		A.abonocancli = e.clientecodigo and
		A.documentoabono = f.tdocumentocodigo and
		A.abonocanmoneda = g.monedacodigo and
   		ZZ.documentocargo = h.tdocumentocodigo and
		ZZ.monedacodigo=i.monedacodigo'
exec (@sensql)
--EXEC cp_OtroPlanillaCanjeRenovacion 'acuaplayacasma','01/02/2003','31/03/2007','%','%','1'
				
--select * from ventas_prueba.dbo.vt_abono A where abononumplanilla='000044'
--   A.abononumplanilla=B.abononumplanilla
GO
