SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- drop proc al_listaproveedor_rep
CREATE   procedure [al_listaproveedor_rep]
@base as varchar(50)
as
declare @cadena as nvarchar(1000)
---declare @c as varchar(2)
---set @c='62'
set @cadena='Select A.PRVCCODIGO,A.PRVCNOMBRE,A.PRVCDIRECC,
              A.PRVCTELEF1,a.prvcruc 
             From ['+@base+'].dbo.MAEPROV A   
             '
execute(@cadena)
GO
