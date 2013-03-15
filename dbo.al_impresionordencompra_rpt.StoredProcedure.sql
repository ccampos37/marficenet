SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
---drop   procedure al_impresionordencompra_rpt
--EXEC al_impresionordencompra_rpt 'aliterm','ON','00000000085'
CREATE          procedure [al_impresionordencompra_rpt]
@base varchar(50),
@tipo varchar(10),
@numero varchar(11)
as
Declare @ncadena nvarchar(4000)
Declare @nparame nvarchar(4000)
Set @ncadena=N'SELECT  A.TIPOORDENcodigo,h.tipoordendescripcion,
		 a.oc_cnumord,a.OC_DFECDOC,
                 OC_CCODPRO=d.clienteruc,
                  OC_CRAZSOC=d.clienterazonsocial,
                  OC_CDIRPRO=d.clientedireccion,d.clientetelefono,d.clientedistrito,
                  d.clientepropietario,d.clientefax,
                  b.oc_nfactor,b.oc_cuniref,
                  e.formapagodescripcion,
		  f.aunidad,
                  g.solicitantenombre,
                  OC_CENTREG,OC_CCOTIZA,
                  a.OC_CCODMON,OC_CFORPAG,OC_DFECENT,OC_COBSERV,OC_NIMPORT,
                  OC_NDESCUE,a.OC_NIGV,OC_NVENTA,
                  OC_CITEM,OC_CCODIGO,oc_ccodref,ord_fabnum,b.oc_ccomen2,
                  Oc_cdesref,
                  OC_NCANTID as d_cant,OC_NPREUNI as d_precio,
                  OC_NDSCPOR as d_pordscto,OC_NDESCTO as d_dscto,
                  b.OC_NIGV as d_igv,OC_NPRENET as d_precioneto,
                  OC_NTOTVEN as d_venta,
                  OC_NTOTNET as d_neto ,OC_COMENTA=b.OC_CCOMEN1 , monedasimbolo,d.clientepropietario as contacto
     	       FROM ['+@base+'].dbo.co_cabordcompra a
                   INNER JOIN ['+@base+'].dbo.co_detordcompra b
	              ON a.oc_cnumord = b.oc_cnumord and a.tipoordencodigo=b.tipoordencodigo
                   inner join ['+@base+'].dbo.gr_moneda c
                      on oc_ccodmon=c.monedacodigo
                   inner join ['+@base+'].dbo.cp_proveedor d
                      on a.oc_ccodpro=d.clientecodigo
                   inner join ['+@base+'].dbo.vt_formapago e
		      on oc_cforpag=formapagocodigo
                   LEFT join ['+@base+'].dbo.maeart f
		      on b.OC_CCODIGO=f.acodigo
                   inner join ['+@base+'].dbo.co_solicitantes g
		      on a.OC_CSOLICT=g.solicitantecodigo
                   inner join ['+@base+'].dbo.co_tipodeorden h
		      on a.tipoordencodigo=h.tipoordencodigo
              Where a.tipoordencodigo='''+@tipo+''' and a.oc_cnumord=''' +@numero+'''  
              ORDER BY b.oc_citem '
--Set @nparame=N'@tipo varchar(2),@numero varchar(11)'
EXECUTE(@NCADENA)
--Execute sp_executesql @ncadena,@nparame,@tipo,@numero,
GO
