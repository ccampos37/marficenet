SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE          PROC [cc_EMLB_Otro_BKPlanillaCanjeRenovacion] 		/*EN USO*/
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
		set @cadsql=' AND h.tplanillacanjes=''1'''
	end
else
	begin
		set @cadsql=' AND h.tplanillarenovar=''1'''
	end
SET @sensql = N'
SELECT 	e.abonocancli as Cod_Cliente,c.clienterazonsocial as Razon_Social,
	e.vendedorcodigo as Cod_Vendedor,e.documentoabono as Cod_Doc_Cargo,
	b.tdocumentodesccorta as Desc_Doc_Cargo,e.abononumdoc as Num_Doc_Cargo,
	a.cargoapefecemi as Fec_Emision_Cargo,
	e.abonocanforcan as Forma_Pago,d.monedasimbolo, 
	ISNULL(e.abonocanimpcan,0) as Importe_Abono,
	e.abonocanmoncan as MonedaAbono,
  	simbolo_mon_abo=(select M.monedasimbolo from [' +@base+ '].dbo.gr_moneda as M where M.monedacodigo=e.abonocanmoncan),
	e.abonocantdqc as Cod_Doc_Abono,g.tdocumentodesccorta as Desc_Doc_Abono,
	e.abonocanndqc as Num_Doc_Abono,e.abonocanfecan as Fec_Cancela_Abono,
	e.abononumplanilla as Num_Planilla, e.abonotipoplanilla as Tipo_Planilla,
	tipopago=
		case when a.cargoapefecemi=e.abonocanfecan and e.abonocanforcan=''T''
			then ''CO'' else ''CR''
		end
FROM 	
	['+@base+'].dbo.vt_cargo a 
	JOIN 
	['+@base+'].dbo.cc_tipodocumento b 
	ON  
	a.documentocargo = b.tdocumentocodigo 
	JOIN
	['+@base+'].dbo.vt_cliente c
	ON
	a.clientecodigo = c.clientecodigo
	JOIN
	['+@base+'].dbo.gr_moneda d
	ON
	a.monedacodigo = d.monedacodigo
	JOIN
	['+@base+'].dbo.vt_abono e
	ON
	a.documentocargo = e.documentoabono
	AND a.cargonumdoc = e.abononumdoc
	JOIN
	['+@base+'].dbo.cc_tipodocumento g
	ON
	g.tdocumentocodigo = e.abonocantdqc
	JOIN
	['+@base+'].dbo.cc_tipoplanilla h
	ON
	h.tplanillacodigo = e.abonotipoplanilla
WHERE	
	e.abonocanfecpla BETWEEN '''+@fecdesde+''' AND '''+@fechasta+''' 
	AND e.vendedorcodigo LIKE '''+@codvendedor+''' 
	AND ltrim(rtrim(a.clientecodigo))  LIKE '''+@codcliente+'''
	AND e.abonocanflreg IS NULL '
set @sensql= @sensql+@cadsql + '
			ORDER BY 
	 		e.abonotipoplanilla,e.abononumplanilla,e.abononumdoc,e.abonocanforcan '
exec (@sensql)
RETURN
--EXEC cc_EMLB_OtroPlanillaCanjeRenovacion 'ventas_prueba','01/05/2002','30/11/2002','%','68','1'
--select * from ventas_prueba.dbo.vt_cargo where clientecodigo='68'
--select * from ventas_prueba.dbo.vt_abono where abonocancli='68'
--select * from ventas_prueba.dbo.vt_cargo A,
--	(select A.* from 	ventas_prueba.dbo.vt_cargo A, 
--			ventas_prueba.dbo.vt_abono B
--	where 
--  	A.documentocargo=B.documentoabono and 
--   	A.cargonumdoc=B.abononumdoc and
--   	A.clientecodigo=B.abonocancli and
--   	A.clientecodigo like '%' and
--   	A.cargoapefecemi between '01/10/2002' and '30/01/2003') as ZZ --and
--where 
--	A.documentocargo=ZZ.documentocargo and
--	A.cargonumdoc=ZZ.cargonumdoc	and
--	A.clientecodigo=ZZ.clientecodigo and
--	A.abonotipoplanilla='03'
	
select 	A.*,
			ZZ.*,
			e.clienterazonsocial,
			f.tdocumentodesccorta as DescDocAbono,
			g.monedasimbolo,
			h.tdocumentodesccorta as DescDocCargo,
			i.monedasimbolo
	from ventas_prueba.dbo.vt_abono A,
	(select A.* from ventas_prueba.dbo.vt_cargo A,
						ventas_prueba.dbo.cc_tipoplanilla d
		where A.abonotipoplanilla='03' and 
			A.cargoapefecemi between '01/10/2002' and '10/02/2003' and
			isnull(cargoapeflgreg,0)<>1 and
			A.abonotipoplanilla=d.tplanillacodigo and
			d.tplanillacanjes='1' and
			A.clientecodigo like '%') as ZZ,
	ventas_prueba.dbo.vt_cliente e,
	ventas_prueba.dbo.cc_tipodocumento f,
	ventas_prueba.dbo.gr_moneda g,
	ventas_prueba.dbo.cc_tipodocumento h,
	ventas_prueba.dbo.gr_moneda i
where A.abononumplanilla=ZZ.abononumplanilla and 
		A.abonotipoplanilla=ZZ.abonotipoplanilla and
		A.abononumplanilla like '%' and
		isnull(A.abonocanflreg,0)<>1 and
		A.abonocancli = e.clientecodigo and
		A.documentoabono = f.tdocumentocodigo and
		A.abonocanmoneda = g.monedacodigo and
   	ZZ.documentocargo = h.tdocumentocodigo and
		ZZ.monedacodigo=i.monedacodigo				
--select * from ventas_prueba.dbo.vt_abono A where abononumplanilla='000044'
--   A.abononumplanilla=B.abononumplanilla
GO
