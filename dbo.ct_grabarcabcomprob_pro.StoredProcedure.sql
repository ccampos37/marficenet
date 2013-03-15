SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Objeto:  procedimiento almacenado dbo.ct_grabarcabcomprob_pro    fecha de la secuencia de comandos: 26/12/2007 03:05:51 p.m. *****
drop PROCEDURE ct_grabarcabcomprob_pro
*/
CREATE     PROCEDURE [ct_grabarcabcomprob_pro]
	(@base varchar(30),
     	@tabla varchar(30),
        @empresa varchar(2),
	 @op int, 
	 @cabcomprobmes 	int,
	 @cabcomprobnumero char(10),
     	 @asientocodigo 	char(3),
 	 @subasientocodigo 	char (4),
	 @cabcomprobfeccontable datetime=NULL,	 
	 @usuariocodigo 	usuariocodigo=NULL,
	 @estcomprobcodigo 	char(2)=NULL,
	 @cabcomprobobservaciones 	varchar(150)=NULL,
	 @fechaact 	datetime=NULL,
	 @cabcomprobglosa 	varchar(30)=NULL,
	 @cabcomprobtotdebe 	numvalor=NULL,
	 @cabcomprobtothaber 	numvalor=NULL,
	 @cabcomprobtotussdebe 	numvalor=NULL,
	 @cabcomprobtotusshaber numvalor=NULL,  
              @cabcomprobgrabada bit=NULL ,
              @cabcomprobnref varchar(30)=NULL,
              @cabcomprobnlibro varchar(10)=NULL )
AS 
DECLARE @sqlcad nvarchar(4000),@sqlparm nvarchar(1000)
--Pararametros de la cadena
SET @sqlparm='@empresa varchar(2),@cabcomprobmes int,@cabcomprobnumero char(10),@cabcomprobfeccontable datetime,'+
	     '@subasientocodigo char(4),@usuariocodigo usuariocodigo,@estcomprobcodigo char(2),'+
             '@asientocodigo char(3),@cabcomprobobservaciones varchar(150),@fechaact datetime,'+
	     '@cabcomprobglosa varchar(30),@cabcomprobtotdebe numvalor,@cabcomprobtothaber numvalor,'+
	     '@cabcomprobtotussdebe numvalor,@cabcomprobtotusshaber numvalor, @cabcomprobgrabada bit,@cabcomprobnref varchar(30),@cabcomprobnlibro varchar(10) '
IF @op=1 --Insertar Datos
BEGIN
	SET @sqlcad=''+
    'INSERT INTO '+'['+@base+'].[dbo].['+@tabla+']
	 (empresacodigo,
	  cabcomprobmes,
	  cabcomprobnumero,
	  cabcomprobfeccontable,
	  subasientocodigo,
	  [usuariocodigo],
	  estcomprobcodigo,
	  asientocodigo,
	  cabcomprobobservaciones,
	  [fechaact],
	  cabcomprobglosa,
	  cabcomprobtotdebe,
	  cabcomprobtothaber,
	  cabcomprobtotussdebe,
	  cabcomprobtotusshaber,cabcomprobgrabada,cabcomprobnref,cabcomprobnlibro)  
  VALUES 
	(@empresa,
	 @cabcomprobmes,
	 @cabcomprobnumero,
	 @cabcomprobfeccontable,
	 @subasientocodigo,
	 @usuariocodigo,
	 @estcomprobcodigo,
	 @asientocodigo,
	 @cabcomprobobservaciones,
	 @fechaact,
	 @cabcomprobglosa,
	 @cabcomprobtotdebe,
	 @cabcomprobtothaber,
	 @cabcomprobtotussdebe,
	 @cabcomprobtotusshaber,@cabcomprobgrabada,@cabcomprobnref,@cabcomprobnlibro)'
END
IF @op=2 --Actualizar
BEGIN
	SET @sqlcad=''+
  	'UPDATE '+'['+@base+'].[dbo].['+@tabla+']'+	
    'SET cabcomprobmes=@cabcomprobmes,
	 	 cabcomprobnumero= @cabcomprobnumero,
	 	 cabcomprobfeccontable=@cabcomprobfeccontable,
	 	 subasientocodigo=@subasientocodigo,
	 	 [usuariocodigo]=@usuariocodigo,
	 	 estcomprobcodigo=@estcomprobcodigo,
	 	 asientocodigo=@asientocodigo,
	  	 cabcomprobobservaciones=@cabcomprobobservaciones,
	 	 [fechaact]	 = @fechaact,
	 	 cabcomprobglosa = @cabcomprobglosa,
	 	 cabcomprobtotdebe = @cabcomprobtotdebe,
	 	 cabcomprobtothaber	 = @cabcomprobtothaber,
	 	 cabcomprobtotussdebe	= @cabcomprobtotussdebe,
	 	 cabcomprobtotusshaber	 = @cabcomprobtotusshaber, 
                            cabcomprobgrabada=@cabcomprobgrabada,
                            cabcomprobnref=@cabcomprobnref
WHERE 
	( empresacodigo		 = @empresa and 
	  cabcomprobmes		 = @cabcomprobmes AND
	  cabcomprobnumero	 = @cabcomprobnumero AND
	  subasientocodigo	 = @subasientocodigo AND
	  asientocodigo	 = @asientocodigo)'
END
IF @op=3 --Eliminar
BEGIN
       SET @sqlcad=''+
  	'DELETE FROM  '+'['+@base+'].[dbo].['+@tabla+'] '+  	
             '  WHERE 
	( empresacodigo		  =@empresa and 
	  cabcomprobmes		 = @cabcomprobmes AND
	  cabcomprobnumero	 = @cabcomprobnumero AND
	  subasientocodigo	 = @subasientocodigo AND
	  asientocodigo	 = @asientocodigo)'
END
Exec sp_executesql @sqlcad,@sqlparm,    @empresa,
					@cabcomprobmes,
					@cabcomprobnumero,
					@cabcomprobfeccontable,
	 				@subasientocodigo,
	 				@usuariocodigo,
	 				@estcomprobcodigo,
	 				@asientocodigo,
	 				@cabcomprobobservaciones,
	 				@fechaact,
	 				@cabcomprobglosa,
	 				@cabcomprobtotdebe,
	 				@cabcomprobtothaber,
	 				@cabcomprobtotussdebe,
	 				@cabcomprobtotusshaber,@cabcomprobgrabada,@cabcomprobnref,@cabcomprobnlibro
GO
