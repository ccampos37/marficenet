SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
cp_GeneraTempAsientoPagarenLinea_pro
execute cp_GeneraTempAsientopagarenLinea_pro 'planta_cASMA','03','12','2011','%%','planta_casma','771100','671100','##xxxxxxxxxxxxxxxxxx'

select * from ##tmp_conta##xx order by 5

*/

CREATE PROC [cp_GeneraTempAsientoPagarenLinea_pro]		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@mes  varchar(2),
@ano  varchar(4),
@codvendedor nvarchar(3),
@basecontab varchar(50),
@ctadifgan nvarchar(20),
@ctadifper nvarchar(20),
@compu varchar(50)
AS
DECLARE @tmpsql varchar (8000)
Set @tmpsql='
If Exists(Select name from tempdb..sysobjects where name=''##tmp_conta'+@compu+''') 
    Drop Table [##tmp_conta'+@compu+']'
Exec(@tmpsql) 
Set @tmpsql='
If Exists(Select name from tempdb..sysobjects where name=''##tmp_contaDif'+@compu+''') 
    Drop Table [##tmp_contaDif'+@compu+']'
Exec(@tmpsql) 

Set @tmpsql='
If Exists(Select name from tempdb..sysobjects where name=''##tmp_contazz'+@compu+''') 
    Drop Table [##tmp_contazz'+@compu+']'
Exec(@tmpsql) 
SET @tmpsql = '	SELECT numide=IDENTITY(bigint, 1,1),
a.empresacodigo,e.abonocancli as CodCliente,abonocantipcam,
c.clienterazonsocial as RazonSocial,b.tdocumentodesccorta as DescDoccargo,g.tdocumentodesccorta as DescDocabono,
Doccargo=a.documentocargo ,NumDoccargo=a.cargonumdoc,
Docabono=e.abonocantdqc,NumDocabono=e.abonocanndqc,
a.cargoapefecemi as FecEmisionCargo,a.monedacodigo,
descripciontipoplanilla=h.tplanilladescripcion,
cuentacargo=case when e.abonocanmoncan=''01'' then g.tdocumentocuentasoles else g.tdocumentocuentadolares end,
cuentaabono=case when a.monedacodigo=''01'' then b.tdocumentocuentasoles else b.tdocumentocuentadolares end,
tcemision=case when a.monedacodigo=''02'' then
	            isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=a.cargoapefecemi),1)  
	       else 1 	end,	
tccancela=case when e.abonocanmoncan=''02'' then
				isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=aa.cargoapefecemi ),1)
      	else
				1
			end,
e.abonocanmoncan as MonedaAbono,
ISNULL(e.abonocanimpcan,0) as ImporteAbono,isnull(aa.cargoapefecemi,e.abonocanfecan) as FecCanAbono,
e.abononumplanilla as PlanillaAbono,pedidotiporefe='' '',pedidonrorefe='' '',
pedidofechasunat=e.abonocanfecpla,e.abonotipoplanilla as TipoPlanilla,a.bancocodigo,e.abonocannumpag   
into [##tmp_contazz'+@compu+'] 
FROM 	['+@base+'].dbo.cp_cargo a 	
inner JOIN ['+@base+'].dbo.cp_tipodocumento b ON a.documentocargo = b.tdocumentocodigo 
inner JOIN ['+@base+'].dbo.cp_proveedor c ON a.clientecodigo = c.clientecodigo
		JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo
inner Join ['+@base+'].dbo.cp_abono e 
                   ON a.clientecodigo=e.abonocancli and a.documentocargo = e.documentoabono AND a.cargonumdoc = e.abononumdoc
		JOIN ['+@base+'].dbo.cp_tipodocumento g ON g.tdocumentocodigo = e.abonocantdqc
		JOIN ['+@base+'].dbo.cp_tipoplanilla h ON h.tplanillacodigo = e.abonotipoplanilla
left Join ['+@base+'].dbo.cp_cargo aa 
                   ON e.abonocancli=aa.clientecodigo and e.abonocantdqc=aa.documentocargo AND e.abonocanndqc=aa.cargonumdoc
         WHERE	a.empresacodigo='''+@empresa+''' and 
	  	month(e.abonocanfecpla)='''+@mes+''' and year(e.abonocanfecpla)='''+@ano+'''  
		AND e.vendedorcodigo LIKE '''+@codvendedor+'''
        AND (h.tplanillacobranza = ''1'' ) and b.tdocumentotipo=''C''
		AND isnull(e.abonocanflreg,0)<>1 
        ORDER BY e.abonocanfecan,a.clientecodigo  '

execute(@tmpsql)


declare @cadsql1 	varchar(4000)
declare @cadsql2 	varchar(4000)
declare @cadsql3 	varchar(4000)
set @cadsql1= 'Select * into [##tmp_contaDif'+@compu+'] from 
( SELECT zz.empresacodigo,ZZ.CodCliente,DocCargo=ZZ.Docabono,NumDocCargo=ZZ.NumDocabono,ZZ.PlanillaAbono,
Item=''1'',cuenta=ZZ.cuentaabono,ZZ.ImporteAbono,ZZ.FecEmisionCargo,ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo=case when zz.MonedaAbono=''01''  then  
	      CAST(ISNULL(ZZ.ImporteAbono,0) AS NUMERIC(15,2)) else
	      CAST(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela AS NUMERIC(15,2)) end,
	abono=cast(0.00 as numeric(15,2)),		
	ZZ.tcemision,ZZ.tccancela,ZZ.monedacodigo,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat, ZZ.abonocannumpag,
    zz.numide,zz.descripciontipoplanilla,glosa = rtrim(DescDocabono)+'' ''+Docabono+'' ''+NumDocabono,
	 dolares= case when ZZ.monedacodigo=''02'' then ISNULL(ZZ.ImporteAbono,0) else 0 end
	FROM  [##tmp_contazz'+@compu+'] as ZZ'
set @cadsql2= ' union all 
SELECT zz.empresacodigo,ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''2'',
  	cuenta= ZZ.cuentacargo,ZZ.ImporteAbono,ZZ.FecEmisionCargo,	ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo= cast(0 as numeric(15,2)),
	abono= case when zz.MonedaAbono=''01''  then  
	      CAST(ISNULL(ZZ.ImporteAbono,0) AS NUMERIC(15,2)) else
	      CAST(ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision AS NUMERIC(15,2)) end,
	ZZ.tcemision,ZZ.tccancela,ZZ.MonedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,ZZ.abonocannumpag,zz.numide,zz.descripciontipoplanilla,glosa=rtrim(DescDoccargo)+'' ''+Doccargo+'' ''+NumDoccargo,
	 dolares= case when ZZ.MonedaAbono=''02'' then ISNULL(ZZ.ImporteAbono,0) else 0 end
	FROM [##tmp_contazz'+@compu+'] as ZZ ) yy '

execute (@cadsql1+@cadsql2)

set @cadsql3= '      SELECT zz.empresacodigo,ZZ.CodCliente,'''','''',ZZ.PlanillaAbono,Item=''3'',
  	cuenta=	case when  round(sum(cargo-abono) ,2) > 0 then ''' +@ctadifgan+ ''' else '''+@ctadifper+ ''' end,
	ImporteAbono=0,'''','''',centrocostocodigo=''40100'',
	cargo=  case when  round(sum(cargo-abono) ,2) < 0 then abs(round(sum(cargo-abono) ,2)) else 0 end,
    abono=	case when  round(sum(cargo-abono) ,2) > 0 then round(sum(cargo-abono) ,2) else 0 end,
	ZZ.tcemision,ZZ.tccancela,''01'',ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,ZZ.abonocannumpag,zz.numide,zz.descripciontipoplanilla,
    glosa='' Aj. Dif. de Cambio Planilla ''+ zz.PlanillaAbono,Dolares=0
	FROM [##tmp_contaDif'+@compu+'] as ZZ
	group by zz.empresacodigo,ZZ.CodCliente,ZZ.PlanillaAbono,ZZ.FecEmisionCargo,ZZ.FecCanAbono,ZZ.tcemision,ZZ.tccancela,
	ZZ.pedidotiporefe,ZZ.pedidonrorefe,ZZ.pedidofechasunat,ZZ.abonocannumpag,zz.numide,zz.descripciontipoplanilla,zz.PlanillaAbono
    having  round(sum(cargo-abono) ,2) <> 0 '

execute ('select * into [##tmp_conta'+@compu+'] from ( select * from [##tmp_contaDif'+@compu+'] union all '+@cadsql3 + ') AS YY' )

RETURN








--select * from ##tmp_contaxx


/****** Object:  StoredProcedure [dbo].[cp_GeneraAsientoPagarenLinea_pro]    Script Date: 03/10/2012 11:00:27 ******/
SET ANSI_NULLS ON
GO
