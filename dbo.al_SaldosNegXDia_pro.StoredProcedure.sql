SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute al_SaldosNegXDia_pro 'ziyaz','02','201201','##70554751'
*/


CREATE proc [al_SaldosNegXDia_pro]
@base varchar(50),
@empresa varchar(2),
@mesproceso varchar(6),
@computer varchar(50)
as

declare @sql varchar(4000)

set @sql='If Exists(Select name from tempdb..sysobjects where name='''+@computer+'_neg'') 
    Drop Table ['+@computer +'_neg] 
select top 0 caalma,almacendescripcion, catd,canumdoc,cafecdoc, decodigo,codigodescripcion, catipmov, decantid, saldo=deprecio 
into ['+@computer +'_neg]
from '+@base+'.dbo.v_kardex where almacenvalorizado=1 and empresacodigo='''+@empresa+''' 
and mesproceso='''+@mesproceso+'''
 
Declare @caalma varchar(2) , @catd varchar(2) , @canumdoc varchar(11) ,@catipmov varchar(1) ,@decodigo varchar(20) , @decantid float
declare @cafecdoc datetime, @codigodescripcion varchar(100), @almacendescripcion varchar(30)
Declare @caalmaold varchar(2) ,@decodigoold varchar(20) , @saldo float 
Declare Correla cursor for 
Select caalma,almacendescripcion, catd,canumdoc,cafecdoc, decodigo, codigodescripcion, catipmov, decantid 
       from '+@base+'.dbo.v_kardex where almacenvalorizado=1 and empresacodigo='''+@empresa+'''   and estadocosto=1 
            and mesproceso='''+@mesproceso+''' order by dealma, decodigo, cafecdoc,catipmov, tipodecosto 
		Open Correla
		fetch next from Correla into @caalma,@almacendescripcion, @catd, @canumdoc,@cafecdoc, @decodigo,@codigodescripcion, @catipmov, @decantid 
        set @caalmaold =''''
        set @decodigoold ='''' 
    	While @@Fetch_Status=0 
	     	Begin 
	          if @caalma<> @caalmaold or @decodigo<> @decodigoold 
	              begin
                     set @saldo =0
	              end

              if @catipmov=''I''         
                       begin
                          set @saldo=@saldo + @decantid 
                       end
	          if @catipmov=''S'' 
                       begin
                          set @saldo=@saldo - @decantid 
                       end
	          if @saldo < 0  
                       begin
                         insert dbo.['+@computer +'_neg] (caalma,almacendescripcion, catd,canumdoc,cafecdoc, decodigo,codigodescripcion, catipmov, decantid, saldo ) 
                           values ( @caalma,@almacendescripcion, @catd, @canumdoc, @cafecdoc, @decodigo,@codigodescripcion, @catipmov,@decantid ,@saldo )
       	               end
 	           set @decodigoold=@decodigo
               set @caalmaold=@caalma 
		fetch next from Correla into @caalma,@almacendescripcion, @catd, @canumdoc,@cafecdoc, @decodigo,@codigodescripcion, @catipmov, @decantid 
        End
	    Close Correla
	    Deallocate Correla  ' 

execute(@sql)
GO
