SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE            PROC [cc_BakContabilizaPlanillaCobranza]		/*EN USO*/
@base varchar(50),
@mes  varchar(2),
@ano  varchar(4),
@codvendedor nvarchar(3),
@basecontab varchar(50),
@ctacaja nvarchar(20),
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
If Exists(Select name from tempdb..sysobjects where name=''##tmp_contazz'+@compu+''') 
    Drop Table [##tmp_contazz'+@compu+']'
Exec(@tmpsql) 
SET @tmpsql = 
' 
SELECT	numide=IDENTITY(bigint, 1,1),
        e.abonocancli as CodCliente,
		c.clienterazonsocial as RazonSocial,
		a.documentocargo as DocCargo,
		b.tdocumentodesccorta as DescDocCargo,a.cargonumdoc as NumDocCargo,
		a.cargoapefecemi as FecEmisionCargo,
    	a.monedacodigo,
		cuenta12=case when a.monedacodigo=''01'' then b.tdocumentocuentasoles else b.tdocumentocuentadolares end,
		tcemision=
			case when a.monedacodigo=''02'' then
	    		isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=a.cargoapefecemi),0)  
			else
				1
			end,	
		tccancela=
			case when e.abonocanmoncan=''02'' then
				isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=e.abonocanfecan ),0)
			else
				1
			end,
		e.abonocanmoncan as MonedaAbono,
		ISNULL(e.abonocanimpcan,0) as ImporteAbono,
		e.abonocanfecan as FecCanAbono,
		e.abononumplanilla as PlanillaAbono,
		e.abonocantdqc as CodDocAbono,
		e.abonocanndqc as NumDocAbono,
		e.abonotipoplanilla as TipoPlanilla,
		a.bancocodigo,
        x.pedidotiporefe,
        x.pedidonrorefe,
        x.pedidofechasunat,
        e.abonocannumpag
        into [##tmp_contazz'+@compu+'] 
	FROM 	
		['+@base+'].dbo.vt_cargo a 	
    	JOIN ['+@base+'].dbo.cc_tipodocumento b 
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
        LEFT OUTER JOIN ['+@base+'].dbo.Vt_pedido X 
        On  
        	a.documentocargo=x.pedidotipofac and 
        	a.cargonumdoc=x.pedidonrofact         
         
	WHERE	
	  	month(e.abonocanfecpla)='''+@mes+''' and year(e.abonocanfecpla)='''+@ano+'''  
		AND e.vendedorcodigo LIKE '''+@codvendedor+''' 
		AND h.tplanillacobranza = ''1''
		AND e.abonocanflreg IS NULL 
        ORDER BY e.abonocanfecan,a.clientecodigo  '
exec(@tmpsql)
declare @cadsql1 	varchar(4000)
declare @cadsql2 	varchar(4000)
declare @cadsql3 	varchar(4000)
set @cadsql1= 'SELECT ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''1'',
  	cuenta=ZZ.cuenta12,
	ZZ.ImporteAbono,
	ZZ.FecEmisionCargo,
	ZZ.FecCanAbono,
	cargo=cast(0.00 as numeric(15,2)),		
	abono= CAST(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2) AS NUMERIC(15,2)),
	ZZ.tcemision,
	ZZ.tccancela,
	ZZ.monedacodigo,
	ZZ.monedaAbono, 
    ZZ.pedidotiporefe,
    ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),
    ZZ.abonocannumpag,
    zz.numide  
	FROM  [##tmp_contazz'+@compu+'] as ZZ'
set @cadsql2= ' union all SELECT ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''2'',
  	cuenta=
		case when len(rtrim(ZZ.bancocodigo))=0	
			then  ''' +@ctacaja+ '''
			else  
				case when ZZ.MonedaAbono=''01'' 
					then	(select bancoctactblesoles from [' +@base+ '].dbo.gr_banco as M where M.bancocodigo=ZZ.bancocodigo)
					else	(select bancoctactbledolar from [' +@base+ '].dbo.gr_banco as M where M.bancocodigo=ZZ.bancocodigo)
				end
		end,
	ZZ.ImporteAbono,
	ZZ.FecEmisionCargo,
	ZZ.FecCanAbono,
	cargo=cast(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2) as numeric(15,2)),
	abono= cast(0 as numeric(15,2)),
	ZZ.tcemision,
	ZZ.tccancela,
	ZZ.monedacodigo,
	ZZ.MonedaAbono, 
    ZZ.pedidotiporefe,
    ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,
    ZZ.abonocannumpag,
    zz.numide 
	FROM [##tmp_contazz'+@compu+'] as ZZ'
set @cadsql3= ' union all SELECT ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''3'',
  	cuenta=	
		case when  (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)>0
			then ''' +@ctadifper+ '''
			else
				case when  (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)<0
					then '''+@ctadifgan+ '''
				end
		end,
	ImporteAbono=0,
	ZZ.FecEmisionCargo,
	ZZ.FecCanAbono,
	abono=		
		case when  ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)>0
			then CAST(round( ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)- ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2) ,2) AS NUMERIC(15,2))
			else CAST(0.00 AS NUMERIC(15,2))
		end,
	cargo=
		case when  ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)<0
			then CAST(round(abs(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)),2) AS NUMERIC(15,2))
			else CAST(0.00 AS NUMERIC(15,2))
		end,
	ZZ.tcemision,
	ZZ.tccancela,
	ZZ.monedacodigo,
	ZZ.MonedaAbono,
    ZZ.pedidotiporefe,
    ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,
    ZZ.abonocannumpag,
    zz.numide    
	FROM [##tmp_contazz'+@compu+'] as ZZ
    where (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)<>0	'
--EXEC(@cadsql1+@cadsql2+@cadsql3)
EXEC('select * into [##tmp_conta'+@compu+'] from (' +@cadsql1+@cadsql2+@cadsql3 + ') AS YY' )
RETURN
--exec cc_ContabilizaPlanillaCobranza 'ventas_prueba','01/12/2002','31/12/2002','%','Contaprueba','101101','776101','976101'
--CodCliente,DocCargo,NumDocCargo,PlanillaAbono,Item,cuenta,cargo abono
GO
