SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
drop      proc ct_EliminaAsientosTesoreria_pro
exec te_EliminaAsientosTesoreria_pro 'mmj2008','01','012','0001','01','01','2003'
*/
  	
CREATE       proc [ct_EliminaAsientosTesoreria_pro] 
  	@Baseconta 		varchar(100),
	@empresa 		varchar(2),  	
	@Asiento	    	varchar(15), 
	@SubAsiento 		varchar(15),
  	@Libro   		varchar(2),         
  	@Mes     		varchar(2),
  	@Ano     		varchar(4)
	
as    
declare @sqlcad varchar(2000)
set @sqlcad='DELETE FROM ' +@Baseconta+ '.dbo.ct_cabcomprob' +@ano+ ' '+
	'where  empresacodigo=''' +@empresa+ ''' and
                asientocodigo=''' +@Asiento+ ''' and 
	        subasientocodigo=''' +@SubAsiento+ ''' and
		cabcomprobmes=''' +@mes+ ''''
exec(@sqlcad)
GO
