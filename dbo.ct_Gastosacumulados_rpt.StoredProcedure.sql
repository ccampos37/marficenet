SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute ct_Gastosacumulados_rpt 'planta_casma','01','2008',3,'1','1',' Left(Cuenta,2) Asc,Nivel Desc ',0
*/
/* 
drop proc ct_Gastosacumulados_rpt
 */
CREATE       Proc [ct_Gastosacumulados_rpt]
(
@Base varchar(50),
@empresa varchar (2),
@Anno varchar(4),
@Mes int,
@Nivel int,
@NoEnCascada int,
@Corden Varchar(500),
@opvista int,  
@long varchar(2)=0,   
@xcuenta varchar(50)=''
)
as 
 
DECLARE @sqlcad varchar(8000),
	@sqlcad1 varchar(8000),
        @sqlcad3 varchar(8000),		
        @pcuent varchar(50),
        @mes1  varchar(2),   
        @pos2 int,@cad varchar(50),@i int      
/*Capturando parametro de cuenta*/
SET @mes1=replicate('0',2-len(@mes))+ rtrim(cast(@mes as varchar(2)))
set @pcuent=''
Exec('Declare Curpcuenta cursor for  
      Select top 1 sistemaconfiguracuenta from ['+@Base+'].dbo.ct_sistema ')
open Curpcuenta
Fetch Next from Curpcuenta into @pcuent
Close Curpcuenta
Deallocate Curpcuenta
/*Fin de Captura de Parametro*/
Set @sqlcad='
If Exists(Select name from tempdb..sysobjects where name=''##tmpxx'') 
    Drop Table [##tmpxx]'
execute(@sqlcad) 
Set @sqlcad=''
set @i=1
WHILE 1=1
Begin		
	Set @pos2=CHARINDEX('*',@pcuent)
	If @pos2=0 --Cuando se llega al ultimo nivel
	Begin
		If @NoEnCascada <>1 
			Set @sqlcad=@sqlcad+dbo.fn_getcad_gastos(@Mes,1)
		Else
			Set @sqlcad=dbo.fn_getcad(@Mes,1)			
		BREAK
	End	
	Set @pcuent=right(@pcuent,len(@pcuent)- (len(@cad)+1))	   	
	set @i=@i+1
End
Set @sqlCad1=' Select c.cuentadescripcion,C.tipocuentacodigo, '+CHAR(13)+
       @sqlcad+CHAR(13)+ ' From '+@base+'.dbo.ct_gastos2008 
               where empresacodigo='''+@empresa+''''

print(@sqlcad1)
GO
