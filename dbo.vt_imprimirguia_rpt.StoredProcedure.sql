SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
execute vt_imprimirguia_rpt 'desarrollo','13','GR','00200017250'
SELECT * FROM ZIYAZ.DBO.MOVALMcab where DETD='GS'DEnumdoc='00000000071'

select * from tabalm
select * from co_multiempresas
*/

CREATE                      procedure [vt_imprimirguia_rpt]
@base varchar(50),
@almacen varchar(2),
@tipo varchar(2),
@numdoc varchar(15)
as
declare @cadena as nvarchar(2000)

SET @cadena =N' SELECT caalma,a.catd,a.canumdoc,a.cafecdoc,A.canomcli,a.cadirenv,a.cacodtran,C.decodigo,c.decantid,
c.deunidad,caglosa,adescri=case when isnull(q.clientetipoespecial,''0'')=''1'' then 
         rtrim(D.adescri)+'' ''+isnull(d.acodigo2,'' '') else d.adescri end,
E.tranombre,a.caruc,a.contacto,empresadescripcion,a.CARFTDOC,a.CARFNDOC,
empresadireccion=case when len(rtrim(r.tadirecc))=0 then 
                 empresadireccion else rtrim(tadirecc)+'' ''+ rtrim(tadistri) end,
isnull(e.trabreve,'''' ) as Brevete,v.vendedornombres as Vendedor,
caructra,canomtra,cadirtra,
factura=p.pedidotipofac+''-''+pedidonrofact,q.clientedireccion
FROM ['+@base+'].dbo.MOVALMCAB A 
INNER JOIN ['+@base+'].dbo.movalmdet C ON a.caalma+a.catd+a.canumdoc=c.dealma+c.detd+C.denumdoc
INNER JOIN ['+@base+'].dbo.MAEART D ON C.decodigo=D.ACODIGO
left join ['+@base+'].dbo.co_multiempresas m on a.empresacodigo=m.empresacodigo
left join ['+@base+'].dbo.al_transporte E on a.cacodtran=E.tracodigo
left join ['+@base+'].dbo.vt_vendedor v on a.cavende=v.vendedorcodigo
left join ['+@base+'].dbo.vt_pedido p on a.empresacodigo+a.canroped=p.empresacodigo+p.pedidonumero
LEFT join ['+@base+'].dbo.vt_cliente q on a.cacodcli=q.clientecodigo
left join ['+@base+'].dbo.tabalm r on a.caalma=r.taalma 
where a.catipmov=''S'' and a.caalma='''+@almacen+''' and a.carftdoc='''+@tipo+''' and a.carfndoc='''+@numdoc+''''

EXECUTE(@cadena)
GO
