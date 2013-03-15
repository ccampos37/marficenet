SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [te_pagosxinternet_rpt] 'planta_casma','03','000028','4'

select * from planta_casma.dbo.te_cabecerarecibos where numerodocxrendir='000028'


*/
CREATE      proc [te_pagosxinternet_rpt]
--Declare
    @base varchar(50),
    @empresa varchar(2),
    @numero varchar(6)='',
    @tipo varchar(1)='1'
as
declare @cadsql varchar(4000)
if @tipo='1'
   begin
     set @cadsql='select recibo=''      '',chkconcil=''0'',empresadescripcion,b.pagosnumero,pagosfecha,pagosmoneda,
         bancocodigo,bancocuenta,pagostipodecambio,banconumero,c.clientecodigo,clienterazonsocial,
         cargodocumento,cargonumdoc,monedadocumento,saldo=importedocumento,importepago=importecancela,
        monedacancela,ctacteproveedor,proveedorruc,pagostipocuenta
        from '+@base+'.dbo.co_multiempresas a 
        inner join '+@base+'.dbo.te_cabecerapagosinternet b on a.empresacodigo=b.empresacodigo
        inner join '+@base+'.dbo.te_detallepagosinternet c on b.empresacodigo+b.pagosnumero=c.empresacodigo+c.pagosnumero
        inner join '+@base+'.dbo.cp_proveedor d on c.clientecodigo=d.clientecodigo
        where a.empresacodigo='''+@empresa+''' and b.pagosnumero='''+@numero+''' 
           and isnull(b.bancoestadoPendiente,''0'')=''1'''
     execute(@cadsql)    
   end

if @tipo='2'
   begin
     set @cadsql='select recibo=c.cabrec_numrecibo,chkconcil=''1'',empresadescripcion,b.pagosnumero,b.pagosfecha,b.pagosmoneda,b.bancocodigo,
        b.bancocuenta,b.pagostipodecambio,b.banconumero,e.clienterazonsocial,d.cabrec_numrecibo , 
        cargodocumento=d.detrec_tipodoc_concepto,cargonumdoc=d.detrec_numdocumento,
        monedadocumento=d.detrec_monedadocumento,
        saldo = case when d.detrec_monedadocumento =''01'' then  d.detrec_importesoles else d.detrec_importedolares end ,
        importepago = case when b.pagosmoneda =''01'' then  d.detrec_importesoles else d.detrec_importedolares end ,
        monedacancela=b.pagosmoneda,ctacteproveedor=''  '',proveedorruc='' '',pagostipocuenta='' ''
        from '+@base+'.dbo.co_multiempresas a 
        inner join '+@base+'.dbo.te_cabecerapagosinternet b on a.empresacodigo=b.empresacodigo
        inner join '+@base+'.dbo.te_cabecerarecibos  c on b.empresacodigo+b.pagosnumero=c.empresacodigo+c.numerodocxrendir
        inner join '+@base+'.dbo.te_detallerecibos  d on c.cabrec_numrecibo=d.cabrec_numrecibo 
        inner join '+@base+'.dbo.cp_proveedor e on c.clientecodigo=e.clientecodigo
        where a.empresacodigo='''+@empresa+''' and b.pagosnumero ='''+@numero+'''
          and isnull(b.bancoestadoPendiente,''0'')=''0'' '
     execute(@cadsql)    
   end

if @tipo='3'
   begin
      set @cadsql=' select monedacancela=''  '',ctacteproveedor=space(20),pagostipocuenta=space(1),tipocuenta01,cuenta01,tipocuenta02,cuenta02,
        chkconcil=0,clienteruc,clienterazonsocial,importepago=0,saldo1=cargoapeimpape-isnull(cargoapeimppag,0),saldo=cargoapeimpape-isnull(cargoapeimppag,0),
         a.* into ##tmp_tel from '+@base+'.dbo.cp_cargo a inner join '+@base+'.dbo.cp_proveedor b on a.clientecodigo=b.clientecodigo 
         where empresacodigo='''+@empresa+''' and isnull(cargoapeflgreg,0)=0 and isnull(cargoapeflgcan,0)=0  
            and cargoapeimpape-isnull(cargoapeimppag,0) > 0 and isnull(cargoapeflgreg,0)=0 and documentocargo=''01'' '
      execute(@cadsql)
   end

if @tipo='4'
   begin
      set @cadsql=' select monedacancela=''  '',ctacteproveedor=space(20),pagostipocuenta=space(1),tipocuenta01,cuenta01,tipocuenta02,cuenta02,
        chkconcil=0,clienteruc,clienterazonsocial,importepago=cargoapeimpape* 0.00,saldo1=cargoapeimpape-isnull(cargoapeimppag,0),saldo=cargoapeimpape-isnull(cargoapeimppag,0),
         a.* into ##tmp_tel from '+@base+'.dbo.cp_cargo a inner join '+@base+'.dbo.cp_proveedor b on a.clientecodigo=b.clientecodigo 
         where empresacodigo='''+@empresa+''' and isnull(cargoapeflgreg,0)=0 and isnull(cargoapeflgcan,0)=0  
            and cargoapeimpape-isnull(cargoapeimppag,0) > 0 and isnull(cargoapeflgreg,0)=0 and documentocargo in (''01'',''02'') '
      execute(@cadsql)
   end
GO
