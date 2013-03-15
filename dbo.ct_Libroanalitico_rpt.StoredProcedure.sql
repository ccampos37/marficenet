SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec ct_libroanalitico_rpt 'planta_casma','03','2011','10','2','FORmato 03.11'
select * from ##ct_analitico
UPDATE CT_DETCOMPROB2010
SET detcomprobnumdocumento =RTRIM(detcomprobnumdocumento)


*/

CREATE proc [ct_Libroanalitico_rpt]

(	@base 			varchar(50),
    @empresa		varchar(2),	 
    @anno 			varchar(4),
	@cabcomprobmesfin	varchar(2),
	@tipo   			char(1),  /** 2: Pendientes //  1:Cancelados  // 3:Todos  **/
    @formato varchar(20)


)
as
declare @sqlcad as varchar(5000)
declare @cad1 varchar(100)
declare @cad2 varchar(100)
If Exists(Select name from tempdb.dbo.sysobjects where name ='##ct_analitico'+@empresa)
	Exec('Drop Table ##ct_analitico'+@empresa)

set @sqlcad='declare @cad1 varchar(100)
declare @cad2 varchar(100)
Declare @descripcion1 varchar(50)
Set @cad1=(select formatodescripcion1 from '+@base+'.dbo.ct_formatos where formatocodigo='''+@FORMATO+''' )
Set @cad2=(select formatodescripcion2 from '+@base+'.dbo.ct_formatos where formatocodigo='''+@FORMATO+''' ) 
Set @descripcion1=(select descripcion1 from '+@base+'.dbo.ct_formatos where formatocodigo='''+@FORMATO+''' ) '

set @sqlcad=@sqlcad+' SELECT DISTINCT
    formatodescripcion1=@cad1,formatodescripcion2=@cad2,formato='''+@formato+''',descripcion=@descripcion1,
	A.analiticocodigo,A.monedacodigo,D.entidadcodigo, D.entidadruc,D.entidadrazonsocial,
	A.cuentacodigo,C.cuentadescripcion, 
	A.cabcomprobnumero,A.detcomprobitem,A.ctacteanaliticofechaconta,
	ctacteanaliticonumdocumento=A.documentocodigo+''  ''+dbo.fn_formatoNumDoc(A.ctacteanaliticonumdocumento), 
    A.ctacteanaliticofechadoc, 
	A.ctacteanaliticoglosa, 
	A.ctacteanaliticodebe, 
	A.ctacteanaliticohaber,
	ctacteanaliticoussdebe=case when c.tipoajuste=''01'' then A.ctacteanaliticoussdebe else 0 end, 
	ctacteanaliticousshaber=case when c.tipoajuste=''01'' then A.ctacteanaliticousshaber else 0 end, 
	A.ctacteanaliticocancel,
	A.operacioncodigo,D.tipoanaliticocodigo,d.identidadcodigo,d.identidaddescripcion , C.TIPOAJUSTE , 
	Descripcionmes=dbo.fn_DescripcionMes ( '+@cabcomprobmesfin+'), aaaa='''+@anno+''' '
set @sqlcad = @sqlcad + ' FROM 
	[' +@base+ '].dbo.[ct_ctacteanalitico' +@anno+ '] A
	Inner join [' +@base+ '].dbo.ct_cuenta C On a.empresacodigo=c.empresacodigo and 
	A.cuentacodigo = C.cuentacodigo
	Inner Join [' +@base+ '].dbo.v_analiticoentidad D On A.analiticocodigo= D.analiticocodigo '

	if @tipo='2'  -- pendientes
	BEGIN	
		set @sqlcad=@sqlcad + '  Inner Join  ( Select  aa.empresacodigo, AA.CuentaCodigo,AA.analiticocodigo,AA.DocumentoCodigo,AA.ctacteanaliticonumdocumento,
		saldoS= round(sum(AA.ctacteanaliticodebe),2) - round(sum(AA.ctacteanaliticohaber),2),
		saldoD= round(sum(AA.ctacteanaliticoussdebe),2) - round(sum(AA.ctacteanaliticousshaber) ,2)
		From [' +@Base+ '].dbo.ct_ctacteanalitico' +@Anno+ ' AA 
			Where Aa.analiticocodigo<>''00'' and Aa.cabcomprobmes<='+@cabcomprobmesfin+' and aa.empresacodigo='''+@empresa+'''
			Group by aa.empresacodigo,Aa.CuentaCodigo,Aa.analiticocodigo,  
			Aa.documentocodigo,Aa.ctacteanaliticonumdocumento
			HAVING  round(sum(AA.ctacteanaliticodebe),2) - round(sum(AA.ctacteanaliticohaber),2) <> 0 ) zz 
			On a.empresacodigo+a.cuentacodigo+a.analiticocodigo+a.documentocodigo+a.ctacteanaliticonumdocumento=
			   zz.empresacodigo+zz.cuentacodigo+zz.analiticocodigo+zz.documentocodigo+zz.ctacteanaliticonumdocumento  '
	END
	if @tipo='1' -- cancelados
	BEGIN	
		set @sqlcad=@sqlcad +'  Inner Join  ( Select  aa.empresacodigo, AA.CuentaCodigo,AA.analiticocodigo,AA.DocumentoCodigo,AA.ctacteanaliticonumdocumento,
			saldoS= round(sum(AA.ctacteanaliticodebe),2) - round(sum(AA.ctacteanaliticohaber),2),
			saldoD= round(sum(AA.ctacteanaliticoussdebe),2) - round(sum(AA.ctacteanaliticousshaber) ,2)
			From [' +@Base+ '].dbo.ct_ctacteanalitico' +@Anno+ ' AA 
			Where Aa.analiticocodigo<>''00'' and Aa.cabcomprobmes<='+@cabcomprobmesfin+' and aa.empresacodigo='''+@empresa+'''
			Group by aa.empresacodigo,Aa.CuentaCodigo,Aa.analiticocodigo,	   
			Aa.documentocodigo,Aa.ctacteanaliticonumdocumento  ) zz On a.empresacodigo=zz.empresacodigo And a.cuentacodigo=zz.cuentacodigo 
			And a.analiticocodigo=zz.analiticocodigo And a.documentocodigo=zz.documentocodigo And a.ctacteanaliticonumdocumento=zz.ctacteanaliticonumdocumento 
			And ((zz.saldoS =0 and a.monedacodigo=''01'') Or ( zz.saldoD=0 and a.monedacodigo=''02'')) '
	END

set @sqlcad = @sqlcad + ' WHERE
	a.empresacodigo='''+@empresa+''' and 
   	A.cabcomprobmes <=' +@cabcomprobmesfin+ ' AND
    c.cuentaestadoanalitico=1 and 
    a.CUENTACODIGO like (select formatocuerntacomodin from '+@BASE+'.dbo.ct_formatos where formatocodigo='''+@FORMATO+''') '
execute(@sqlcad)
--print(@sqlcad)
GO
