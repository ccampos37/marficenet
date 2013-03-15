SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_recalacum_pro    fecha de la secuencia de comandos: 19/12/2007 11:30:24 a.m. *****
drop PROC ct_recalacum_pro
EXECUTE CT_recalacum_PRO 'gremco','12','2007',1,'AA'
*/
CREATE      PROC [ct_recalacum_pro]
(@base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@mespro int,
@user varchar(50))
AS
DECLARE  @i int,
@mes varchar(2),
@sqlcad1  varchar(8000),     
@sqlcad  varchar(8000)     
--Generando la Cadena Para el Recalculo de los Saldos Acumulados 
SET @i=@mespro
SET @sqlcad1='' 
SET @sqlcad=''
WHILE @i <=12
BEGIN
	SET @mes=replicate('0',2-len(@i))+ rtrim(cast(@i as varchar(2))) 
	IF @i>@mespro SET @sqlcad=@sqlcad+','
           SET @sqlcad=@sqlcad + 				
       	     'saldoacumhaber'+@mes+'=saldohaber00+'+dbo.fn_getcad(@i,1)+CHAR(13)+         
		',saldoacumdebe'+@mes+'=saldodebe00+'+ dbo.fn_getcad(@i,2)+CHAR(13)+
		',saldoacumusshaber'+@mes+'=saldousshaber00+'+ dbo.fn_getcad(@i,3)+CHAR(13)+
		',saldoacumussdebe'+@mes+'=saldoussdebe00+'+ dbo.fn_getcad(@i,4)+CHAR(13)
       	IF @i>@mespro SET @sqlcad1=@sqlcad1+','
           SET @sqlcad1=@sqlcad1+ 				
            'gastosacum'+@mes+'='+dbo.fn_getcad_gastos(@i,1)+CHAR(13)+
	    ',gastosacumuss'+@mes+'='+dbo.fn_getcad_gastos(@i,2)+CHAR(13)
	SET @i=@i+1
END
SET @sqlcad='UPDATE ['+@base+'].dbo.[ct_saldos'+@anno+']'+CHAR(13)+    
            'SET '+@sqlcad + ' where empresacodigo='''+@empresa+'''' 
SET @sqlcad1='UPDATE ['+@base+'].dbo.[ct_gastos'+@anno+']'+CHAR(13)+    
            'SET '+@sqlcad1 + ' where empresacodigo='''+@empresa+''''
execute (@sqlcad)
execute (@sqlcad1)
--select * from data_mmj.dbo.ct_gastos2005
GO
