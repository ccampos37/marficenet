SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
execute [al_impresionguia_rep] 'aliterm2012','01','NS','00000000001'

*/

CREATE       procedure [al_impresionguia_rep]
@base varchar(50),
@almacen varchar(2),
@tipo varchar(2),
@numero varchar(11)
as
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Set @ncadena=N'SELECT catipmov,ACODIGO,cafecdoc, aunidad,DELOTE,DEALMA,tadescri, kilos= DECANTID,isnull(decanref1,0) as rollos,
	descripcion= ADESCRI,DEORDFAB,catd,canumdoc,cacodmov,tt_descri, canomPRO,A.DEPRECIO,TOTAL=ROUND(A.DEPRECIO*DECANTID,2),
	DEORDFAB
     	FROM ['+@base+'].dbo.movalmdet A
	INNER JOIN ['+@base+'].dbo.maeart ON DECODIGO=ACODIGO
	INNER JOIN ['+@base+'].dbo.MOVALMCAB ON DEALMA=CAALMA AND DETD=CATD AND DENUMDOC=CANUMDOC
	INNER JOIN ['+@base+'].dbo.tabtransa ON CAcodmov=tt_codmov AND catipmov=tt_tipmov
	INNER JOIN ['+@base+'].dbo.tabalm ON dealma=taalma
	Where DEALMA=''' +@ALMACEN+''' AND DETD=''' +@TIPO+ ''' AND DENUMDOC=''' +@NUMERO+'''
        ORDER BY ACODIGO '

exec (@NCADENA)

-- EXEC al_impresionguia_rep 'ziyaz','04','NI','00000000055'
GO
