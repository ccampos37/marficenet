SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Drop proc [dbo].[te_voucher_rpt] 

exec te_voucher_sub_rpt 'gremco','208869'

*/

create  proc [cc_imprimeplanillacobranza_sub_rpt] 

@Base  varchar(50),
@Nrecibo  varchar(6)

as
Declare @SqlCad varchar(8000)

Declare @BDTablaCabecera as varchar(100)
Declare @BDTablaDetalle as varchar(100)
Declare @Anno as varchar(4)
Declare @SqlAux as varchar(1000)

if exists (select name from tempdb.dbo.sysobjects where name='##tmpDato') 
  exec('DROP TABLE ##tmpDato')

Set @SqlAux= 'Select Year(cabrec_fechadocumento) as Anno Into ##tmpDato From ['+@Base+'].dbo.te_cabecerarecibos Where cabrec_numrecibo='''+@nrecibo+''' '
execute(@SqlAux)
Set @Anno = (Select Cast(Anno as varchar(4)) From ##tmpDato)
exec('DROP TABLE ##tmpDato')

Set @BDTablaCabecera=' ['+@Base+'].dbo.[ct_cabcomprob'+@Anno+']'
Set @BDTablaDetalle=' ['+@Base+'].dbo.[ct_detcomprob'+@Anno+']'

Set @SqlCad='select b.cabcomprobnumero,b.cabcomprobmes,c.detcomprobitem,c.cuentacodigo,d.cuentadescripcion ,
e.monedadescripcion,c.detcomprobdebe,c.detcomprobhaber,detcomprobglosa
from ['+@Base+'].dbo.te_cabecerarecibos A
     left join '+@BDTablaCabecera+' b 
       on A.empresacodigo=b.empresacodigo and a.comprobconta=b.cabcomprobnumero
     inner join '+@BDTablaDetalle+' c 
       on b.empresacodigo=c.empresacodigo and b.cabcomprobmes=c.cabcomprobmes 
          and b.asientocodigo=c.asientocodigo and b.subasientocodigo=c.subasientocodigo
          and b.cabcomprobnumero=c.cabcomprobnumero
     inner join ['+@Base+'].dbo.ct_cuenta d 
       on c.empresacodigo=d.empresacodigo and c.cuentacodigo=d.cuentacodigo
     inner join ['+@Base+'].dbo.gr_moneda e 
       on c.monedacodigo=e.monedacodigo
Where A.cabrec_numrecibo='''+@Nrecibo+''' '

Execute(@SqlCad) 
--execute  te_voucher_rpt  'gremco','100007'
GO
