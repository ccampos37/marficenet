SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
---drop   procedure al_impresionrequerimientos_rpt
CREATE   procedure [al_impresionrequerimientos_rpt]
@base varchar(50),
@tipo varchar(10),
@numero varchar(11)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT A.TIPOORDENcodigo,h.tipoordendescripcion,a.OC_CNUMORD,
  i.aunidad,a.OC_DFECDOC,a.OC_CCODPRO,OC_CRAZSOC=d.clienterazonsocial,
  OC_CDIRPRO=d.clientedireccion,d.clientepropietario,
  b.oc_nfactor,b.oc_cuniref,OC_CENTREG,OC_CCOTIZA,e.centrocostodescripcion,
  OC_DFECENT,OC_COBSERV,OC_CITEM,OC_CCODIGO,oc_ccodref,ord_fabnum,
  b.OC_CCOMEN1,b.oc_ccomen2,
  Oc_cdesref = case rtrim(b.OC_cCodigo) when ''00'' then
                    '''' 
               else rtrim(OC_CDESREF) end,
  OC_NCANTID as d_cant,oc_nsaldo ,OC_COMENTA, f.entidadrazonsocial,g.solicitantenombre
  FROM ['+@base+'].dbo.co_cabordcompra a 
       INNER JOIN ['+@base+'].dbo.co_detordcompra b 
              ON a.tipoordencodigo=b.tipoordencodigo and a.oc_cnumord = b.oc_cnumord
       left join ['+@base+'].dbo.cp_proveedor d
            on a.oc_ccodpro=d.clientecodigo
       left join ['+@base+'].dbo.ct_centrocosto e
            on b.centrocostocodigo=e.centrocostocodigo
       left join ['+@base+'].dbo.ct_entidad f
            on b.entidadcodigo=f.entidadcodigo
       inner join ['+@base+'].dbo.co_solicitantes g
            on a.oc_csolict=g.solicitantecodigo
       inner join ['+@base+'].dbo.co_tipodeorden h
            on a.tipoordencodigo=h.tipoordencodigo
       LEFT JOIN ['+@base+'].dbo.maeart i
            on b.oc_ccodigo=i.acodigo
  where a.tipoordencodigo='''+@tipo+''' and a.oc_cnumord=''' +@numero+'''  
  ORDER BY b.oc_citem '
--Set @nparame=N'@tipo varchar(2),@numero varchar(11)'
execute(@NCADENA)
--Execute sp_executesql @ncadena,@nparame,@tipo,@numero,
--EXEC al_impresionRequerimientos_rpt 'ZIYAZ','RC','00000000003'
GO
