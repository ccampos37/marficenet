SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [al_stockinicial_rep]
@base varchar(50),
@alma varchar(2),
@tipo varchar(2)
as
declare @cadena as nvarchar(1000)
declare @parame as nvarchar(1000)
declare @i as varchar(1)
set @i='I'
set @cadena='SELECT A.DECODIGO,C.ADESCRI,ROUND(SUM(A.DECANTID),2) as total 
             FROM ['+@base+'].dbo.MOVALMDET A INNER JOIN 
             ['+@base+'].dbo.MOVALMCAB B 
             ON A.DEALMA=B.CAALMA AND A.DETD=B.CATD AND A.DENUMDOC=B.CANUMDOC 
             INNER JOIN ['+@base+'].dbo.MAEART C 
             ON A.DECODIGO=C.ACODIGO 
             WHERE A.DEALMA='''+@alma +''' AND B.CACODMOV='''+@tipo +''' AND B.CATIPMOV='''+@I+'''
             GROUP BY A.DECODIGO,C.ADESCRI ORDER BY C.ADESCRI,A.DECODIGO'
execute(@cadena)
GO
