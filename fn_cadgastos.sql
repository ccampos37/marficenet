SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  función definida por el usuario dbo.fn_cadBalance    Fecha de la secuencia de comandos: 01/01/2008 08:18:11 p.m. ******/
/*
drop  FUNCTION dbo.fn_cadBalance
*/
ALTER FUNCTION [fn_cadgastos]
(
@Base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@nmes int,
@cad varchar(50),
@nivel int
)      
RETURNS varchar(1000)
BEGIN 	
	DECLARE  @sqlcad varchar(2000),@mes varchar(2),@mesant varchar(2)
	SET @mes=replicate('0',2-len(@nmes))+ rtrim(cast(@nmes as varchar(2)))
	SET @mesant=replicate('0',2-len(@nmes-1))+ rtrim(cast(@nmes-1 as varchar(2)))
	SET @sqlcad=''+ 'SELECT empresacodigo,	cuenta=left(cuentacodigo,'+@cad+'),
         saldoact =sum(gastosacum'+@mes+'),
          nivel='+rtrim(cast(@nivel as varchar(10)))+' FROM ['+@Base+'].dbo.[ct_gastos'+@anno+']
          where empresacodigo='''+@empresa+''' and left(centrocostocodigo,2) in (''10'',''20'') 
             and gastosacum'+@mes+' <> 0 	     
 	     GROUP BY empresacodigo,left(cuentacodigo,'+@cad+')'
    RETURN @sqlcad
END
