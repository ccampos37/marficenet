SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
Create  proc [cs_gentemptintoBK]
/*
	Author: Fernando Cossio Peralta
   Fecha Ini : 21/05/2003 
   Fecha Ter : 
   Procedimiento : Vaciado de informacion de Tintoreria 
   al modulo de costos centralizando la informacion en base a la
   fecha de proceso.
*/
--Declare  
@base    varchar(50),
@baseemp varchar(50),
@mes   int,
@anno  varchar(4),
@compu varchar(50),
@Nmesatras int, 
@Nmesadela int
/*Set @base='db_costos'
Set @mes=5
Set @anno='2004'
Set @compu='desarrollo3'
Set @baseemp='etextil0001'
Set @Nmesatras=2
Set @Nmesadela=1 */
as
--Tabla temporal de produccion de kilos por maquina
if exists(select name from tempdb.dbo.sysobjects where name='##tmp_headorden'+@compu)
Exec('Drop table ##tmp_headorden'+@compu )
Exec('Select *,mesxx=''00-0000 '' into ##tmp_headorden'+@compu+'   
      from ['+@base+'].dbo.head_orden_04_2003 where 1=0 ')
--Tabla temporal del detalle de produccion de kilos por maquina
if exists(select name from tempdb.dbo.sysobjects where name='##tmp_Detorden'+@compu)
Exec('Drop table ##tmp_Detorden'+@compu )
Exec('Select *,mesxx=''00-0000 '' into ##tmp_Detorden'+@compu+'   
      from ['+@base+'].dbo.Det_Orden_04_2003 where 1=0 ')
--Tabla temporal de control de horas de los trabajadores por maquina
if exists(select name from tempdb.dbo.sysobjects where name='##tmp_CTRLorden'+@compu)
Exec('Drop table ##tmp_CTRLorden'+@compu )
Exec('Select *,mesxx=''00-0000 '' into ##tmp_CTRLorden'+@compu+'   
      from ['+@base+'].dbo.CTRL_04_2003 where 1=0 ')
--Tabla teporal de quimico partes cabecera
--select * from [etextil0001].dbo.quimicopartes_04_2003
/* Verificar porque hay algunos quimico partes que no tiene codigo de orden
 */  
if exists(select name from tempdb.dbo.sysobjects where name='##tmp_quimicopartes'+@compu)
Exec('Drop table ##tmp_quimicopartes'+@compu )
Exec('Select *,mesxx=''00-0000 '' into ##tmp_quimicopartes'+@compu+'   
      from ['+@baseemp+'].dbo.quimicopartes_04_2003 where 1=0 ')
--Tabla temporal de quimico partes detalle el precio de los insumos por hoha de trabajo
--select * from [etextil0001].dbo.quimicopartesitems_04_2003
if exists(select name from tempdb.dbo.sysobjects where name='##tmp_quimicopartesitems'+@compu)
Exec('Drop table ##tmp_quimicopartesitems'+@compu )
Exec('Select *,mesxx=''00-0000 '' into ##tmp_quimicopartesitems'+@compu+'   
      from ['+@baseemp+'].dbo.quimicopartesitems_04_2003 where 1=0 ')
Declare 
@mesaux int,
@desmes varchar(2),  
@periodo varchar(10),
@i      int,  
@SqlCad varchar(5000),
@mesx int,
@anox int
--Buscando hacia atras
Set @i=0
Set @mesaux=@mes
set @periodo=replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
             '_'+@anno
Declare @conta int   
While @i <=@Nmesatras
Begin 
   --Print @periodo    
   --set @desmes=replicate('0',2-len(@mesaux))+ltrim(rtrim(cast(@mesaux as varchar(2))))	   
   --Insertando en la cabecerta de la tabla temporal produccion de kilos por maquina
   
   Set @SqlCad=''+ 
   'Declare tempoxx 
    cursor for select conta=isnull(count(name),0) from ['+@base+'].dbo.sysobjects 
    where ltrim(rtrim(name))=''head_orden_'+@periodo+''''   
   exec (@SqlCad)   
   set @conta=0
   open  tempoxx
   fetch next from tempoxx into @conta 
   close tempoxx
   deallocate tempoxx      
   --print (@conta) 
 If @conta=1
 Begin
   Set @SqlCad='Insert Into ##tmp_headorden'+@compu+'  
   Select *,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' 
   Where month(FechaDespacho)='+cast(@mes as varchar(2))     
   exec(@SqlCad) 
   Set @SqlCad='Insert Into ##tmp_Detorden'+@compu+'  
	Select B.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@base+'].dbo.Det_Orden_'+@periodo+' B              
   Where A.Cod_Orden=B.Cod_Orden and                  
         month(A.FechaDespacho)='+cast(@mes as varchar(2))        
   exec(@SqlCad) 
   
   Set @SqlCad=''+ 
   'Insert Into ##tmp_CTRLorden'+@compu+char(13)+
   ' Select A.*,'''+@periodo+''' from  ['+@base+'].dbo.CTRL_'+@periodo+' A
     inner join 
   (Select A.Cod_Partida from ['+@base+'].dbo.Det_Orden_'+@periodo+' A
    inner join db_costos.dbo.head_Orden_'+@periodo+' B
	  on A.Cod_orden=B.Cod_orden and 
    month(B.FechaDespacho)='+cast(@mes as varchar(2))+')  as B
   on a.cod_partida=b.cod_partida '
   exec(@SqlCad)        
   
   Set @SqlCad='Insert Into ##tmp_quimicopartes'+@compu+'  
	Select B.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@baseemp+'].dbo.quimicopartes_'+@periodo+' B              
   Where A.Cod_Orden=B.Cod_Orden and                  
         month(A.FechaDespacho)='+cast(@mes as varchar(2))           
   exec(@SqlCad)
   Set @SqlCad='Insert Into ##tmp_quimicopartesitems'+@compu+'  
	Select C.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@baseemp+'].dbo.quimicopartes_'+@periodo+' B,
                 ['+@baseemp+'].dbo.quimicopartesitems_'+@periodo+' C               
   Where A.Cod_Orden=B.Cod_Orden and     
         B.NroMovQuimico=C.NroMovQuimico and              
         month(A.FechaDespacho)='+cast(@mes as varchar(2))           
   exec(@SqlCad)
 End
   set @i=@i+1
   set @mesx=month(
               dateadd(Month,@i * -1,
                 cast('01/'+
                      replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
                      '/'+@anno as datetime))     
                  )  
   set @anox=year(
               dateadd(Month,@i * -1,
                 cast('01/'+
                      replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
                      '/'+@anno as datetime))  
                 )
   set @periodo=replicate('0',2-len(@mesx))+ltrim(rtrim(cast(@mesx as varchar(2))))+
                '_'+cast(@anox as varchar(4))                        
End 
--Buscando hacia adelante
Set @i=0
Set @mesaux=@mes
set @periodo=replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
             '_'+@anno
While @i < @Nmesadela
Begin 
   set @mesaux=@mesaux+1
   set @i=@i+1       
   set @mesx=month(
               dateadd(Month,@i  ,
                 cast('01/'+
                      replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
                      '/'+@anno as datetime))     
                )
   set @anox=year(
               dateadd(Month,@i ,
                 cast('01/'+
                      replicate('0',2-len(@mes))+ltrim(rtrim(cast(@mes as varchar(2))))+
                      '/'+@anno as datetime))  
                 )
   set @periodo=replicate('0',2-len(@mesx))+ltrim(rtrim(cast(@mesx as varchar(2))))+
                '_'+cast(@anox as varchar(4))                        
	--set @desmes=replicate('0',2-len(@mesaux))+ltrim(rtrim(cast(@mesaux as varchar(2))))	
   --Print @periodo
      Set @SqlCad=''+ 
   'Declare tempoxx 
    cursor for select conta=isnull(count(name),0) from ['+@base+'].dbo.sysobjects 
    where ltrim(rtrim(name))=''head_orden_'+@periodo+''''   
   exec (@SqlCad)   
   set @conta=0
   open  tempoxx
   fetch next from tempoxx into @conta 
   close tempoxx
   deallocate tempoxx      
   --print (@conta) 
 If @conta=1
 Begin   
	Set @SqlCad='Insert Into ##tmp_headorden'+@compu+'  
	Select *,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' 
    Where month(FechaDespacho)='+cast(@mes as varchar(2))     
   exec(@SqlCad)	
   Set @SqlCad='Insert Into ##tmp_Detorden'+@compu+'  
	Select B.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@base+'].dbo.Det_Orden_'+@periodo+' B              
   Where A.Cod_Orden=B.Cod_Orden and                  
         month(A.FechaDespacho)='+cast(@mes as varchar(2))        
   exec(@SqlCad) 
   Set @SqlCad=''+ 
   'Insert Into ##tmp_CTRLorden'+@compu+char(13)+
   ' Select A.*,'''+@periodo+''' from  ['+@base+'].dbo.CTRL_'+@periodo+' A
   inner join 
   (Select A.Cod_Partida from ['+@base+'].dbo.Det_Orden_'+@periodo+' A
    inner join db_costos.dbo.head_Orden_'+@periodo+' B
	  on A.Cod_orden=B.Cod_orden and 
    month(B.FechaDespacho)='+cast(@mes as varchar(2))+')  as B
   on a.cod_partida=b.cod_partida '
   exec(@SqlCad)        
   
   Set @SqlCad='Insert Into ##tmp_quimicopartes'+@compu+'  
	Select B.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@baseemp+'].dbo.quimicopartes_'+@periodo+' B              
   Where A.Cod_Orden=B.Cod_Orden and                  
         month(A.FechaDespacho)='+cast(@mes as varchar(2))           
   exec(@SqlCad)
   Set @SqlCad='Insert Into ##tmp_quimicopartesitems'+@compu+'  
	Select C.*,'''+@periodo+''' from ['+@base+'].dbo.head_orden_'+@periodo+' A, 
                 ['+@baseemp+'].dbo.quimicopartes_'+@periodo+' B,
                 ['+@baseemp+'].dbo.quimicopartesitems_'+@periodo+' C               
   Where A.Cod_Orden=B.Cod_Orden and     
         B.NroMovQuimico=C.NroMovQuimico and              
         month(A.FechaDespacho)='+cast(@mes as varchar(2))           
   exec(@SqlCad) 
 End         
End
GO
