SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE                   procedure [al_RelacionRequerimientos_rpt]
@base varchar(50),
@solicitante varchar(10),
@orden varchar(10),
@estado varchar(1),
@tipo integer,
@fechaini varchar(10),
@fechafin varchar(10),
@tabla varchar(50)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'
SELECT OC_CRAZSOC,OC_DFECENT,estadoocdescripcion , tipoordendescripcion,
e.solicitantecodigo,e.solicitantenombre,
f.centrocostodescripcion,
g.fam_nombre,
h.entidadrazonsocial,
descripcion = case rtrim(d.OC_cCodigo) when ''00'' then
                    rtrim(d.OC_CCOMEN1) 
               else rtrim(d.OC_CDESREF)+'' -- ''+rtrim(d.OC_CCOMEN1) end,
d.* 
into ['+@base+'].dbo.'+@tabla+' 
 From ['+@base+'].dbo.co_cabordcompra a
    inner join ['+@base+'].dbo.co_detordcompra d
       on a.tipoordencodigo=d.tipoordencodigo and a.OC_CNUMORD=d.OC_CNUMORD
    INNER JOIN ['+@base+'].dbo.co_estadorequerimiento b
       on a.estadooccodigo= b.estadooccodigo
    INNER join ['+@base+'].dbo.co_tipodeorden c 
       on a.tipoordencodigo=c.tipoordencodigo
    inner join ['+@base+'].dbo.co_solicitantes e
       on a.oc_csolict=e.solicitantecodigo
    left join ['+@base+'].dbo.ct_centrocosto f
       on d.centrocostocodigo=f.centrocostocodigo
    left join ['+@base+'].dbo.familia g
       on d.fam_codigo=g.fam_codigo
    LEFT JOIN ['+@base+'].dbo.ct_entidad h
       on d.entidadcodigo=h.entidadcodigo
 Where flagrequerimientos=1  AND OC_CSOLICT LIKE ('''+@SOLICITANTE+''')
       and a.TIPOORDENCODIGO like (''' +@orden+''')  
       and ISNULL(d.oc_estadoorden,0)<>1 
       and b.estadoocatendido<>1
       and b.nivelrequerimientocodigo like ('''+@estado+''')'
If @tipo= 1 Set @ncadena=@ncadena+' and  a.oc_dfecdoc between ''' +@fechaini+ ''' 
               and '''+@fechafin+''''
set @ncadena=@ncadena+' ORDER BY 1,2 '
execute(@NCADENA)
--EXEC al_RelacionRequerimientos_rpt 'acuaplayacasma','%%','%%','%%',1,'01/11/2006','30/11/2006','##xx'
GO
