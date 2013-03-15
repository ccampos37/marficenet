SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [al_actualizaproducto_pro]
@baseini varchar(50),
@basefin varchar(50),
@almacen varchar(2),
@articulo varchar(20),
@tipo varchar(1)
--@valor float
as
Declare @cadena nvarchar(3000)
Declare @parame nvarchar(3000)
Declare @valor char(1)
Declare @dato char(2)
Declare @ref char(1)
Declare @usua varchar(8)
Declare @fecha datetime
set @valor='0'
set @dato=@almacen      --'01'
set @ref='REF'
set @usua='elozano'
set @fecha=getdate()
if @tipo='1' 
	Begin	
		set @cadena='Delete From ['+@basefin+'].dbo.vt_producto where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen
		set @cadena='Delete From ['+@basefin+'].dbo.listapre1 where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen

		Set @cadena='INSERT INTO ['+@basefin+'].dbo.VT_PRODUCTO
					(	productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						USUARIOCODIGO,
						FECHAACT,
						almacencodigo
					)
					SELECT DISTINCT
						ACODIGO as productocodigo,
						ADESCRI as productodescripcion,
						left(ADESCRI,30) as productodescrcorta,
						AGRUPO as grupovtacodigo,
						AFAMILIA as productofamiliacodigo,
						@VALOR as productocategoriacodigo,
						ATIPO as productotipo,
						AUNIDAD as unidadcodigo,
						@VALOR as productoporcimpto,
						@VALOR as productoestunidreferencia,
						@REF as unidadreferencial,
						@VALOR as unidadfactorconv,
						APRECIO,
						CASE ACODMON WHEN ''MN'' THEN ''01'' ELSE ''02'' END  as monedacodigo,
						@USUA as usuariocodigo,
						@fecha as fechaact,
						@DATO as almacencodigo
		  			From 
				                ['+@baseini+'].DBO.MAEART 
					Where acodigo =@articulo'
--@VALOR AS productoprecvta CAMBIADO EN VEZ DE APRECIO EN EL SELECT DISTINC DEL MAEART AARIBA
		set @parame=N'@cadena nvarchar(2000),
			      @parame nvarchar(1000),
			      @valor char(1),
			      @dato char(2),
			      @ref char(1),
			      @usua varchar(8),
			      @fecha datetime,
		  	      @almacen varchar(2),		
			      @articulo varchar(20)'
		
		execute sp_executesql @cadena,@parame,@cadena,
						      @parame,
						      @valor,
						      @dato,
					              @ref,
						      @usua,
						      @fecha,
						      @almacen,
						      @articulo	 

		Set @cadena='INSERT INTO ['+@basefin+'].dbo.LISTAPRE1
					(	productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						almacencodigo
					)
					SELECT 
						productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						almacencodigo
					 FROM ['+@basefin+'].DBO.VT_PRODUCTO
					 Where productocodigo=@articulo and almacencodigo=@almacen'
		
		
		set @parame=N'@cadena nvarchar(2000),
			      @parame nvarchar(1000),
			      @valor char(1),
			      @dato char(2),
			      @ref char(1),
			      @usua varchar(8),
			      @fecha datetime,
		  	      @almacen varchar(2),		
			      @articulo varchar(20)'
		
		execute sp_executesql @cadena,@parame,@cadena,
						      @parame,
						      @valor,
						      @dato,
					              @ref,
						      @usua,
						      @fecha,
						      @almacen,
						      @articulo	 
		
	end

if @tipo='2'     --Actualizar articulo
	Begin
		set @cadena='Delete From ['+@basefin+'].dbo.vt_producto where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen
		set @cadena='Delete From ['+@basefin+'].dbo.listapre1 where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen
		Set @cadena='INSERT INTO ['+@basefin+'].dbo.VT_PRODUCTO
					(	productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						USUARIOCODIGO,
						FECHAACT,
						almacencodigo
					)
					SELECT DISTINCT
						ACODIGO as productocodigo,
						ADESCRI as productodescripcion,
						left(ADESCRI,30) as productodescrcorta,
						AGRUPO as grupovtacodigo,
						AFAMILIA as productofamiliacodigo,
						@VALOR as productocategoriacodigo,
						ATIPO as productotipo,
						AUNIDAD as unidadcodigo,
						@VALOR as productoporcimpto,
						@VALOR as productoestunidreferencia,
						@REF as unidadreferencial,
						@VALOR as unidadfactorconv,
						@VALOR AS productoprecvta,
						CASE ACODMON WHEN ''MN'' THEN ''01'' ELSE ''02'' END  as monedacodigo,
						@USUA as usuariocodigo,
						@fecha as fechaact,
						@DATO as almacencodigo
		  			From 
				                ['+@baseini+'].DBO.MAEART 
					Where acodigo =@articulo'
		
		set @parame=N'@cadena nvarchar(2000),
			      @parame nvarchar(1000),
			      @valor char(1),
			      @dato char(2),
			      @ref char(1),
			      @usua varchar(8),
			      @fecha datetime,
		  	      @almacen varchar(2),		
			      @articulo varchar(20)'
		
		execute sp_executesql @cadena,@parame,@cadena,
						      @parame,
						      @valor,
						      @dato,
					              @ref,
						      @usua,
						      @fecha,
						      @almacen,
						      @articulo	 
		
		
		Set @cadena='INSERT INTO ['+@basefin+'].dbo.LISTAPRE1
					(	productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						almacencodigo
					)
					SELECT 
						productocodigo,
						productodescripcion,
						productodescrcorta,
						grupovtacodigo,
						productofamiliacodigo,
						productocategoriacodigo,
						productotipo,
						unidadcodigo,
						productoporcimpto,
						productoestunidreferencia,
						unidadreferencial,
						unidadfactorconv,
						productoprecvta,
						monedacodigo,
						almacencodigo
					 FROM ['+@basefin+'].DBO.VT_PRODUCTO
					 Where productocodigo=@articulo and almacencodigo=@almacen'
		
		
		set @parame=N'@cadena nvarchar(2000),
			      @parame nvarchar(1000),
			      @valor char(1),
			      @dato char(2),
			      @ref char(1),
			      @usua varchar(8),
			      @fecha datetime,
		  	      @almacen varchar(2),		
			      @articulo varchar(20)'
		
		execute sp_executesql @cadena,@parame,@cadena,
						      @parame,
						      @valor,
						      @dato,
					              @ref,
						      @usua,
						      @fecha,
						      @almacen,
						      @articulo	 
	End
if @tipo='3'   --Eliminar Articulo
	Begin
		set @cadena='Delete From ['+@basefin+'].dbo.vt_producto where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen
		set @cadena='Delete From ['+@basefin+'].dbo.listapre1 where productocodigo=@articulo and almacencodigo=@almacen'
		set @parame=N'@articulo varchar(20),@almacen varchar(2)'
		execute sp_executesql @cadena,@parame,@articulo,@almacen
	End
GO
