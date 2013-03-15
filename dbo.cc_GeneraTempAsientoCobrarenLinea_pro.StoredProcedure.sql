SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [cc_GeneraTempAsientoCobrarenLinea_pro] 'ziyaz','02','01','2010','%%','ziyaz','771100','671100','##xx'
select * from ##tmp_conta##xx

*/


CREATE    PROC [cc_GeneraTempAsientoCobrarenLinea_pro]		/*EN USO*/
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
If Exists(Select name from tempdb..sysobjects where name=''##tmp_contazz'+@compu+''') 
    Drop Table [##tmp_contazz'+@compu+']'
Exec(@tmpsql) 
SET @tmpsql = '	SELECT numide=IDENTITY(bigint, 1,1),a.empresacodigo,e.abonocancli as CodCliente,
c.clienterazonsocial as RazonSocial,b.tdocumentodesccorta as DescDocabono,b.tdocumentotipo,
Docabono=(case when isnull(b.tdocumentosunat,'''')<>'''' then b.tdocumentosunat else a.documentocargo end ) ,NumDocabono=a.cargonumdoc,
Doccargo=e.abonocantdqc,NumDoccargo=e.abonocanndqc,
a.cargoapefecemi as FecEmisionCargo,a.monedacodigo,
cuentaabono=case when a.monedacodigo=''01'' then b.tdocumentocuentasoles else b.tdocumentocuentadolares end,
cuentacargo=case when a.monedacodigo=''01'' then g.tdocumentocuentasoles else g.tdocumentocuentadolares end,
tcemision=case when e.abonocanmoncan=''02'' then
	            isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=a.cargoapefecemi),0)  
	       else 1 	end,	
tccancela=case when e.abonocanmoncan=''02'' then
				isnull((select tipocambioventa from [' +@basecontab+ '].dbo.ct_tipocambio as M where M.tipocambiofecha=e.abonocanfecan ),0)
      	else
				1
			end,
e.abonocanmoncan as MonedaAbono,ISNULL(e.abonocanimpcan,0) as ImporteAbono,e.abonocanfecan as FecCanAbono,
e.abononumplanilla as PlanillaAbono,
e.abonotipoplanilla as TipoPlanilla,a.bancocodigo,x.pedidotiporefe,x.pedidonrorefe, x.pedidofechasunat,
e.abonocannumpag   into [##tmp_contazz'+@compu+'] 
FROM 	['+@base+'].dbo.vt_cargo a 	
inner JOIN ['+@base+'].dbo.cc_tipodocumento b ON a.documentocargo = b.tdocumentocodigo 
inner JOIN ['+@base+'].dbo.vt_cliente c ON a.clientecodigo = c.clientecodigo
		JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo
		JOIN ['+@base+'].dbo.vt_abono e 
                   ON a.empresacodigo=e.empresacodigo and a.documentocargo = e.documentoabono AND a.cargonumdoc = e.abononumdoc
		JOIN ['+@base+'].dbo.cc_tipodocumento g ON g.tdocumentocodigo = e.abonocantdqc
		JOIN ['+@base+'].dbo.cc_tipoplanilla h ON h.tplanillacodigo = e.abonotipoplanilla
                LEFT OUTER JOIN ['+@base+'].dbo.Vt_pedido X On  
        	a.empresacodigo=x.empresacodigo and a.documentocargo=x.pedidotipofac and a.cargonumdoc=x.pedidonrofact         
         WHERE	a.empresacodigo='''+@empresa+''' and 
	  	month(e.abonocanfecpla)='''+@mes+''' and year(e.abonocanfecpla)='''+@ano+'''  
		AND e.vendedorcodigo LIKE '''+@codvendedor+''' 
		AND ( h.tplanillacobranza = ''1'' and b.tdocumentotipo=''C'' or h.tplanillaajustes = ''1'' and b.tdocumentotipo=''A'' ) 
		AND isnull(e.abonocanflreg,0)<>1 
        ORDER BY e.abonocanfecan,a.clientecodigo  '

execute(@tmpsql)

declare @cadsql1 	varchar(4000)
declare @cadsql2 	varchar(4000)
declare @cadsql3 	varchar(4000)

--- item=1 , es para froma de pago
--- item=2 , es para el documento de origen
 
set @cadsql1= 'SELECT zz.empresacodigo,ZZ.CodCliente,DocCargo=ZZ.Docabono,NumDocCargo=ZZ.NumDocabono,ZZ.PlanillaAbono,
Item=''2'',cuenta=ZZ.cuentaabono,ZZ.ImporteAbono,ZZ.FecEmisionCargo,ZZ.FecCanAbono,
	cargo=case when  tdocumentotipo=''C''  then cast(0.00 as numeric(15,2)) else CAST(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2) AS NUMERIC(15,2)) end ,		
	abono=Case when  tdocumentotipo=''C''  then CAST(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2) AS NUMERIC(15,2)) else cast(0.00 as numeric(15,2)) end ,
	ZZ.tcemision,ZZ.tccancela,ZZ.monedacodigo,ZZ.monedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),ZZ.abonocannumpag,
    zz.numide,
	 dolares= case when ZZ.monedacodigo=''02'' then ISNULL(ZZ.ImporteAbono,0) else 0 end
	FROM  [##tmp_contazz'+@compu+'] as ZZ'
set @cadsql2= ' union all 
SELECT zz.empresacodigo,ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''1'',
  	cuenta= ZZ.cuentacargo,ZZ.ImporteAbono,ZZ.FecEmisionCargo,	ZZ.FecCanAbono,
	cargo= case when tdocumentotipo=''C'' then cast(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2) as numeric(15,2)) else cast(0 as numeric(15,2)) end ,
	abono= case when tdocumentotipo=''C'' then cast(0 as numeric(15,2)) else cast(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2) as numeric(15,2)) end ,
	ZZ.tcemision,ZZ.tccancela,ZZ.monedacodigo,ZZ.MonedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,ZZ.abonocannumpag,zz.numide,
	 dolares= case when ZZ.MonedaAbono=''02'' then ISNULL(ZZ.ImporteAbono,0) else 0 end
	FROM [##tmp_contazz'+@compu+'] as ZZ'
set @cadsql3= ' union all 
        SELECT zz.empresacodigo,ZZ.CodCliente,ZZ.DocCargo,ZZ.NumDocCargo,ZZ.PlanillaAbono,Item=''3'',
  	cuenta=	case when  (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)>0
			then ''' +@ctadifper+ '''
			else
				case when  (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)<0
					then '''+@ctadifgan+ '''
				end
		end,
	ImporteAbono=0,ZZ.FecEmisionCargo,ZZ.FecCanAbono,
         abono=	case when  ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)>0
			then CAST(round( ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)- ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2) ,2) AS NUMERIC(15,2))
			else CAST(0.00 AS NUMERIC(15,2))
		end,
	cargo=case when  ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)<0
			then CAST(round(abs(ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision),2)-ROUND((ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela),2)),2) AS NUMERIC(15,2))
			else CAST(0.00 AS NUMERIC(15,2))
		end,
	ZZ.tcemision,ZZ.tccancela,ZZ.monedacodigo,ZZ.MonedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    ZZ.pedidofechasunat,ZZ.abonocannumpag,zz.numide,Dolares=0
	FROM [##tmp_contazz'+@compu+'] as ZZ
    where (ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision)-(ISNULL(ZZ.ImporteAbono,0)*ZZ.tccancela)<>0	'

execute('select * into [##tmp_conta'+@compu+'] from (' +@cadsql1+@cadsql2+@cadsql3 + ') AS YY' )
RETURN
GO
