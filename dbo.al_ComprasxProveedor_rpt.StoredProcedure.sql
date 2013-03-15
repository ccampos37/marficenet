SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Objeto:  procedimiento almacenado dbo.al_ComprasxProveedor_rpt    fecha de la secuencia de comandos: 30/01/2007 11:45:21 a.m. *****
drop proc al_ComprasxProveedor_rpt

EXEC al_ComprasxProveedor_rpt 'newgreen','%%','%%','19/03/2006','19/03/2008','%%','##JCK_compras','01'

*/


CREATE          procedure [al_ComprasxProveedor_rpt]
@base varchar(50),
@proveedor1 varchar(11),
@proveedor2 varchar(11),
@fechaini varchar(10),
@fechafin varchar(10),
@moneda varchar(2),
@filtro varchar(100),
@almacen varchar(2)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT b.adescri,mmaa=str(year(c.cafecdoc),4)+'' ''+DATENAME(month, c.cafecdoc),
entidad=d.dequipo+'' ''+g.entidadrazonsocial,C.CAALMA,c.cacodmon, C.CATD,C.CATIPMOV,C.CANUMDOC, C.CAFECDOC, 
C.CACODMOV,CARFNDOC=rtrim(e.tdo_descri)+ ''  ''+c.CARFNDOC ,CACODPRO=a.clienteruc, C.CACODMON, C.CATIPCAM, 
CANOMPRO=a.clienterazonsocial, D.DECODIGO, D.DEDESCRI, D.DEUNIDAD, D.DECANTID, 
deprecio= case when depRECIO > 0 then deprecio 
            else case when catipmov=''I'' then 0 else h.stkprepro end
          end ,
d.depreuni,
a.clienterazonsocial,f.monedadescripcion
FROM '+@BASE+'.DBO.MOValmCAB C INNER JOIN '+@BASE+'.DBO.MOVALMDET D 
      ON C.CAALMA=D.DEALMA AND C.CATD=D.DETD AND C.CANUMDOC=D.DENUMDOC 
     left join '+@BASE+'.dbo.cp_proveedor a on c.cacodpro=a.clientecodigo
     inner join '+@BASE+'.dbo.maeart b on d.decodigo=b.acodigo
     left join '+@BASE+'.dbo.tipo_docu e on c.CARFTDOC=e.tdo_tipdoc
     left join '+@BASE+'.dbo.gr_moneda f on c.CAcodmon=f.monedacodigo
     left join '+@BASE+'.dbo.ct_entidad g on d.dequipo=g.entidadcodigo
     inner join '+@BASE+'.dbo.stkart h on d.dealma+d.decodigo=h.stalma+h.stcodigo
WHERE (C.CATD= ''NI'' OR C.CATD=''NS'') and 
     isnull(c.casitgui,'''')<>''A'' and 
     isnull(C.CACODPRO,'''') like ('''+@proveedor1+''') AND 
     C.caalma like ('''+@almacen+''') AND 
     isnull(d.dequipo,'''') like ('''+@proveedor2+''')  AND
     C.CAFECDOC>='''+@fechaini+''' AND C.CAFECDOC<='''+@fechafin+'''
     AND c.catipmov+c.cacodmov in ( select transa from '+@filtro+') ORDER BY 1,2 '

execute(@NCADENA)
GO
