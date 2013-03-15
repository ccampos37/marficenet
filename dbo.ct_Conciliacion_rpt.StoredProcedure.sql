SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_Conciliacion_rpt    fecha de la secuencia de comandos: 19/12/2007 03:36:11 p.m. ******/
--select A.cabcomprobnumero,A.asientocodigo,A.subasientocodigo,A.monedacodigo,tipdocref=isnull(A.tipdocref,''),detcomprobnumref=isnull(A.detcomprobnumref,''),A.detcomprobfechaemision,A.analiticocodigo,C.entidadrazonsocial,A.detcomprobdebe,A.detcomprobhaber,A.detcomprobusshaber,A.detcomprobussdebe , A.detcomprobtipocambio,A.detcomprobconci 
--From ct_detcomprob2002 A,dbo.v_analiticoentidad C 
--Where A.analiticocodigo = C.analiticocodigo and  cuentacodigo='104111'
/*
drop  proc ct_Conciliacion_rpt 
 exec ct_Conciliacion_rpt 'mmj2008','01','2007','10','104111','-1','09'
*/
CREATE      proc [ct_Conciliacion_rpt]
( 
	
	@base varchar(50),
	@empresa varchar(2),	
	@anno varchar(4),
	@mescomprob varchar(2),
	@cuentacodigo varchar(20),
	@bitconcil   varchar(2),
    @mesant varchar(2)
)
as
 
Declare @sqlcad varchar(1500)
set @sqlcad='
select a.empresacodigo,A.cuentacodigo, D.cuentadescripcion,  
  A.cabcomprobnumero,A.asientocodigo,A.subasientocodigo,
  A.monedacodigo,tipdocref=isnull(A.documentocodigo,''''),
  A.detcomprobnumdocumento, A.detcomprobfechaemision,
  A.analiticocodigo,C.entidadrazonsocial,
  A.detcomprobdebe,A.detcomprobhaber,
  A.detcomprobusshaber,A.detcomprobussdebe, 
  A.detcomprobtipocambio,A.detcomprobconci,
  SaldoAcS= case ' +@mesant+ ' when ''00'' then
				(H.saldodebe' +@mesant+ '-H.saldohaber' +@mesant+ ')
			else
				(H.saldoacumdebe' +@mesant+ '-H.saldoacumhaber' +@mesant+ ')
			end,
  SaldoAcD= case ' +@mesant+ ' when ''00'' then
				(H.saldoussdebe' +@mesant+ '-H.saldousshaber' +@mesant+ ')
			else
				(H.saldoacumussdebe' +@mesant+ '-H.saldoacumusshaber' +@mesant+ ')
			end
  From [' +@base+ '].dbo.ct_detcomprob' +@anno+ ' A inner join [' +@base+ '].dbo.v_analiticoentidad C
        on A.analiticocodigo = C.analiticocodigo 
     inner join ['  +@base+ '].dbo.ct_cuenta D on a.empresacodigo=d.empresacodigo and A.cuentacodigo=D.cuentacodigo
     inner join ['  +@base+ '].dbo.ct_Saldos' +@anno+ ' H on A.cuentacodigo=H.cuentacodigo and A.empresacodigo=H.empresacodigo
Where	A.cuentacodigo like ''' +@cuentacodigo+  ''' and 
	detcomprobconci like ''' + cast(@bitconcil as varchar(2))   +  ''' '
exec(@sqlcad)
GO
