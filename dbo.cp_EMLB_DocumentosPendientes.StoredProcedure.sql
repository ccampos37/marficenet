SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*Documentos Vencidos y por Vencer*/
CREATE        proc [cp_EMLB_DocumentosPendientes](
@base varchar(50),
@compu varchar(20),
@fecha varchar(10),
@RangoVencer varchar(50),
@RangoVencido varchar(50),
@codcliente varchar(20),
@codmoneda varchar(2),
@basecontab varchar(50),
@coddocumento varchar(2)
)
as
set nocount on
DECLARE @sqlcad varchar(3500)
DECLARE @totdiaven as integer
DECLARE @totdiapve as integer
declare @valortope as integer
set @valortope=dbo.fn_ubicarango('' +@RangoVencer+ '',5)
IF EXISTS (SELECT NAME FROM tempdb.dbo.sysobjects WHERE NAME='##tmp_documpendiente'+@compu)
exec('DROP TABLE ##tmp_documpendiente' +@compu )
set @sqlcad='
	SELECT A.clientecodigo, A.documentocargo, A.cargonumdoc,A.cargoapefecemi,
			A.cargoapefecvct,A.monedacodigo,cargoapeimpape=isnull(A.cargoapeimpape,0),
			cargoapeimppag=isnull(A.cargoapeimppag,0),
			cargopagadoux=isnull(A.cargoapeimppag,0),
			A.cargoapeflgcan,A.cargoapecarabo,
			tipocambio=isnull((select isnull(tipocambioventa,0) from [' +@basecontab+ '].dbo.ct_tipocambio where tipocambiofecha=A.cargoapefecemi),0),
 			E.tdocumentodescripcion,
			I.clienteruc,I.clienterazonsocial,
			H.monedasimbolo,
			estadoreg=case when floor(cast(cargoapefecvct-''' +@fecha+ ''' as real))>=0
				then ''POR VENCER''
				else ''VENCIDO''
			end,
			numdias=floor(cast(cargoapefecvct-''' +@fecha+ ''' as real)),
			numcolumna=dbo.fn_ubicacolumna(''' +@RangoVencer+ ''',abs(floor(cast(cargoapefecvct-''' +@fecha+ ''' as real)))),
			DocVen1=cast(0 as numeric(25,9)),DocVen2=cast(0 as numeric(25,9)),DocVen3=cast(0 as numeric(25,9)),DocVen4=cast(0 as numeric(25,9)),DocVen5=cast(0 as numeric(25,9)),
			DocPVe1=cast(0 as numeric(25,9)),DocPVe2=cast(0 as numeric(25,9)),DocPVe3=cast(0 as numeric(25,9)),DocPVe4=cast(0 as numeric(25,9)),DocPVe5=cast(0 as numeric(25,9))
   INTO 	##tmp_documpendiente' +@compu+ '
	FROM 	[' +@base+ '].dbo.cp_cargo A,
 			[' +@base+ '].dbo.cp_tipodocumento E,
			[' +@base+ '].dbo.gr_moneda H,
			[' +@base+ '].dbo.cp_proveedor I
	WHERE A.documentocargo=E.tdocumentocodigo AND A.documentocargo LIKE ''' +@coddocumento+  ''' AND
			A.monedacodigo=H.monedacodigo AND
        	A.clientecodigo=I.clientecodigo AND
			A.clientecodigo like ''' +@codcliente+ ''' AND 
			A.cargoapeflgcan=0  AND
			A.cargoapeflgreg IS NULL AND
			cast(abs(floor(cast(A.cargoapefecvct-''' +@fecha+ ''' as real))) as integer)<=' +cast(@valortope as varchar(2))+  ' 
	ORDER BY A.clientecodigo, A.documentocargo,A.cargonumdoc'
--A.monedacodigo like ''' +@codmoneda+ '''	AND
EXEC(@sqlcad)
Declare @cadsql varchar(3000)
Declare @i as integer
Declare @cadena varchar(400)
	set	@cadena='=case when monedacodigo=''01'' then
			case when ''' +@codmoneda+ '''=''01''
				then (cargoapeimpape-cargoapeimppag)
				else case when tipocambio<>0 then (cargoapeimpape-cargoapeimppag)/tipocambio else 0 end
		 	end
		else 
		 	case when ''' +@codmoneda + '''=''02''
				then (cargoapeimpape-cargoapeimppag)
				else (cargoapeimpape-cargoapeimppag)*tipocambio
			end
  	end'
set @i=1
while @i<=5
begin
	set @cadsql='update ##tmp_documpendiente' +@compu+ ' set DocVen' +cast(@i as varchar(2))+ @cadena+'
	where numcolumna=' +cast(@i as varchar(2))+ ' AND estadoreg=''VENCIDO'''
	exec(@cadsql)
	set @i=@i+1
end
set @i=1
while @i<=5
begin
	set @cadsql='update ##tmp_documpendiente' +@compu+ ' set DocPVe' +cast(@i as varchar(2))+ @cadena+'
	where numcolumna=' +cast(@i as varchar(2))+ ' AND estadoreg=''POR VENCER'''
	exec(@cadsql)
	set @i=@i+1
end
exec('SELECT * FROM ##tmp_documpendiente' +@compu)
set nocount off
--select * from ##tmp_saldodocdesarrollo3 order by abonocancli,documentoabono,abononumdoc
--exec cp_EMLB_DocumentosPendientes 'ventas_prueba','DESARR','15/12/2002','7*15*30*45*60*','7*15*30*45*60*','%','02','contaprueba','%'
GO
