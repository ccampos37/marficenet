SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [al_stockinicial_rpt]
@base varchar(50),
@empresa varchar(2),
@alma varchar(2),
@transa varchar(2)
as
declare @cadena as nvarchar(1000)
declare @parame as nvarchar(1000)
declare @i as varchar(1)
set @i='I'
set @cadena='SELECT almacen=dealma+'' '' + almacendescripcion, DECODIGO,codigodescripcion ,cant=ROUND(SUM(A.DECANTID),4) ,  total=ROUND(SUM(A.DECANTID*isnull(a.deprecio,0)),2) 
             FROM ['+@base+'].dbo.v_kardex a 
             WHERE empresacodigo='''+@empresa+''' and cacodmov='''+@transa+''' '
if @alma<>'%%' set @cadena= @cadena + ' and  A.DEALMA='''+@alma +''' '
set @cadena = @cadena +' GROUP BY dealma,almacendescripcion,DECODIGO,codigodescripcion  having ROUND(SUM(A.DECANTID),4)<> 0 ORDER BY codigodescripcion,A.DECODIGO ' 

execute(@cadena)
GO
