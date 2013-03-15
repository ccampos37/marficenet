SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute cp_PlanillaCanjeRenovacion 'ziyaz','01/01/2010','30/09/2010','%%',1,'000705','02'
 

*/


CREATE   PROC [cp_PlanillaCanjeRenovacion] 		/*EN USO*/
@base varchar(50),
@fecdesde varchar(10)='01/01/2008',
@fechasta varchar(10)='31/01/2008',
@codcliente varchar(20),
@opcion integer=1,  /*1=Canje 2=Renovación*/
@numplanilla varchar(6)='%%',
@empresa varchar(2)='01'
AS
DECLARE @sensql varchar (4000)
Declare @cadsql varchar(3000)
set @cadsql='' 
if @opcion=1
	begin
		set @cadsql=' and  d.tplanillacanjes=1 '
	end
else
	begin
		set @cadsql=' and  d.tplanillarenovar=1 '
	end
set @sensql=' select tipocanje=(case when  tipo=1 then '' DOC. A CANJEAR '' else '' DOC. CANJEADOS '' end ) ,
        nn=tplanillacodigo+abononumplanilla,	z.* , e.clienterazonsocial,tdocumentodescripcion,g.monedasimbolo ,
       importe = (case when  tdocumentotipo=''C'' then cargoapeimpape else cargoapeimpape*-1 end ) from
      ( select 	tipo=2 , tplanillacodigo,abononumplanilla,tplanilladescripcion,clientecodigo,documentocargo, cargonumdoc,cargoapefecemi,
                cargoapefecvct,monedacodigo,cargoapeimpape,cargoaperefere from [' + @base+ '].dbo.cp_cargo a 
           inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
           where A.cargoapefecemi BETWEEN '''+ @fecdesde+''' AND '''+@fechasta+''' and isnull(cargoapeflgreg,0)<>1 '+ +@cadsql+ '
                and a.abononumplanilla like ('''+@numplanilla+''')
        union all
            select 	tipo=1 , tplanillacodigo,a.abononumplanilla,tplanilladescripcion,abonocancli,a.documentoabono, a.abononumdoc,b.cargoapefecemi ,
                    b.cargoapefecvct,a.abonocanmoncan , a.abonocanimcan, b.cargoaperefere  from [' + @base+ '].dbo.cp_abono a 
           inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
           left join  [' + @base+ '].dbo.cp_cargo b 
                on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
           where abonocanfecpla BETWEEN '''+ @fecdesde+''' AND '''+@fechasta+''' and isnull(abonocanflreg,0)<>1 '+ +@cadsql+ '
                and a.abononumplanilla like ('''+@numplanilla+''' )
       ) z
     inner join 	[' + @base+ '].dbo.cp_proveedor e on z.clientecodigo=e.clientecodigo
     inner join 	[' + @base+ '].dbo.gr_moneda g on z.monedacodigo=g.monedacodigo 
     inner join 	[' + @base+ '].dbo.cp_tipodocumento t on z.documentocargo=t.tdocumentocodigo '

execute (@sensql)
GO
