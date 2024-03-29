SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Renovaciones , Canjes

cp_GeneraTempAsientoPagarenLinea_pro
execute cp_GeneraTempAsientopagarenLinea1_pro 'aliterm2012','01','08','2012','%%','aliterm2012','7711000','6711000','##xx'
select * from ##tmp_contazz##xx


select * from ziyaz.dbo.cp_cargo where abononumplanilla='000699'


CANJES -- RENOVACIONES


*/

ALTER PROC [cp_GeneraTempAsientoPagarenLinea1_pro]		/*EN USO*/
@base varchar(50),
@empresa varchar(2),
@mes  varchar(2),
@ano  varchar(4),
@numero nvarchar(8),
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
SET @tmpsql = '	SELECT numide=e.tplanillacodigo+e.abononumplanilla,
a.empresacodigo,e.tipo,e.clientecodigo as CodCliente,
c.clienterazonsocial as RazonSocial,b.tdocumentodesccorta as DescDocabono,
Doccargo=e.documentocargo,NumDoccargo=e.cargonumdoc,
a.cargoapefecemi as FecEmisionCargo,a.monedacodigo,
descripciontipoplanilla=h.tplanilladescripcion,fechaplanilla=e.cargoapefecpla,
cuentacargo=case when a.monedacodigo=''01'' then b.tdocumentocuentasoles else b.tdocumentocuentadolares end,
tcemision=isnull(tipocambioventa ,1),	
e.monedacodigo as MonedaAbono,e.importe,
ImporteCargo=case when g.tdocumentotipo=''C'' then ISNULL(e.cargo,0) else ISNULL(e.abono,0) end,
ImporteAbono= case when g.tdocumentotipo=''C'' then ISNULL(e.abono,0) else ISNULL(e.cargo,0) end ,
e.cargoapefecemi as FecCanAbono,
e.abononumplanilla as PlanillaAbono,pedidotiporefe='' '',pedidonrorefe='' '',
pedidofechasunat=e.cargoapefecemi,e.tplanillacodigo as TipoPlanilla,a.bancocodigo
into [##tmp_contazz'+@compu+'] FROM 	['+@base+'].dbo.cp_cargo a 	
inner JOIN ['+@base+'].dbo.cp_tipodocumento b ON a.documentocargo = b.tdocumentocodigo 
inner JOIN ['+@base+'].dbo.cp_proveedor c ON a.clientecodigo = c.clientecodigo
inner JOIN ['+@base+'].dbo.gr_moneda d ON a.monedacodigo = d.monedacodigo
inner JOIN ( select tipo=2 , a.empResacodiGo, tplanillacodigo,abononumplanilla,tplanilladescripcion,clientecodigo,documentocargo, cargonumdoc,cargoapefecemi,
                    cargoapefecvct,a.monedacodigo,cargo=0000000000.00 ,
                    abono=case when a.monedacodigo=''01'' then cargoapeimpape else round(cargoapeimpape* isnull(tipocambioventa ,1),2) end ,
                    cargoaperefere,cargoapefecpla,tipocambioventa, importe=cargoapeimpape
                    from [' + @base+ '].dbo.cp_cargo a 
                   inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
                   inner join [' +@basecontab+ '].dbo.ct_tipocambio M  on a.cargoapefecemi=M.tipocambiofecha	
                   where 	month(a.cargoapefecpla)='''+@mes+''' and year(a.cargoapefecemi)='''+@ano+''' and isnull(cargoapeflgreg,0)<>1 
                         AND ( d.tplanillacanjes = ''1'' or d.tplanillarenovar=''1'' ) and a.abononumplanilla like ('''+@numero+''')
            union all
            select 	tipo=1 , a.empresAcodigo, tplanillacodigo,a.abononumplanilla,tplanilladescripcion,abonocancli,a.documentoabono, a.abononumdoc,b.cargoapefecemi ,
                        a.abonocanfecan,a.abonocanmoncan , 
                       cargo=case when a.abonocanmoncan=''01'' then a.abonocanimcan else a.abonocanimcan * isnull(tipocambioventa ,1) end ,
                       abono=00000000.00, b.cargoaperefere,abonocanfecpla,tipocambioventa , importe=a.abonocanimcan
            from [' + @base+ '].dbo.cp_abono a 
           inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
           left join  [' + @base+ '].dbo.cp_cargo b 
                on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
           inner join [' +@basecontab+ '].dbo.ct_tipocambio M on b.cargoapefecemi=M.tipocambiofecha	
           where month(a.abonocanfecpla)='''+@mes+''' and year(a.abonocanfecpla)='''+@ano+'''  and isnull(abonocanflreg,0)<>1 
                 AND ( d.tplanillacanjes = ''1'' or d.tplanillarenovar=''1'' ) and a.abononumplanilla like ('''+@numero+''' )
       ) e ON a.empresacodigo+a.clientecodigo=e.empresacodigo+e.clientecodigo and a.documentocargo+a.cargonumdoc = e.documentocargo+e.cargonumdoc
inner jOIN ['+@base+'].dbo.cp_tipodocumento g ON g.tdocumentocodigo = e.documentocargo
inner JOIN ['+@base+'].dbo.cp_tipoplanilla h ON h.tplanillacodigo = e.tplanillacodigo
WHERE	a.empresacodigo='''+@empresa+''' AND e.tplanillacodigo+e.abononumplanilla LIKE '''+@numero+''' 
		AND ( h.tplanillacanjes = ''1'' or h.tplanillarenovar=''1'' ) ORDER BY e.tplanillacodigo,e.abononumplanilla,e.tipo  '

execute(@tmpsql)

declare @cadsql1 	varchar(4000)
declare @cadsql2 	varchar(4000)
declare @cadsql3 	varchar(4000)
set @cadsql1= 'SELECT zz.empresacodigo,zz.numide,ZZ.CodCliente,DocCargo, NumDocCargo, ZZ.PlanillaAbono,
Item=''1'',cuenta=ZZ.cuentacargo,ZZ.Importe,ZZ.FecEmisionCargo,ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo= CAST(ROUND((ISNULL(ZZ.Importecargo,0)),2) AS NUMERIC(15,2)),
	abono= CAST(ROUND((ISNULL(ZZ.Importeabono,0)),2) AS NUMERIC(15,2)),
	ZZ.tcemision,ZZ.monedacodigo,ZZ.monedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),zz.fechaplanilla,zz.descripciontipoplanilla,operacioncodigo=''04''
	FROM  [##tmp_contazz'+@compu+'] as ZZ where tipo=''1'' '
set @cadsql2= ' union all 
SELECT zz.empresacodigo,zz.numide,ZZ.CodCliente,DocCargo, NumDocCargo, ZZ.PlanillaAbono,
Item=''2'',cuenta=ZZ.cuentacargo,zz.importe,ZZ.FecEmisionCargo,ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo= CAST(ROUND((ISNULL(ZZ.Importecargo,0)),2) AS NUMERIC(15,2)),
	abono= CAST(ROUND((ISNULL(ZZ.Importeabono,0)),2) AS NUMERIC(15,2)),
	ZZ.tcemision,ZZ.monedacodigo,ZZ.monedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),zz.fechaplanilla,zz.descripciontipoplanilla,operacioncodigo=''01''
	FROM  [##tmp_contazz'+@compu+'] as ZZ where tipo=''2''  '
set @cadsql3= ' union all 
        SELECT zz.empresacodigo,zz.numide,'' '','' '','' '',ZZ.PlanillaAbono,Item=''3'',
  	cuenta=	case when  sum((ISNULL(ZZ.importecargo,0)))-sum((ISNULL(ZZ.ImporteAbono,0)))>0 then ''' +@ctadifgan+ '''
			     else '''+@ctadifper+ ''' end,
	Importe=0,ZZ.Fechaplanilla,ZZ.Fechaplanilla,centrocostocodigo=''40100'',
	cargo=case when  sum(round(ISNULL(ZZ.importecargo,0),2))-sum(round(ISNULL(ZZ.ImporteAbono,0),2))>=0 then 0
			     else abs (sum(round(ISNULL(ZZ.importecargo,0),2))-sum(round(ISNULL(ZZ.ImporteAbono,0),2))) 
               end ,
	abonoo=case when  sum((ISNULL(ZZ.importecargo,0)))-sum((ISNULL(ZZ.ImporteAbono,0)))>=0 then 
			              abs (sum(round(ISNULL(ZZ.importecargo,0),2))-sum(round(ISNULL(ZZ.ImporteAbono,0),2)) ) 
                else 0 end ,
	1,''01'',''01'','' '','' '',zz.fechaplanilla,zz.fechaplanilla,zz.descripciontipoplanilla,operacioncodigo=''04''
	FROM [##tmp_contazz'+@compu+'] as ZZ
    group by zz.empresacodigo,zz.numide,ZZ.PlanillaAbono,zz.fechaplanilla,zz.descripciontipoplanilla 
    having sum(round(ISNULL(ZZ.ImporteCargo,0)*ZZ.tcemision,2))-sum(round(ISNULL(ZZ.ImporteAbono,0)*ZZ.tcemision,2))<>0	
'

execute ('select * into [##tmp_conta'+@compu+'] 
from (' +@cadsql1+@cadsql2+@cadsql3 + ' ) AS YY   where cargo+abono > 0 ' )
