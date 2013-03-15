SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXECUTE [te_detallepagosinternet_pro] 'PLANTA_CASMA','1','03','333333','11111','01','222222',1,1,'01','01'

*/

CREATE PROCEDURE [te_detallepagosinternet_pro]
@BASE nvarchar(50),
@tipo char(1),
@empresa char(2),
@numero char(6),
@cliente nvarchar(11),
@tipodoc char(2),
@numerodoc nvarchar(14),
@importedoc float,
@importepago float,
@monedadoc char(2),
@monedapago char(2),
@proveedorruc char(11),
@cuentatipo char(1),
@ctacteproveedor varchar(20)

 
AS

declare @CADENA AS nvarchar(4000)
declare @parame as nvarchar(4000)

	SET @cadena =N' Insert Into '+@base +'.dbo.te_detallepagosinternet
                ([empresacodigo],
				[pagosnumero],
				[clientecodigo],
				cargodocumento,
				cargonumdoc,
				[importedocumento],
				importecancela,
				[monedadocumento],
				[monedacancela],
                proveedorruc,
                pagostipocuenta,
				ctacteproveedor )

      VALUES ( @empresa,
				@numero,
				@cliente,
				@tipodoc,
				@numerodoc,
				@importedoc,
				@importepago,
				@monedadoc,
				@monedapago,
				@proveedorruc,
				@cuentatipo,
				@ctacteproveedor) '

	SET @Parame =N'@empresa char(2),
				@numero char(6),
				@cliente nvarchar(11),
				@tipodoc char(2),
				@numerodoc nvarchar(14),
				@importedoc float, 
				@importepago float, 
				@monedadoc char(2),
				@monedapago char(2),
				@proveedorruc char(11),
				@cuentatipo char(1),
				@ctacteproveedor varchar(20)
 '

	EXEC sp_executesql @cadena,@parame,@empresa,
				@numero,
				@cliente,
				@tipodoc,
				@numerodoc,
				@importedoc,
				@importepago,
				@monedadoc,
				@monedapago,
				@proveedorruc,
				@cuentatipo,
				@ctacteproveedor
GO
