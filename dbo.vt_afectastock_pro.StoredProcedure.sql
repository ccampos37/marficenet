SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [vt_afectastock_pro]
@baseini varchar(50),
@basefin varchar(50),
@numero  char(11),
@tipo float
as
Declare @cadena varchar(4000)
Declare @parame varchar(4000)
set nocount on
Set @cadena=N'select * into #tempo from ['+@baseini+'].dbo.vt_detallepedido where pedidonumero=@numero'
set @parame=N'@numero char(11)'
execute sp_executesql @cadena,@cadena,@numero
select * from #tempo
GO
