SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE           PROC [vt_ingresodetallealma_pro]
@base varchar(50),
@tabla varchar(50),
@tipo char(1),
@item char(3),
@numero char(11),
@producto varchar(20),
@unidad varchar(5),
@cantidad  float,
@preciopacto float,
@dsctoxitem float,
@importebruto float,
@porcomision float,
@mdsctoitem float,
@mdsctoxlinea float,
@mdsctoxprom float,
@mimpor float,
@unidadref float,
@almacen varchar(2),
@ordfab VARCHAR(10)=NULL,
@productoconversion varchar(20)=null,
@cantidad1 float=0,
@equipo varchar(11)='' 

AS

Declare @cadena nvarchar(1000)
Declare @parame nvarchar(1000)
Declare @valor varchar(2)
Declare @GS varchar(2)
set @valor=@almacen
if @tipo='1' 
  begin 
   set @gs='GS'
  end 
if @tipo='2'   --nota salida
  begin 
   set @gs='NS'
  end 
if @tipo='3'  --nota ingreso
  begin 
   set @gs='NI'
  end 
      Set @cadena='INSERT INTO ['+@base +'].dbo.'+@tabla+
		  '  (DETD,DEALMA,DEITEM,DENUMDOC,
			DECODIGO,DECANTID,DEPREVTA,DEDESCTO,
			DEVALTOT,DEPORDES,DECANTENT,DEORDFAB,
			DECANREF1,DECODREF,DECANREF,dequipo
			)
		VALUES(
			@GS,@valor,@item,@numero,
			@producto,@cantidad,@preciopacto,@dsctoxitem,
			@importebruto,@mdsctoitem,@cantidad,@ordfab,
			@unidadref,@productoconversion,@cantidad1, @equipo )'

	Set @parame=N'@item char(3),@numero char(11),@producto varchar(20),@unidad varchar(5),
		@cantidad  float,@preciopacto float,@dsctoxitem float,@importebruto float,
		@porcomision float,@mdsctoitem float,@mdsctoxlinea float,@mdsctoxprom float,
		@mimpor float,@unidadref float,@valor varchar(2),@ordfab varchar(10),
		@GS varchar(2),@productoconversion varchar(20),@cantidad1 float , @equipo varchar(11) '
       execute sp_executesql @cadena,@parame,@item,
						@numero,
						@producto,
						@unidad,
						@cantidad,
						@preciopacto,
						@dsctoxitem,
						@importebruto,
						@porcomision,
						@mdsctoitem,
						@mdsctoxlinea,
						@mdsctoxprom,
						@mimpor,
						@unidadref,
						@valor,
						@ordfab,
						@gs,@productoconversion,@cantidad1, @equipo
GO
