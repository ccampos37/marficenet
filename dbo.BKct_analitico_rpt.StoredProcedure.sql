SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [BKct_analitico_rpt]
(	@base 			varchar(50),
	@anno 			varchar(4),
	@cabcomprobmesini	varchar(2),
	@cabcomprobmesfin	varchar(2),
	@cuentacodigo 		varchar(20),
	@asientocodigo 		varchar(3),
	@subasientocodigo 	varchar(3),
	@analiticocodigo 	varchar(14),
	@tipoanaliticocodigo 	varchar(3),
	@ctacteanaliticocancel	varchar(1),
	@op   			char(1)
)
as
declare @sqlcad as varchar(5000)
if @op='1'
BEGIN
set @sqlcad='SELECT D.tipoanaliticocodigo, 
	B.tipoanaliticodescripcion,    
	A.analiticocodigo,
	A.monedacodigo, 
	D.entidadcodigo, 
	D.entidadruc,
	D.entidadrazonsocial, 
	A.cuentacodigo, 
	C.cuentadescripcion, 
	A.cabcomprobnumero, 
	A.detcomprobitem, 
	A.ctacteanaliticofechaconta, 
	A.documentocodigo, 
	A.ctacteanaliticonumdocumento, 
	A.ctacteanaliticofechadoc, 
	A.ctacteanaliticoglosa, 
	A.ctacteanaliticodebe, 
	A.ctacteanaliticohaber, 
	A.ctacteanaliticoussdebe, 
	A.ctacteanaliticousshaber, 
	A.ctacteanaliticocancel,
	A.operacioncodigo
    FROM 
		[' +@base+ '].dbo.[ct_ctacteanalitico' +@anno+ '] A,
		[' +@base+ '].dbo.ct_tipoanalitico B, 
    	[' +@base+ '].dbo.ct_cuenta C,
		[' +@base+ '].dbo.v_analiticoentidad D  
    WHERE
	A.cuentacodigo = C.cuentacodigo AND
	A.analiticocodigo=D.analiticocodigo AND
 	B.tipoanaliticocodigo = D.tipoanaliticocodigo AND 
    A.cabcomprobmes BETWEEN ' +@cabcomprobmesini+ ' AND ' +@cabcomprobmesfin+ ' AND
	A.cuentacodigo LIKE ''' +@cuentacodigo+ ''' AND
	A.asientocodigo LIKE ''' +@asientocodigo+ ''' AND
	A.subasientocodigo LIKE ''' +@subasientocodigo+ ''' AND
    A.analiticocodigo LIKE ''' +@analiticocodigo+ ''' AND
	B.tipoanaliticocodigo LIKE ''' +@tipoanaliticocodigo+ ''' AND
	A.ctacteanaliticocancel='  +@ctacteanaliticocancel + ''
END
if @op='2'
BEGIN
  print 'Se hizo por primera vez'
  print 'Se hizo por segunda vez'
END
--print (@sqlcad)
exec (@sqlcad)
--execute ct_analitico_rpt 'contaprueba','XXXX','1','8','421%','%%','%%','%%','001',1,'1'
GO
