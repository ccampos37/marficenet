SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [tj_repordenpendiente_pro]
@base varchar(50),
@base2 varchar(50)
--@fechaini varchar(10),
---@fechafin varchar(10)
as
Declare @ncade as nvarchar(2000)
Declare @npara as nvarchar(2000)
Set @ncade=N'SELECT a.CLIENTECODIGO,Clienterazonsocial,
							       a.tjordenum,a.cabordfecdoc,a.cabordfecentrega,
									a.cabordnrorecep,
									b.acodigo,c.adescri,b.detordkgs,b.detsaldo	
							FROM ['+@base+'].dbo.TJ_CABECERAORDEN A
							INNER JOIN ['+@base+'].dbo.TJ_DETALLEORDEN B
								ON A.tjordenum=B.tjordenum
							LEFT JOIN ['+@base2+'].dbo.maeart C
								ON c.acodigo=b.acodigo COLLATE Modern_Spanish_CI_AS
							LEFT JOIN ['+@base2+'].dbo.vt_cliente d
								ON d.clientecodigo=a.clientecodigo COLLATE Modern_Spanish_CI_AS
							WHERE b.detsaldo>0'
--							WHERE a.cabordfecdoc>=@fechaini and a.cabordfecdoc<=@fechafin and b.detsaldo>0'
--set @npara=N'@fechaini varchar(10),@fechafin varchar(10)'
						
execute sp_executesql @ncade,@npara
--execute sp_executesql @ncade,@npara,@fechaini,@fechafin
GO
