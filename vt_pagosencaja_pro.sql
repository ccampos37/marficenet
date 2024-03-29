SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROC [vt_pagosencaja_pro]

@base varchar(50),
@tipo char(1),
@empresa varchar(2),
@pedidonumero varchar(15),
@pagocodigo  char(2),
@pagotipocodigo  char(2),
@numdoc varchar(20),
@moneda	char(2),
@importe float ,
@tipocambio float

As
Declare @cadena as nvarchar(4000)
Declare @parame as nvarchar(4000)
if @tipo='1' 
   Begin
    	SET @cadena =N'Insert Into ['+@base +'].dbo.vt_pagosencaja
               (empresacodigo,pedidonumero,pagocodigo,pagotipocodigo,pagonumdoc,monedacodigo,pagoimporte,
                pagotipodecambio)
                VALUES (@empresa, @pedidonumero,@pagocodigo,@pagotipocodigo,@numdoc,@moneda,@importe,
                @tipocambio)'

	     SET @Parame = N'@empresa char(2),@pedidonumero varchar(15),@pagocodigo  char(2),@pagotipocodigo char(2),
			        @numdoc 	varchar(20),@moneda	char(2),@importe float,@tipocambio	float '

	     EXEC sp_executesql @cadena,@parame,
               @empresa, @pedidonumero,@pagocodigo,@pagotipocodigo,@numdoc,@moneda,@importe,@tipocambio
	end 















