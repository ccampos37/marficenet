SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop PROC ct_mayoriza_pro

EXECUTE CT_MAYORIZA_PRO 'planta_casma','01','2008',1,'AA'

*/
CREATE          PROC [ct_mayoriza_pro]
(@base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@mespro int,
@user varchar(50))
AS
DECLARE  @i int,@mes varchar(2),
         @sqlcad  varchar(8000),
         @sqlcad1 varchar(7000), 
         @sqlcad2 varchar(7000),
	 @sqlcad3 varchar(7000),
         @sqlcad4 varchar(7000),
	 @sqlcad5 varchar(7000),
	 @sqlcad6 varchar(7000)
--Insertando cuentas que falten en la tabla saldos de la tabla del plan de cuentas
SET @sqlcad1='
UPDATE ['+@base+'].dbo.[ct_detcomprob'+@anno+'] set cuentacodigo=rtrim(cuentacodigo),
       centrocostocodigo=rtrim(centrocostocodigo)
WHERE empresacodigo='''+@empresa+''' and cabcomprobmes='+rtrim(cast(@mespro as varchar(2)))+char(13)+ ''
execute(@sqlcad1)

set @sqlcad1='
INSERT ['+@base+'].dbo.[ct_saldos'+@anno+'](empresacodigo,cuentacodigo,fechaact,usuariocodigo)
SELECT empresacodigo,cuentacodigo,getdate(),'''+@user+''' FROM ['+@base+'].dbo.ct_cuenta
WHERE  empresacodigo='''+@empresa+''' and 
	cuentanivel=(SELECT TOP 1 sistemaultimonivel FROM ['+@base+'].dbo.ct_sistema) and 
	empresacodigo+cuentacodigo not in 
(SELECT empresacodigo+cuentacodigo FROM ['+@base+'].dbo.[ct_saldos'+@anno+'] where empresacodigo='''+@empresa+''')'
--Actualizando saldos del mes indicado Agrupando los Montos del Movimiento
SET @mes=replicate('0',2-len(@mespro))+ rtrim(cast(@mespro as varchar(2)))
--Actualizando a ceros a todas las cuentas 
SET @sqlcad2=''+
	'UPDATE ['+@base+'].dbo.[ct_saldos'+@anno+']'+CHAR(13)+ 
	'SET saldodebe'+@mes+'=0'+CHAR(13)+
    	',saldohaber'+@mes+'=0'+CHAR(13)+
    	',saldoussdebe'+@mes+'=0'+CHAR(13)+
    	',saldousshaber'+@mes+'=0'+CHAR(13)+
		',saldoacumdebe'+@mes+'=0'+CHAR(13)+
		',saldoacumhaber'+@mes+'=0'+CHAR(13)+
		',saldoacumusshaber'+@mes+'=0'+CHAR(13)+
		',saldoacumussdebe'+@mes+'=0  where empresacodigo='''+@empresa+''''
SET @sqlcad3=''+
	'UPDATE ['+@base+'].dbo.[ct_saldos'+@anno+']'+CHAR(13)+ 
	'SET saldodebe'+@mes+'=B.debe'+CHAR(13)+
    	',saldohaber'+@mes+'=B.haber'+CHAR(13)+
    	',saldoussdebe'+@mes+'=B.ussdebe'+CHAR(13)+
    	',saldousshaber'+@mes+'=B.usshaber'+CHAR(13)+
'FROM
 ['+@base+'].dbo.[ct_saldos'+@anno+'] A,
	(SELECT
	 empresacodigo,cabcomprobmes,cuentacodigo,debe=sum(detcomprobdebe),haber=sum(detcomprobhaber),
                               ussdebe=sum(detcomprobussdebe),usshaber=sum(detcomprobusshaber)
 	 FROM ['+@base+'].dbo.[ct_detcomprob'+@anno+']
 	 WHERE empresacodigo='''+@empresa+''' and cabcomprobmes='+rtrim(cast(@mespro as varchar(2)))+char(13)+
 	 'GROUP BY empresacodigo,cabcomprobmes,cuentacodigo) as B
 WHERE 
	a.empresacodigo=b.empresacodigo and A.cuentacodigo=B.cuentacodigo'
--Insertando cuentas que falten en la tabla saldos de la tabla de gastos
SET @sqlcad4=''+
'INSERT ['+@base+'].dbo.[ct_gastos'+@anno+'](empresacodigo,cuentacodigo,centrocostocodigo)
SELECT DISTINCT empresacodigo,rtrim(cuentacodigo),rtrim(centrocostoCODIGO) FROM ['+@base+'].dbo.[ct_detcomprob'+@anno+']
   WHERE  empresacodigo+cuentacodigo+centrocostocodigo not in 
   (SELECT empresacodigo+cuentacodigo+centrocostocodigo FROM 
     ['+@base+'].dbo.[ct_gastos'+@anno+'] where empresacodigo='''+@empresa+''') and empresacodigo='''+@empresa+'''
     and centrocostocodigo<>''00'''
--Actualizando a ceros a todas las cuentas de gastos
SET @sqlcad5=''+
	'UPDATE ['+@base+'].dbo.[ct_gastos'+@anno+']'+CHAR(13)+ 
	'SET gastos'+@mes+'=0,'+CHAR(13)+
        'gastosuss'+@mes+'=0,'+CHAR(13)+
	'gastosacum'+@mes+'=0,'+CHAR(13)+
	'gastosacumuss'+@mes+'=0 where empresacodigo='''+@empresa+''''
-- actualizando saldos desde movimientos
SET @sqlcad6=''+
    'UPDATE ['+@base+'].dbo.[ct_gastos'+@anno+']'+CHAR(13)+ 
	'SET gastos'+@mes+'=Bb.debe-bb.haber'+CHAR(13)+
    	',gastosuss'+@mes+'=Bb.ussdebe-bb.usshaber'+CHAR(13)+
'FROM
 ['+@base+'].dbo.[ct_gastos'+@anno+'] A,
	(SELECT
	 a.empresacodigo,a.cabcomprobmes,a.cuentacodigo,a.centrocostocodigo,
         debe=sum(a.detcomprobdebe),
         haber=sum(a.detcomprobhaber),
         ussdebe=sum(a.detcomprobussdebe),
         usshaber=sum(a.detcomprobusshaber)
 	 FROM ['+@base+'].dbo.[ct_detcomprob'+@anno+'] a
         inner join ['+@base+'].dbo.[ct_cuenta] b on a.empresacodigo=b.empresacodigo and A.cuentacodigo = B.cuentacodigo   
 	 WHERE a.empresacodigo='''+@empresa+''' and a.cabcomprobmes='+rtrim(cast(@mespro as varchar(2)))+char(13)+
            ' and a.centrocostocodigo<>''00'' and b.cuentaestadoccostos=1  
         GROUP BY a.empresacodigo,a.cabcomprobmes,a.cuentacodigo,a.centrocostocodigo) as Bb
 WHERE 
	a.empresacodigo+A.cuentacodigo+a.centrocostocodigo=bb.empresacodigo+Bb.cuentacodigo+bb.centrocostocodigo'
  exec (@sqlcad1)           
  exec (@sqlcad2)	    
  exec (@sqlcad3)
  exec (@sqlcad4)
  exec (@sqlcad5)
  exec (@sqlcad6)
--Ejecutando el sp que recalcula Acumulados
  execute ct_recalacum_pro @base,@empresa,@anno,@mespro,@user
GO
