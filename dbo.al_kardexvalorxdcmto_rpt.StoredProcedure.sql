SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [al_kardexvalorxdcmto_rpt]
@base varchar(50),
@tipo varchar(1)
as
declare @cadena as nvarchar(1000)
if @tipo='T'
	begin
		set @cadena='
			select COD_ART, DESCRIPCION, FEC_DOC, HOR_DOC, COD_MOV, 
					 TIP_TRANSA, DES_TRANSA, NUM_DOC, CAN_ART, PRE_UNIT, 
					 COS_PRO, SAL_STOCK, SER_LOT, ING_SAL
			from ['+@base+'].dbo.al_Kardex_Val '
	end
if @tipo<>'T'
	begin
		set @cadena='
			select COD_ART, DESCRIPCION, FEC_DOC, HOR_DOC, COD_MOV, 
					 TIP_TRANSA, DES_TRANSA, NUM_DOC, CAN_ART, PRE_UNIT, 
					 COS_PRO, SAL_STOCK, SER_LOT, ING_SAL
			from ['+@base+'].dbo.al_Kardex_Val 
			where ING_SAL = '''+@tipo+''' '
	end
     
execute(@cadena)
GO
