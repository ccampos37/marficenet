SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [al_RelacionRequerimientosResumen_rpt]
@base varchar(50),
@solicitante varchar(50),
@orden varchar(10),
@estado varchar(2),
@tipo integer,
@fechaini varchar(10),
@fechafin varchar(10)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)

Set @ncadena=N'select z.tipoordencodigo,z.fam_nombre,z.oc_ccodigo,z.descripcion,z.oc_cunidad,total=sum(z.oc_nsaldo)
	 from
	(
	SELECT a.tipoordencodigo,a.OC_CNUMORD,oc_citem,a.OC_DFECDOC,a.OC_CCODPRO,
	OC_CRAZSOC,OC_DFECENT,estadoocdescripcion , tipoordendescripcion,
	fam_nombre,d.oc_ccodigo,oc_cunidad,
	descripcion = case rtrim(d.OC_cCodigo) when ''00'' then
	                    rtrim(d.OC_CCOMEN1) 
	               else rtrim(d.OC_CDESREF)+'' -- ''+rtrim(d.OC_CCOMEN1) end,
	d.oc_nsaldo 
	From ['+@base+'].dbo.co_cabordcompra a
	    INNER JOIN ['+@base+'].dbo.co_estadorequerimiento b
	       on a.estadooccodigo= b.estadooccodigo
	    INNER join ['+@base+'].dbo.co_tipodeorden c 
	       on a.tipoordencodigo=c.tipoordencodigo
	    inner join ['+@base+'].dbo.co_detordcompra d
	       on a.tipoordencodigo=d.tipoordencodigo and a.OC_CNUMORD=d.OC_CNUMORD
	    left join ['+@base+'].dbo.familia g
	       on d.fam_codigo=g.fam_codigo
	 Where flagrequerimientos=1  AND OC_CSOLICT LIKE ('''+@SOLICITANTE+''')
	       and a.TIPOORDENCODIGO like (''' +@orden+''')  
	       AND isnull(d.oc_estadoorden,0)<>1
	       and b.estadoocatendido<>1'

/* ESTO IBA AL ULTIMO DE NCADENA
and b.nivelrequerimientocodigo like ('''+@estado+''')
*/

If @tipo= 1 Set @ncadena=@ncadena+' and  a.oc_dfecdoc between ''' +@fechaini+ ''' and '''+@fechafin+''''
set @ncadena=@ncadena+') as z group by z.tipoordencodigo,z.descripcion,z.fam_nombre,
		       z.oc_ccodigo,z.oc_cunidad ORDER BY 1,2,3,4 '


exec(@NCADENA)
-- EXEC al_RelacionRequerimientosResumen_rpt 'ziyaz','%%','%%','%%',1,'01/11/2008','30/11/2008'
GO
