SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [ser_listaservicio_rep]
@base varchar(50),
@base2 varchar(50),
@provee varchar(15),
@fini varchar(10),
@ffin varchar(10),
@empresa varchar(2)
as
declare @ncade nvarchar(1000)
declare @npara nvarchar(1000)
set @ncade=N'select servicio_fecha,c.prvccodigo,c.prvcnombre,servicio_orden,servicio_tiporefe,servicio_nrorefe,
			 servicio_moneda,servicio_total,servicio_pagado From ['+@base+'].dbo.control_servicio b
			 inner join ['+@base2+'].dbo.maeprov C
			 on  b.servicio_proveedor=c.prvccodigo COLLATE Modern_Spanish_CI_AI 
			 where 	empresa_codigo like @empresa and servicio_proveedor like @provee and servicio_fecha>=@fini and servicio_fecha<=@ffin' 
Set @npara=N'@provee varchar(15),@fini varchar(10),	@ffin varchar(10),@empresa varchar(2)'
execute sp_executesql @ncade,@npara,@provee,@fini,@ffin,@empresa
GO
