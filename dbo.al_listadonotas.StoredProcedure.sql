SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE           procedure [al_listadonotas]
@base varchar(50),
@base2 varchar(50),
@almacen varchar(2),
@tipo varchar(2),
@numero varchar(11),
@cabecera varchar(40),
@detalle varchar(40)
as
Declare @ncadena nvarchar(3000)
Declare @nparame nvarchar(2000)
--exec al_listadonotas 'etextil0001','empresas',15,'S','03-00012','quimicopartes_06_2003','quimicopartesitems_06_2003'
--ojo  solo es para ingreso  tienes q  hacer condicion para salidas...(a.quimicocantidads)
if @tipo='I' 
    begin 
	set @ncadena=N'SELECT b.quimicoid,partefecha,A.almacenid,
             		          	a.quimicocantidadi as kilos,B.quimicodescripcion as descripcion,
                       		  c.cod_orden as orden,c.ordencompraid,c.facturanro,c.guianro,c.importacion
	     		FROM ['+@base+'].dbo.'+@detalle+' A
			INNER JOIN ['+@base2+'].dbo.[maestro quimicos] B
			ON a.quimicoid = b.quimicoid
	 		INNER JOIN ['+@base+'].dbo.'+@cabecera+' C 
             			 ON A.almacenid=C.almacenid AND A.operaciontipo=C.operaciontipo AND DENUMDOC=CANUMDOC 
			       Where A.almacenid=''' +@ALMACEN+''' AND A.operaciontipo=''' +@TIPO+ '''   AND DENUMDOC=''' +@NUMERO+'''
	               ORDER BY b.quimicoid '
    end
else
    begin 
	set @ncadena=N'SELECT b.quimicoid,partefecha,A.almacenid,
             		          	a.quimicocantidads as kilos,B.quimicodescripcion as descripcion,
                       		c.cod_orden as orden,c.ordencompraid,c.facturanro,c.guianro,c.importacion
	     		FROM ['+@base+'].dbo.'+@detalle+' A
			INNER JOIN ['+@base2+'].dbo.[maestro quimicos] B
			ON a.quimicoid = b.quimicoid
	 		INNER JOIN ['+@base+'].dbo.'+@cabecera+' C 
             			 ON A.almacenid=C.almacenid AND A.operaciontipo=C.operaciontipo AND DENUMDOC=CANUMDOC 
			       Where A.almacenid=''' +@ALMACEN+''' AND A.operaciontipo=''' +@TIPO+ '''   AND DENUMDOC=''' +@NUMERO+'''
	               ORDER BY b.quimicoid '
    end
Exec(@ncadena)
--return
GO
