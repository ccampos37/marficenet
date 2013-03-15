SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [TipoDoc](@tipo char(1),@importe float) 
RETURNS float
AS
BEGIN
DECLARE @monto float
SET @monto =
   CASE @tipo
	WHEN 'A' THEN @importe*-1
   	WHEN 'C' THEN @importe
   	ELSE @importe
   END
RETURN @monto
END
GO
