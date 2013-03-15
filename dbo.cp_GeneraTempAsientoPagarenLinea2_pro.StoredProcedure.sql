SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
cp_GeneraTempAsientoPagarenLinea_pro
execute [cp_GeneraTempAsientoPagarenLinea2_pro] 'planta_casma','03','12','2011','%%','planta_casma','7761000','6761100','##xx'
select * from ct_cuenta


select distinct a.empresacodigo,A.Fechaplanilla, A.numide, A.PlanillaAbono, * from dbo.##tmp_conta##xx a order by fechaplanilla

*/

                  
CREATE PROC [cp_GeneraTempAsientoPagarenLinea2_pro]		/*EN USO*/
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
SET @tmpsql = '	SELECT numide=e.PlanillaAbono, e.*,ImporteCargo=case when tdocumentotipo=''C'' then ISNULL(e.cargo,0) else ISNULL(e.abono,0) end,
ImporteAbono= case when tdocumentotipo=''C'' then ISNULL(e.abono,0) else ISNULL(e.cargo,0) end ,
pedidotiporefe='' '',pedidonrorefe='' '',pedidofechasunat=e.FecEmisionCargo,e.tplanillacodigo as TipoPlanilla,bancocodigo='' ''
into [##tmp_contazz'+@compu+'] FROM 
	( select tipo=2 ,a.empresacodigo, tplanillacodigo,PlanillaAbono=a.abononumplanilla,tdocumentotipo,descripciontipoplanilla=tplanilladescripcion,
	  CodCliente=abonocancli,Doccargo=a.documentoabono, NumDoccargo=a.abononumdoc,FecEmisionCargo=isnull(b.cargoapefecemi,abonocanfecan),
	  FecCanAbono=isnull(cargoapefecemi,abonocanfecan) ,fechaplanilla=abonocanfecpla,a.abonocanfecan,MonedaAbono=a.abonocanmoncan,tcemision=isnull(tipocambioventa ,1),
	  cargo=00000000.00,abono=case when a.abonocanmoncan=''01'' then a.abonocanimcan else a.abonocanimcan * isnull(tipocambioventa ,1) end,b.cargoaperefere,
	  abonocanfecpla,tipocambioventa , importe=a.abonocanimcan,cuentacargo=case when a.abonocanmoncan=''01'' then tdocumentocuentasoles else tdocumentocuentadolares end
      from [' + @base+ '].dbo.vt_abono a 
      inner join [' + @base+ '].dbo.cc_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
      inner join [' + @base+ '].dbo.vt_cliente vt on A.abonocancli=vt.clientecodigo
      inner join [' + @base+ '].dbo.cc_tipodocumento td on A.documentoabono=td.tdocumentocodigo
      left join  [' + @base+ '].dbo.vt_cargo b on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
      left join [' +@basecontab+ '].dbo.ct_tipocambio M on b.cargoapefecemi=M.tipocambiofecha	
      where a.empresacodigo='''+@empresa+''' AND month(a.abonocanfecpla)='''+@mes+''' and year(a.abonocanfecpla)='''+@ano+'''  
            and isnull(abonocanflreg,0)<>1 AND ( tplanillacompensa = ''1''  ) and a.abononumplanilla like ('''+@numero+''' )
      union all
      select tipo=1 , a.empresacodigo,tplanillacodigo,PlanillaAbono=a.abononumplanilla,tdocumentotipo,descripciontipoplanilla=tplanilladescripcion,
      CodCliente=abonocancli,Doccargo=a.documentoabono, NumDoccargo=a.abononumdoc,FecEmisionCargo=isnull(b.cargoapefecemi,abonocanfecan),
      FecCanAbono=isnull(cargoapefecemi,abonocanfecan) ,abonocanfecan=abonocanfecpla, abonocanfecan,MonedaAbono=a.abonocanmoncan,tcemision=isnull(tipocambioventa,1),
      cargo=case when a.abonocanmoncan=''01'' then a.abonocanimcan else a.abonocanimcan * isnull(tipocambioventa ,1) end ,
      abono=00000000.00, b.cargoaperefere,abonocanfecpla,tipocambioventa , importe=a.abonocanimcan,cuentacargo=case when a.abonocanmoncan=''01'' then tdocumentocuentasoles else tdocumentocuentadolares end
      from [' + @base+ '].dbo.cp_abono a 
      inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
      inner join [' + @base+ '].dbo.cp_proveedor cp on A.abonocancli=cp.clientecodigo
      inner join [' + @base+ '].dbo.cp_tipodocumento td on A.documentoabono=td.tdocumentocodigo
      left join  [' + @base+ '].dbo.cp_cargo b on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
      inner join [' +@basecontab+ '].dbo.ct_tipocambio M on b.cargoapefecemi=M.tipocambiofecha	
      where a.empresacodigo='''+@empresa+''' AND month(a.abonocanfecpla)='''+@mes+''' and year(a.abonocanfecpla)='''+@ano+'''
            and isnull(abonocanflreg,0)<>1 AND ( d.tplanillacompensa= ''1'' ) and a.abononumplanilla like ('''+@numero+''' )
  ) e 
  inner JOIN ['+@base+'].dbo.gr_moneda d ON e.MonedaAbono = d.monedacodigo ORDER BY e.tplanillacodigo,e.PlanillaAbono,e.tipo  '

execute(@tmpsql)

declare @cadsql1 	varchar(4000)
declare @cadsql2 	varchar(4000)
declare @cadsql3 	varchar(4000)
set @cadsql1= 'SELECT zz.empresacodigo,zz.numide,ZZ.CodCliente,DocCargo, NumDocCargo, ZZ.PlanillaAbono,
Item=''1'',cuenta=ZZ.cuentacargo,ZZ.Importe,ZZ.FecEmisionCargo,ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo= CAST(ROUND((ISNULL(ZZ.Importecargo,0)),2) AS NUMERIC(15,2)),
	abono= CAST(ROUND((ISNULL(ZZ.Importeabono,0)),2) AS NUMERIC(15,2)),
	ZZ.tcemision,ZZ.monedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),zz.fechaplanilla,zz.descripciontipoplanilla,operacioncodigo=''04''
	FROM  [##tmp_contazz'+@compu+'] as ZZ where tipo=''1'' '
set @cadsql2= ' union all 
SELECT zz.empresacodigo,zz.numide,ZZ.CodCliente,DocCargo, NumDocCargo, ZZ.PlanillaAbono,
Item=''2'',cuenta=ZZ.cuentacargo,zz.importe,ZZ.FecEmisionCargo,ZZ.FecCanAbono,centrocostocodigo=space(10),
	cargo= CAST(ROUND((ISNULL(ZZ.Importecargo,0)),2) AS NUMERIC(15,2)),
	abono= CAST(ROUND((ISNULL(ZZ.Importeabono,0)),2) AS NUMERIC(15,2)),
	ZZ.tcemision,ZZ.monedaAbono,ZZ.pedidotiporefe,ZZ.pedidonrorefe,
    pedidofechasunat=isnull(ZZ.pedidofechasunat,ZZ.FecEmisionCargo),zz.fechaplanilla,zz.descripciontipoplanilla,operacioncodigo=''01''
	FROM  [##tmp_contazz'+@compu+'] as ZZ where tipo=''2''  '
set @cadsql3= ' union all 
        SELECT zz.empresacodigo,zz.numide,'' '','' '','' '',ZZ.PlanillaAbono,Item=''3'',
  	cuenta=	case when  sum((ISNULL(ZZ.importecargo,0)))-sum((ISNULL(ZZ.ImporteAbono,0)))>0 then ''' +@ctadifgan+ '''
			     else '''+@ctadifper+ ''' end,
	Importe=0,ZZ.Fechaplanilla,ZZ.Fechaplanilla,centrocostocodigo=''40100'',
	cargo=case when  round(sum(ISNULL(ZZ.importecargo,0)),2)-round(sum(ISNULL(ZZ.ImporteAbono,0)),2)>=0 then 0
			     else abs (sum(round(ISNULL(ZZ.importecargo,0),2))-sum(round(ISNULL(ZZ.ImporteAbono,0),2))) 
               end ,
	abonoo=case when  round(sum((ISNULL(ZZ.importecargo,0)))-sum((ISNULL(ZZ.ImporteAbono,0))),2)>=0 then 
			              abs (sum(round(ISNULL(ZZ.importecargo,0),2))-sum(round(ISNULL(ZZ.ImporteAbono,0),2)) ) 
                else 0 end ,
	1,''01'','' '','' '',zz.fechaplanilla,zz.fechaplanilla,'' '',operacioncodigo=''04''
	FROM [##tmp_contazz'+@compu+'] as ZZ
    group by zz.empresacodigo,zz.numide,ZZ.PlanillaAbono,zz.fechaplanilla
    having round(sum(ISNULL(ZZ.importecargo,0)),2)-round(sum(ISNULL(ZZ.ImporteAbono,0)),2)<>0	
'
execute ('select * into [##tmp_conta'+@compu+'] 
from (' +@cadsql1+@cadsql2+@cadsql3 + ') AS YY' )
GO
