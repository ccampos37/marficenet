SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [cp_PlanillaCompensaciones_rpt] 'planta_casma','03','31/12/2011','31/12/2011','%%'
 

*/


CREATE PROC [cp_PlanillaCompensaciones_rpt] 		/*EN USO*/

@base varchar(50),
@empresa varchar(2)='01' ,
@fecdesde varchar(10)='01/01/2008',
@fechasta varchar(10)='31/01/2008',
@codcliente varchar(20)
AS
DECLARE @sensql varchar (4000)
Declare @cadsql varchar(3000)
set @cadsql='' 
set @sensql=' Select *,monedasimbolo, c.empresadescripcion from 
             ( select tipo=2 ,a.empresacodigo, clienterazonsocial,tdocumentodescripcion,tplanillacodigo,a.abononumplanilla,tplanilladescripcion,abonocancli,
                        a.documentoabono, a.abononumdoc,b.cargoapefecemi ,monedacodigo=abonocanmoneda,ABONOCANFECPLA,
                        b.cargoapefecvct,a.abonocanmoncan , a.abonocanimcan, b.cargoaperefere  from [' + @base+ '].dbo.cp_abono a 
              inner join [' + @base+ '].dbo.cp_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
              left join  [' + @base+ '].dbo.cp_cargo b 
                  on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
              LEFT join 	[' + @base+ '].dbo.cp_proveedor e on a.abonocancli=e.clientecodigo
              LEFT join 	[' + @base+ '].dbo.cp_tipodocumento t on a.documentoabono=t.tdocumentocodigo 
              where a.empresacodigo='''+@empresa +'''and abonocanfecpla BETWEEN '''+ @fecdesde+''' AND '''+@fechasta+''' and isnull(abonocanflreg,0)<>1 
                    and d.tplanillacompensa=1
            union all
            select 	tipo=1 , a.empresacodigo, clienterazonsocial,tdocumentodescripcion,tplanillacodigo,a.abononumplanilla,tplanilladescripcion,abonocancli,
                    a.documentoabono, a.abononumdoc,b.cargoapefecemi ,monedacodigo=abonocanmoneda,ABONOCANFECPLA,
                    b.cargoapefecvct,a.abonocanmoncan , a.abonocanimcan, b.cargoaperefere  from [' + @base+ '].dbo.vt_abono a 
           left join [' + @base+ '].dbo.cc_tipoplanilla d on A.abonotipoplanilla=d.tplanillacodigo
           left join  [' + @base+ '].dbo.vt_cargo b 
                on a.empresacodigo+a.abonocancli+a.documentoabono+a.abononumdoc=b.empresacodigo+b.clientecodigo+documentocargo+cargonumdoc
           left join 	[' + @base+ '].dbo.vt_cliente e on a.abonocancli=e.clientecodigo
           left join 	[' + @base+ '].dbo.cc_tipodocumento t on a.documentoabono=t.tdocumentocodigo 
           where a.empresacodigo='''+@empresa +'''and  abonocanfecpla BETWEEN '''+ @fecdesde+''' AND '''+@fechasta+''' and isnull(abonocanflreg,0)<>1
           and d.tplanillacompensa=1
         ) z
     inner join [' + @base+ '].dbo.co_multiempresas c on z.empresacodigo=c.empresacodigo  
     LEFT join 	[' + @base+ '].dbo.gr_moneda g on z.monedacodigo=g.monedacodigo 
     '

execute (@sensql)
GO
