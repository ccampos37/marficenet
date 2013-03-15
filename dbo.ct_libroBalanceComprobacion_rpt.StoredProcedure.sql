SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute ct_BalanceComprobacion_rpt 'ziyaz','02','2010',12,4,0,' Left(Cuenta,2) Asc,Nivel Desc ',1,'0'
*/
create   Proc [ct_libroBalanceComprobacion_rpt]
(
@Base 		varchar(50),
@empresa 	varchar(2),
@Anno 		varchar(4),
@Mes 		int,
@Nivel 		int,
@NoEnCascada 	int,
@Corden 	Varchar(500),
@opvista 	int,  
@long 		varchar(2)=0,   
@xcuenta 	varchar(50)='',
@sistemamonista varchar(1)='0'
)
as 
 
DECLARE @sqlcad varchar(8000),
	@sqlcad1 varchar(8000),
        @sqlcad2 varchar(8000),		
        @sqlcad3 varchar(8000),		
	@sqlcad4 varchar(8000),
        @pcuent varchar(50),
        @mes1  varchar(2),   
        @pos2 int,@cad varchar(50),
	@i int

set @sqlcad='declare @sistemamonista int
Set @sistemamonista=(select top 1 sistemamonista from '+@base+'.dbo.ct_sistema )'
execute(@sqlcad)    

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
set @sqlcad4=''
set @i=1
WHILE 1=1
Begin		
	Set @pos2=CHARINDEX('*',@pcuent)
	If @pos2=0 --Cuando se llega al ultimo nivel
	Begin
		If @NoEnCascada <>1 
			Set @sqlcad=@sqlcad+dbo.fn_cadBalance(@Base,@empresa,@anno,@Mes,@pcuent,@i)
                  Else
                  
			Set @sqlcad=dbo.fn_cadBalance(@Base,@empresa,@anno,@Mes,@pcuent,@Nivel)			
		If @NoEnCascada <>1 
			Set @sqlcad4=@sqlcad4+dbo.fn_cadgastos(@Base,@empresa,@anno,@Mes,@pcuent,@i)
                  Else
		        Set @sqlcad4=dbo.fn_cadgastos(@Base,@empresa,@anno,@Mes,@pcuent,@Nivel)
                 BREAK

	End	
    Set @cad=substring(@pcuent,1,@pos2-1)		
	If @NoEnCascada <>1 
	Begin
		Set @sqlcad=@sqlcad+dbo.fn_cadBalance(@Base,@empresa,@anno,@Mes,@cad,@i)	        
		Set @sqlcad4=@sqlcad4+dbo.fn_cadgastos(@Base,@empresa,@anno,@Mes,@cad,@i)	        
    	        If @i <> @Nivel 
                   begin
                      SET @sqlcad=@sqlcad+CHAR(13)+'UNION ALL'+CHAR(13)  	
                      SET @sqlcad4=@sqlcad4+CHAR(13)+'UNION ALL'+CHAR(13)  	
                   end
	End
		
	If @i=@Nivel 
	Begin	
		If @NoEnCascada =1 
			Set @sqlcad=dbo.fn_cadBalance(@Base,@empresa,@anno,@Mes,@cad,@Nivel)
			Set @sqlcad4=dbo.fn_cadgastos(@Base,@empresa,@anno,@Mes,@cad,@Nivel)
		BREAK
	End
	Set @pcuent=right(@pcuent,len(@pcuent)- (len(@cad)+1))	   	
	set @i=@i+1
End

Set @sqlCad1=' Select c.cuentadescripcion,C.tipocuentacodigo, xx.*,'+CHAR(13)+
       dbo.fn_CalcCadBalance()+CHAR(13)+
       ' into .dbo.##tmpxx From ('
Set @sqlcad=@sqlcad+
       ') as xx,['+@Base+'].dbo.ct_cuenta C '+CHAR(13)+		
			'Where xx.empresacodigo=c.empresacodigo and xx.cuenta=c.cuentacodigo and c.empresacodigo='''+@empresa+''''+
			case when @long<>0 then 
	            ' and (left(xx.cuenta,'+@long+') like '''+@xcuenta+''') '
               Else ' ' end +
            case when @opvista=0 then ' ' else ' and 'end + 
             dbo.fn_WhereCadBalMovi(@opvista)+CHAR(13)+  
            'Order By '+@Corden +CHAR(13)
set @sqlcad2 =' update ##tmpxx 
set FunPerdiSol= FunPerdiSol + case when (h.saldodebe'+@mes1+'-h.saldohaber'+@mes1+')< 0 then
                                 0 else abs(h.saldodebe'+@mes1+'-h.saldohaber'+@mes1+') end , 
    FunGanaSol= FunGanaSol +  case when (h.saldodebe'+@mes1+'-h.saldohaber'+@mes1+') <= 0 then 
                                abs(h.saldodebe'+@mes1+'-h.saldohaber'+@mes1+') else 0 end, 
    FunPerdiSolAC=FunPerdiSolAC + case when h.saldoacumdebe'+@mes1+'-h.saldoacumhaber'+@mes1+' < 0 then
                                 0 else abs(h.saldoacumdebe'+@mes1+'-h.saldoacumhaber'+@mes1+') end,
    FunGanaSolAC=FunGanaSolAC + case when (h.saldoacumdebe'+@mes1+'-h.saldoacumhaber'+@mes1+') <= 0 then
                                abs(h.saldoacumdebe'+@mes1+'-h.saldoacumhaber'+@mes1+') else 0 end 
    from ['+@Base+'].dbo.ct_saldos'+@anno+' h inner join ##tmpxx xx
     on xx.cuenta=left(h.cuentacodigo,2) and h.cuentacodigo=''799100'' '+CHAR(13)
set @sqlcad3 =' select * from  ##tmpxx xx '
EXECUTE (@sqlCad1+@sqlcad+@sqlcad2)
--execute (@sqlCad1+@sqlcad)

--print(@sqlcad4)

If @sistemamonista='0' 
   begin
      Set @sqlcad= ' Update ##tmpxx set funperdisolac =b.saldoact, funperdisol=b.saldoact
             from  ##tmpxx a,('+@sqlcad4+') b 
             where a.cuenta=b.cuenta '
      execute(@sqlcad)
   end
execute (@sqlcad3)
--execute ct_BalanceComprobacion_rpt 'frontier','2007',1,'1','1',' Left(Cuenta,2) Asc,Nivel Desc ',0
GO
