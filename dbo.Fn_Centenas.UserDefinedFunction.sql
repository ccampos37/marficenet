SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Función para centenas 
--Función que devuelve en letra las centenas. El párametro @Estilo permite identificar los distintos valores que puede tener un mismo número. 
--Figura 4. 
--CREATE FUNCTION F_Centenas(@Numero as bigint, @Estilo as bit=0) 
CREATE FUNCTION [Fn_Centenas](@Numero as bigint, @Estilo as bit=0) 
RETURNS varchar(500) AS 
BEGIN 
DECLARE @Texto varchar(500)
SELECT @Texto=''
SELECT @Texto=
CASE 
WHEN @Numero=000 THEN ' '
WHEN @Numero=100 THEN 'CIEN'
WHEN @Numero>100 and @Numero<200 THEN 'CIENTO' + dbo.Fn_Decenas(RIGHT(CONVERT(varchar, @Numero), 2), 0)
WHEN (@Numero>=200 and @Numero<500) or (@Numero>599 and @Numero<1000) THEN 
     dbo.Fn_Decenas(LEFT(CONVERT(varchar, @Numero), 1), 1) +'CIENTOS ' +dbo.Fn_Decenas(RIGHT(CONVERT(varchar, @Numero), 2), 1)
WHEN @Numero>=500  and @Numero<=599  THEN 'QUINIENTOS '+dbo.Fn_Decenas(RIGHT(CONVERT(varchar, @Numero), 2), 1)
WHEN @Numero<10 THEN dbo.Fn_Unidades(@Numero, 0)
WHEN @Numero<100 THEN dbo.Fn_Decenas(@Numero, @Estilo)
END
RETURN @Texto
END
GO
