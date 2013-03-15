SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       procedure [vt_impresionletras_rpt]
@base as varchar(50),
@modovta as varchar(2),
@docnum as varchar(15),
@empresacodigo as varchar(2)
--@tipo as varchar(1)
--@filtro as varchar(100)
as
declare @cadena as nvarchar(2000)
declare @cadena2 as nvarchar(500)
--set @cadena2 = ' Order by Adescri'
--if @tipo='1' 
--   Begin
--        set @cadena2 = ' Order by Acodigo'  
--   End
--
SET @cadena =N'Select a.empresacodigo,a.modovtacodigo,a.pedidonrofact,a.pedidototneto, a.puntovtacodigo,b.puntovtadescripcion 
	From ['+@base+'].dbo.vt_pedido a  Inner Join ['+@base+'].dbo.vt_puntoventa b On a.puntovtacodigo=b.puntovtacodigo
	Where a.empresacodigo='''+@empresacodigo+''' And modovtacodigo='''+@modovta+''' And pedidonrofact='''+@docnum+''' '
--print(@cadena)
execute(@cadena)
-- EXEC vt_impresionletras_rpt 'gremco','FA','01300009200','12'
GO
