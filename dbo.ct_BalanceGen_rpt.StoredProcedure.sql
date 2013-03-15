SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
/* 
drop Proc ct_BalanceGen_rpt
 Primero colocarle el nivel a todas la cuentas que este de los parametros
 del balance de comprobacion

execute ct_balancegen_rpt 'campos2012','01','2012','01',2,'##xx','1'

*/

CREATE         Proc [ct_BalanceGen_rpt]
@Base varchar(50),
@empresa varchar(2),
@Ano  varchar(4),
@Mes  varchar(2),
@Nivel Varchar(2),
@Computer Varchar(50),
@modo char(1)='0'
as
If Exists(Select name from tempdb.dbo.sysobjects where name ='##tmp_balance'+@computer)
	Exec('Drop Table ##tmp_balance'+@computer)
Declare
@SqlCad Varchar(8000)
Set @SqlCad='
 Select  
     Linea=strucbalancelinea,
	 Dato1=strucbalancedato1,
     Descrip1=strucbalancedescrip1,
     Signo1=strucbalancesigno1,
     Formula1=Case When Upper(strucbalancedato1)=''R'' then strucbalancenivel1 Else '''' end, 
     Monto1=Isnull(Case When strucbalancedual =0 
                 			then case isnull(strucbalancesigno1,'''') 
                       				When ''+'' Then ABS(Saldo1)
                       				When ''-'' Then ABS(Saldo1)* -1 
                       				Else Saldo1 End          
                     	Else  abs(SaldoDHpos) end ,0),
     Err1=isnull(A.err1,0),
     Dato2=strucbalancedato2, 
     Descrip2=strucbalancedescrip2,
     Signo2=strucbalancesigno2,
     Formula2=Case When Upper(strucbalancedato2)=''R'' then strucbalancenivel2 Else '''' end,
     Monto2=Isnull(Case When strucbalancedual =0 
                 			then case isnull(strucbalancesigno2,'''') 
                      			When ''+'' Then ABS(Saldo2)
                      			When ''-'' Then ABS(Saldo2) * -1 
                     		        Else Saldo2 End         
            		Else  abs(SaldoDH)  end,0),
     Err2=isnull(b.err2,0) Into ##tmp_balance'+@computer+'
     From  ['+@base+'].dbo.ct_strucbalance S
     left join  
	 (Select Saldo1=sum((Case when Error=0 then Saldo else 0 end)),linea,Err1=sum((Case when Error=0 then 0 else 1 end))
			 from ( Select A.CuentaCodigo,
	         Saldo=saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+', 	       
	         linea=B.strucbalancelinea,                      
             Error=Case When strucbalanceinvval1 = 0 then 
                      Case When   
                           Not (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+' >=0)          
                           Then 1  
                           Else 0 end 
                 Else 0 End                     
	         from ['+@Base+'].dbo.ct_saldos'+@Ano+' A ,['+@Base+'].dbo.ct_strucbalance B
 	         Where empresacodigo='''+@empresa+''' and PATINDEX(''%*''+left(A.Cuentacodigo,'+@Nivel+')+''*%'',B.strucbalancenivel1) > 0 
                   and (saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+' >0 or 
                    (strucbalancedual=0 and saldoacumdebe'+@Mes+'-saldoacumhaber'+@Mes+'<>0 ))) as XX
        Group by  linea
        ) A on  s.strucbalancelinea=a.linea 
	   left join 
       ( Select Saldo2=sum((Case when Error=0 then Saldo else 0 end)),         
                linea,Err2=sum((Case when Error=0 then 0 else 1 end))
				from ( Select A.CuentaCodigo,
	                 Saldo=case when strucbalanceinvval2 = 0 then 
                               saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+'
                            else saldoacumhaber'+@Mes+' - saldoacumdebe'+@Mes+' end , 	       
	           linea=B.strucbalancelinea,                      
               Error=Case When strucbalanceinvval2 = 0 then 
                      Case When   
                          (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+' >0)          
                           Then 1  
                           Else 0 end 
                 Else 0 End                     
	          from ['+@Base+'].dbo.ct_saldos'+@Ano+' A ,['+@Base+'].dbo.ct_strucbalance B
 	          Where empresacodigo='''+@empresa+''' and PATINDEX(''%*''+left(A.Cuentacodigo,'+@Nivel+')+''*%'',B.strucbalancenivel2) > 0 and 
                   B.strucbalancedual=0  and (saldoacumdebe'+@Mes+'+saldoacumhaber'+@Mes+')<>0 ) as XX
           Group by  linea
       ) B on s.strucbalancelinea=b.linea  
     left join         
     (Select 
		SaldoDH=sum(Saldoneg),         
        SaldoDHpos=sum(Saldopos),
        linea               
        from (
	    Select A.CuentaCodigo,
	           Saldoneg=Case when (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+') <0 then (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+') else 0 end  , 	       
               Saldopos=case when (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+') >0 then (saldoacumdebe'+@Mes+' - saldoacumhaber'+@Mes+') else 0 end,  	       
	           linea=B.strucbalancelinea                      
	    from ['+@Base+'].dbo.ct_saldos'+@Ano+' A ,['+@Base+'].dbo.ct_strucbalance B
 	    Where a.empresacodigo='''+@empresa+''' and PATINDEX(''%*''+left(A.Cuentacodigo,'+@Nivel+')+''*%'',B.strucbalancenivel2) > 0 and 
               B.strucbalancedual<>0  and 
               (saldoacumdebe'+@Mes+'+saldoacumhaber'+@Mes+')<>0 ) as XX
        Group by  linea
     ) as C	on s.strucbalancelinea=c.linea  '  
     
execute( @SqlCad)
if @modo='1'
begin
  exec ct_analitico_rpt @Base,@empresa,@Ano,'00',@Mes,'42%','%%','%','%%','%%','2','0','1'
--exec ct_analitico_rpt 'gremco','30','2008','00','10','1211','%%','%','%%','%%','2','0',0

  set @sqlcad=' update ##tmp_balance'+@computer+'
       set monto2=monto2 - isnull((select sum(ctacteanaliticohaber)-sum(ctacteanaliticodebe) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
                 where linea=5 

      update ##tmp_balance'+@computer+'
      set monto2=monto2 + isnull((select sum(ctacteanaliticohaber)-sum(ctacteanaliticodebe) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
      where linea=23 '
     execute(@sqlcad)

  exec ct_analitico_rpt @Base,@empresa,@Ano,'00',@Mes,'46%','%%','%','%%','%%','2','0','1'

  set @sqlcad=' update ##tmp_balance'+@computer+'
       set monto2=monto2 - isnull((select sum(ctacteanaliticohaber)-sum(ctacteanaliticodebe) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
                 where linea=7 

      update ##tmp_balance'+@computer+'
      set monto2=monto2 + isnull((select sum(ctacteanaliticohaber)-sum(ctacteanaliticodebe) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
      where linea=24 '
      execute(@sqlcad)

/*  exec ct_analitico_rpt @Base,@empresa,@Ano,'00',@Mes,'12%','%%','%','%%','%%','2','1','1'

  set @sqlcad=' update ##tmp_balance'+@computer+'
       set monto1=monto1 - isnull((select sum(ctacteanaliticodebe)-sum(ctacteanaliticohaber) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
                 where linea=3 

      update ##tmp_balance'+@computer+'
      set monto1=monto1 + isnull((select sum(ctacteanaliticodebe)-sum(ctacteanaliticohaber) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
      where linea=20 '
   execute(@sqlcad)
*/
  exec ct_analitico_rpt @Base,@empresa,@Ano,'00',@Mes,'16%','%%','%','%%','%%','2','0','1'

  set @sqlcad=' update ##tmp_balance'+@computer+'
       set monto1=monto1 - isnull((select sum(ctacteanaliticodebe)-sum(ctacteanaliticohaber) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
                 where linea=5 

      update ##tmp_balance'+@computer+'
      set monto1=monto1 + isnull((select sum(ctacteanaliticodebe)-sum(ctacteanaliticohaber) from ##ct_analitico'+@empresa+' a 
                 inner join ['+@Base+'].dbo.co_multiempresas b on a.entidadruc=b.empresaruc ),0)
      where linea=21 '
      execute(@sqlcad)
 

end

Declare @SqlCad2 Varchar(8000)
Declare @Linea int,
        @Dato1 Varchar(1),
		@Dato2 Varchar(1),            
        @monto1 numeric(20,2),
        @monto2 numeric(20,2),
        @Acum1  numeric(20,2),
		@Acum2  numeric(20,2),
		@FAcum1  numeric(20,2),
		@FAcum2  numeric(20,2)	
 
Set @Acum1=0
Set @Acum2=0 
Set @FAcum1=0
Set @FAcum2=0
Exec('
Declare balgen cursor
for select linea,dato1,monto1,dato2,monto2 
	from ##tmp_balance'+@computer)
Open balgen
Fetch next from balgen into @linea,@dato1,@monto1,@dato2,@monto2 
While @@Fetch_Status=0
Begin
	If @Dato1='M' Set @Acum1=@Acum1 + isnull(@monto1,0)
	If @Dato2='M' Set @Acum2=@Acum2 + isnull(@monto2,0)
	
	If @Dato1='T'
	Begin
		Set @FAcum1=@FAcum1 + isnull(@Acum1,0)		
		Set @SqlCad2='					
		Update ##tmp_balance'+@Computer+'  
			set monto1='+rtrim(Cast(@Acum1 as Varchar(30)))+'
		where current of balgen' /*linea='+Rtrim(Cast(@linea as varchar(3)))*/
		Exec(@SqlCad2)
		Set @Acum1=0
	End	
	If @Dato2='T'
	Begin
		Set @FAcum2=@FAcum2 + isnull(@Acum2,0)
		Set @SqlCad2='					
		Update ##tmp_balance'+@Computer+'  
			set monto2='+rtrim(Cast(@Acum2 as Varchar(30)))+' 
		where current of balgen' /*linea='+Rtrim(Cast(@linea as varchar(3)))*/
		Exec(@SqlCad2)
		Set @Acum2=0
	End	
    If @Dato1='F'
	Begin					
		Set @SqlCad2='
		Update ##tmp_balance'+@computer+'  
			set monto1='+rtrim(Cast(iSNULL(@FAcum1,0) as Varchar(30)))+'                 
		where current of balgen'
		Exec(@SqlCad2)
		Set @FAcum1=0		
	End	
	If @Dato2='F'
	Begin					
		Set @SqlCad2='
		Update ##tmp_balance'+@computer+'  
			set  monto2='+rtrim(Cast(ISNULL(@FAcum2,0) as Varchar(30)))+'  
		where current of balgen'
		Exec(@SqlCad2)
		Set @FAcum2=0
	End	
	Fetch next from balgen into @linea,@dato1,@monto1,@dato2,@monto2 
End
close balgen
Deallocate balgen
Declare @Lineform int,	
		@Formula2  varchar(500),		
        @LineformAnt int,
        @Cadena varchar(500),
        @CadUp varchar(1000)
Set @SqlCad2='
Declare balres
cursor for	
	Select Linea=A.Linea,Lineform=B.Linea,
	       A.monto1,A.monto2,B.Formula2        
	from ##tmp_balance'+@Computer+' A,
	(select * from ##tmp_balance'+@computer+'
	where Dato2=''R'') as B
	Where PATINDEX(''%#''+ltrim(rtrim(cast(A.linea as varchar(3))))+''#%'',B.Formula2) > 0       
    order by B.Linea'
Exec(@SqlCad2)
SEt @LineformAnt=999 
Open balres
Fetch next from balres into @linea,@Lineform,@monto1,@monto2,@Formula2 
While @@Fetch_Status=0
Begin	
	If  @LineformAnt <> @Lineform 
	BEGIN
		If @Cadena <>'' 
					set @CadUp='Update ##tmp_balance'+@computer+' set Monto2='+@cadena+ ' where linea='+ 
                   				CAST(@lineform AS VARCHAR(3))                     
		Exec(@CadUp)
		Set @Cadena=@Formula2	
	END 
	Set @Cadena=REPLACE(@Cadena,'LA#'+
        rtrim(CAST(@linea AS VARCHAR(3))) +'#',RTRIM(CAST(@MONTO1 AS VARCHAR(50))))	
    Set @Cadena=REPLACE(@Cadena,'LP#'+
        rtrim(CAST(@linea AS VARCHAR(3))) +'#',RTRIM(CAST(@MONTO2 AS VARCHAR(50))))		
    Set @LineformAnt=@Lineform	
	Fetch next from balres into @linea,@Lineform,@monto1,@monto2,@Formula2 
End
If @Cadena <>'' 
	set @CadUp='Update ##tmp_balance'+@computer+' set Monto2='+@cadena+ ' where linea='+ 
                CAST(@lineform AS VARCHAR(3))                     
	

Exec(@CadUp)
close balres
Deallocate balres	
Exec('Select * From ##tmp_balance'+@computer)
GO
