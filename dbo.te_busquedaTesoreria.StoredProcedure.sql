SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.te_busquedaTesoreria    fecha de la secuencia de comandos: 21/04/2007 06:57:35 a.m. ******/
/****** Objeto:  procedimiento almacenado dbo.te_busquedaTesoreria    fecha de la secuencia de comandos: 20/04/2007 09:00:01 a.m. ******/
CREATE   proc [te_busquedaTesoreria]
@base as nvarchar(20),
@dato as nvarchar(20)
as
declare @cadena nvarchar(4000)
set @cadena =' 
select tipo=''TE'',recibo=a.cabrec_numrecibo,fecha=detrec_fechacancela,cabrec_ingsal,proveedor=c.clienterazonsocial,
documento=e.tdocumentodescripcion,
moneda=case when detrec_monedacancela=''01'' then ''S/.'' else ''US$'' end,
importe=case when detrec_monedacancela=''01'' then detrec_importesoles else detrec_importedolares end,
conceptodescripcion,Glosa=case when isnull(conceptodescripcion,'''')='''' then 
                case when rtrim(a.cabrec_observacion1)='''' then
                          b.detrec_observacion else a.cabrec_observacion1 end                      
           else conceptodescripcion end ,               
pago=f.tdocumentodescripcion,b.rendicionnumero 
from ['+@base +'].dbo.te_cabecerarecibos a 
inner join ['+@base +'].dbo.te_detallerecibos b on a.cabrec_numrecibo=b.cabrec_numrecibo 
left join ['+@base +'].dbo.cp_proveedor c  on a.clientecodigo=c.clientecodigo
left join ['+@base +'].dbo.te_conceptocaja d on b.detrec_tipodoc_concepto=d.conceptocodigo
left join ['+@base +'].dbo.cp_tipodocumento e on b.detrec_tipodoc_concepto=e.tdocumentocodigo 
left join ['+@base +'].dbo.cp_tipodocumento f on b.detrec_tdqc=f.tdocumentocodigo 
where c.clienterazonsocial like (''%'+upper(@dato)+'%'') 
      OR a.cabrec_observacion1 like (''%'+upper(@dato)+'%'')
      OR b.detrec_observacion like (''%'+upper(@dato)+'%'')'
execute(@cadena)
--- execute te_busquedaTesoreria 'acuaplayacasma', 'cocina'
-- select * from acuaplayacasma.dbo.cp_proveedor order by 1
GO
