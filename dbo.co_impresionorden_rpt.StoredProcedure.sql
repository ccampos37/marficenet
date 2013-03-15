SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE        procedure [co_impresionorden_rpt]
@base varchar(50),
@tipo varchar(2),
@numero varchar(11)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT a.OC_CNUMORD,a.OC_DFECDOC,a.OC_CCODPRO,
                  OC_CRAZSOC=d.clienterazonsocial,
                  OC_CDIRPRO=d.clientedireccion,
                  a.OC_CCODMON,OC_CFORPAG,OC_DFECENT,OC_COBSERV,OC_NIMPORT,
                  OC_NDESCUE,a.OC_NIGV,OC_NVENTA,
                  OC_CITEM,OC_CCODIGO,oc_ccodref,ord_fabnum,OC_CDESREF,
                  OC_NCANTID as d_cant,OC_NPREUNI as d_precio,
                  OC_NDSCPOR as d_pordscto,OC_NDESCTO as d_dscto,
                  b.OC_NIGV as d_igv,OC_NPRENET as d_precioneto,OC_NTOTVEN as d_venta,
                  OC_NTOTNET as d_neto ,OC_COMENTA , monedasimbolo
     	       FROM ['+@base+'].dbo.co_cabordcompra a
                   INNER JOIN ['+@base+'].dbo.co_detordcompra b
	              ON a.oc_cnumord = b.oc_cnumord and a.tipoordencodigo=b.tipoordencodigo
                   inner join ['+@base+'].dbo.gr_moneda c
                      on oc_ccodmon=c.monedacodigo
                   inner join ['+@base+'].dbo.cp_proveedor d
                      on a.oc_ccodpro=d.clientecodigo
              Where a.oc_cnumord=''' +@numero+'''  
              ORDER BY b.oc_citem '
--Set @nparame=N'@tipo varchar(2),@numero varchar(11)'
execute (@NCADENA)
--Execute sp_executesql @ncadena,@nparame,@tipo,@numero,
--EXEC co_impresionorden_rpt 'invnemo','OC','00000000017'
GO
