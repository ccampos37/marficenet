SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [vt_impresion]
@base varchar(50),
@tabla varchar(50),
@lista varchar(50),
@almacen varchar(2),
@numero char(11),
@items varchar(2)
as
Declare @totitem float
Declare @titems float
Declare @ncadena nvarchar(2000)
Declare @nparame nvarchar(2000)
Declare @nspace varchar(1)
set nocount on
Set @ncadena=N'drop table ['+@base+'].dbo.tempfile'
Execute sp_executesql @ncadena
Set @nspace=' '
Set @ncadena=N'Create table ['+@base+'].dbo.tempfile
		( detpedcantpedida char(8),
		  productocodigo char(8),
		  productodescripcion char(80),
		  detpedmontoprecvta float,
		  detpedimpbruto float)'
Execute sp_executesql @ncadena
Set @ncadena=N'INSERT into ['+@base+'].dbo.tempfile
		  Select a.detpedcantpedida,a.productocodigo,b.productodescripcion,(a.detpedimpbruto/a.detpedcantpedida),a.detpedimpbruto
		  From ['+@base+'].dbo.'+@tabla+' A join ['+@base+'].dbo.'+@lista+' B 
		  On A.productocodigo=B.productocodigo 
		  Where pedidonumero=@numero and b.almacencodigo=@almacen'
Set @nparame=N'@numero char(11),@almacen varchar(2)'
Execute sp_executesql @ncadena,@nparame,@numero,@almacen
  set @titems=@items
  set @totitem=@@rowcount  
  set @totitem=@totitem+1 
  WHILE @totitem<=@items
   BEGIN
     Set @ncadena=N'INSERT INTO ['+@base+'].dbo.tempfile(detpedcantpedida,productocodigo,productodescripcion,detpedmontoprecvta,detpedimpbruto)
		    VALUES (@nspace,@nspace,@nspace,null,null)'
     set @nparame=N'@nspace varchar(1)'
     Execute sp_executesql @ncadena,@nparame,@nspace		
     set @totitem=@totitem+1
   END
  Set @ncadena=N'select * from ['+@base+'].dbo.tempfile'
   
  Execute sp_executesql @ncadena
GO
