SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop PROC ct_SaldosAnalitico_rpt
exec  ct_SaldosAnalitico_rpt 'planta_casma','03','2011','00','10','12%','%%','%%','1'
*/
CREATE           PROC [ct_SaldosAnalitico_rpt]
(
	@base			varchar(50),
    @empresa                varchar(2),
	@anno			varchar(4),
	@cabcomprobmesini	varchar(2),
	@cabcomprobmesfin	varchar(2),
	@cuentacodigo		varchar(20),
	@codigoanalitico	varchar(14),
	@tipoanaliticocodigo	varchar(3),
	@AjusteDifCambio Char(1)='1'
)
as
Declare @sqlcad varchar(5000)
set @sqlcad='select z.* from 
	 (  SELECT A.empresacodigo,
                   	    B.entidadcodigo, 
    	   	    A.cuentacodigo,
		    C.cuentadescripcion,
    		    B.entidadruc, 
	    	    B.entidadrazonsocial,a.monedacodigo,b.tipoanaliticocodigo,
    		    sumdebs=SUM(A.ctacteanaliticodebe), 
	    	    sumhabs=SUM(A.ctacteanaliticohaber), 
	       	    sumdebd=SUM(A.ctacteanaliticoussdebe), 
	    	    sumhabd=SUM(A.ctacteanaliticousshaber)
	      FROM  [' +@base+ '].dbo.[ct_ctacteanalitico' +@anno+ '] A
                    inner join  [' +@base+ '].dbo.v_analiticoentidad B
                        on A.analiticocodigo=B.analiticocodigo
	            inner join  [' +@base+ '].dbo.ct_cuenta C
                        on a.empresacodigo=c.empresacodigo and A.cuentacodigo = c.cuentacodigo 
	      WHERE     A.empresacodigo like '''+@empresa+''' AND
			A.cuentacodigo like ''' +@cuentacodigo+ ''' AND c.cuentaestadoanalitico=''1'' AND 
			A.analiticocodigo like ''' +@codigoanalitico+ ''' AND
			B.tipoanaliticocodigo like ''' +@tipoanaliticocodigo+ ''' AND
			A.cabcomprobmes BETWEEN ' +@cabcomprobmesini+ ' AND ' +@cabcomprobmesfin + '
	      GROUP BY 	
			A.empresacodigo,
                        B.entidadcodigo,b.tipoanaliticocodigo,
    		        A.cuentacodigo,
			C.cuentadescripcion,
			B.entidadruc, 
			B.entidadrazonsocial,a.monedacodigo
	) as z where '

If @AjusteDifCambio='0'
  Begin
	set @sqlcad=@sqlcad+' (z.sumdebS-z.sumhabS <> 0 And z.monedacodigo=''01'') Or  (z.sumdebd-z.sumhabd <> 0 And z.monedacodigo=''02'')'
  End
Else
  Begin
	set @sqlcad=@sqlcad+' z.sumdebS-z.sumhabS <> 0 '
  End


execute( @sqlcad)
--
GO
