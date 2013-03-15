SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc al_cierremensual_pro

select *  from kardex_ziyaz.dbo.al_movresmes

exec al_cierremensualEmpresa_pro 'kardex_ziyaz','02','201001','201002' 

select * from pacific.dbo.moresmes Where smmespro='200601' and smalma='01'
update pacific.dbo.movalmcab set cacierre=0
*/
CREATE  procedure [al_cierremensualEmpresa_pro]
@base varchar(20),
@Empresa varchar(2),
@mesactual varchar(6),
@mesnuevo varchar(6)
as
Declare @cadena nvarchar(4000)
Declare @parame nvarchar(4000)
Set @cadena=N'Update ['+@base+'].dbo.al_movresmes
                      Set smactcan =isnull(smsaldoini,0)+isnull(smcanent,0)-isnull(smcansal,0),
                          smmnactval=isnull(SMMNvalI,0)+isnull(smmnent,0)-isnull(smmnsal,0)
	              Where  empresacodigo='''+@empresa+''' and smmespro='''+@mesactual+''' 
              insert into ['+@base+'].dbo.al_movresmes (smmespro,empresacodigo,smcodigo,smsaldoini,SMMNvalI )
                    select '''+@mesnuevo+''',empresacodigo,smcodigo,smactcan,smmnactval from ['+@base+'].dbo.al_movresmes
                     Where empresacodigo='''+@empresa+'''  and smmespro='''+@mesactual+'''  
                     and empresacodigo+smcodigo not in ( select empresacodigo+smcodigo from ['+@base+'].dbo.al_movresmes
                                                  where empresacodigo='''+@empresa+''') and smmespro='''+@mesnuevo+'''   
		update ['+@base+'].dbo.al_movresmes  set SMSALDOINI=b.smactcan, SMMNvalI=b.smmnactval
                      from ['+@base+'].dbo.al_movresmes a, (select empresacodigo,smcodigo,smactcan,smmnactval from ['+@base+'].dbo.al_movresmes
                                                  Where empresacodigo='''+@empresa+''' and smmespro='''+@mesactual+'''  ) as b
                     where a.empresacodigo+a.smcodigo = b.empresacodigo+b.smcodigo and a.smmespro='''+@mesnuevo+'''' 
execute(@cadena)
GO
