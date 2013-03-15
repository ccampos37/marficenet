SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc al_cierremensual_pro
exec al_cierremensual_pro 'pacific','01','200601','200602' 
select * from pacific.dbo.moresmes Where smmespro='200601' and smalma='01'
update pacific.dbo.movalmcab set cacierre=0
*/
CREATE  procedure [al_cierremensual_pro]
@base varchar(20),
@almacen varchar(2),
@mesactual varchar(6),
@mesnuevo varchar(6)
as
Declare @cadena nvarchar(4000)
Declare @parame nvarchar(4000)
Set @cadena=N'Update ['+@base+'].dbo.moresmes
                      Set smactcan =isnull(smantcan,0)+isnull(smcanent,0)-isnull(smcansal,0),
                          smmnactval=isnull(smmnantval,0)+isnull(smmnent,0)-isnull(smmnsal,0)
	              Where smmespro='''+@mesactual+''' and smalma='''+@almacen+'''
              insert into ['+@base+'].dbo.moresmes (smmespro,smalma,smcodigo,smantcan,smsaldoini )
                    select '''+@mesnuevo+''',smalma,smcodigo,smactcan,smmnactval from ['+@base+'].dbo.moresmes
                     Where smmespro='''+@mesactual+''' and smalma='''+@almacen+''' 
                     and smalma+smcodigo not in ( select smalma+smcodigo from ['+@base+'].dbo.moresmes
                                                  where smmespro='''+@mesnuevo+''') 
		update ['+@base+'].dbo.moresmes set smantcan=b.smactcan, smsaldoini=b.smmnactval
                      from ['+@base+'].dbo.moresmes a, (select smalma,smcodigo,smactcan,smmnactval from ['+@base+'].dbo.moresmes
                                                  Where smmespro='''+@mesactual+''' and smalma='''+@almacen+''' ) as b
                     where a.smalma+a.smcodigo = b.smalma+b.smcodigo and a.smmespro='''+@mesnuevo+'''' 
execute(@cadena)
GO
