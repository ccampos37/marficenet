SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_GeneraCtaCteApertura
*/
 
CREATE    proc [ct_GeneraCtaCteApertura]
(	
	@base		varchar(50),
        @empresa 	varchar(2), 
	@annoact 	varchar(4),
	@annopas	varchar(4)
	
)
as
Declare @cadsql varchar(4000)
set @cadsql='
	Insert [' +@base+ '].dbo.ct_ctacteanalitico' +@annoact+ '
		(empresacodigo,cabcomprobmes, detcomprobitem, cabcomprobnumero, subasientocodigo, asientocodigo, documentocodigo, operacioncodigo, cuentacodigo, 
		 ctacteanaliticofechaconta, analiticocodigo, ctacteanaliticonumdocumento, ctacteanaliticofechadoc, ctacteanaliticoglosa, ctacteanaliticodebe, 
		ctacteanaliticoussdebe, ctacteanaliticohaber, ctacteanaliticousshaber, ctacteanaliticocancel, ctacteanaliticofechaven,monedacodigo,ctacteanaliticosaldo)
	select 
		empresacodigo,cabcomprobmes, detcomprobitem, cabcomprobnumero=''00''+left(cabcomprobnumero,2)+substring(cabcomprobnumero,4,2)+right(cabcomprobnumero,4), 
		subasientocodigo, asientocodigo, documentocodigo, operacioncodigo, cuentacodigo, 
 		ctacteanaliticofechaconta, analiticocodigo, ctacteanaliticonumdocumento, 
		ctacteanaliticofechadoc,ctacteanaliticoglosa, ctacteanaliticodebe, 
 		ctacteanaliticoussdebe, ctacteanaliticohaber, ctacteanaliticousshaber, ctacteanaliticocancel, ctacteanaliticofechaven,monedacodigo,ctacteanaliticosaldo
	from
		[' +@base+ '].dbo.ct_ctacteanalitico' +@annopas + '
	where  
	       empresacodigo like ''' +@empresa+  ''' and
               ctacteanaliticocancel is null'
exec(@cadsql)
GO
