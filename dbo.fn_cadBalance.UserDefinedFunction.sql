SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  función definida por el usuario dbo.fn_cadBalance    Fecha de la secuencia de comandos: 01/01/2008 08:18:11 p.m. ******/
/*
drop  FUNCTION dbo.fn_cadBalance
*/
create FUNCTION [fn_cadBalance]
(
@Base varchar(50),
@empresa varchar(2),
@anno varchar(4),
@nmes int,
@cad varchar(50),
@nivel int
)      
RETURNS varchar(2000)
BEGIN 	
	DECLARE  @sqlcad varchar(2000),@mes varchar(2)
	SET @mes=replicate('0',2-len(@nmes))+ rtrim(cast(@nmes as varchar(2)))
	SET @sqlcad=''+
	 'SELECT empresacodigo,		
	      cuenta=left(cuentacodigo,'+@cad+'),
          debe00=sum(saldodebe00),
          haber00=sum(saldohaber00),
		  debe=Sum(saldodebe'+@mes+') , 
          haber=Sum(saldohaber'+@mes+'),
		  debeAC=Sum(saldoacumdebe'+@mes+'),
          haberAC=Sum(saldoacumhaber'+@mes+'),
          debeuss00=sum(saldoussdebe00),
          haberuss00=sum(saldousshaber00),
		  debeuss=Sum(saldoussdebe'+@mes+'),
          haberuss=Sum(saldousshaber'+@mes+'),
		  debeACuss=Sum(saldoacumussdebe'+@mes+'),
          haberACuss=Sum(saldoacumusshaber'+@mes+'),
          nivel='+rtrim(cast(@nivel as varchar(10)))+'  
 	  FROM ['+@Base+'].dbo.[ct_saldos'+@anno+']
             where empresacodigo='''+@empresa+'''  	     
 	     GROUP BY empresacodigo,left(cuentacodigo,'+@cad+')'
    RETURN @sqlcad
END
GO
