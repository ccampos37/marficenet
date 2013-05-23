SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [v_analiticoentidad]
AS
SELECT     a.analiticocodigo, a.tipoanaliticocodigo, b.*,identidaddescripcion
FROM         dbo.ct_analitico a 
             INNER JOIN dbo.ct_entidad b ON a.entidadcodigo = b.entidadcodigo
             left join dbo.gr_identidad c on isnull(b.identidadcodigo,0)=c.identidadcodigo





GO


