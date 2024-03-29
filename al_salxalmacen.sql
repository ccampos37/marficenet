SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

EXECUTE al_stockactual_rep 'agro2000','11','0','0','03','%%'
DROP PROC [dbo].[al_stockactual_rep]
*/

ALTER        procedure [al_stockactual_rep]
@base as varchar(50),
@almacen as varchar(2),
@precio as varchar(1)='0',
@where as varchar(1)='1',
@fam1  varchar(10)='%%',
@fam2 varchar(10)='%%'
as
declare @cadena as nvarchar(4000)
set @cadena='select yy.*
 from 
  ( Select afamilia,FAM_NOMBRE,ACODIGO2,ACodigo,Adescri,
            disp= STSKDIS ,
             comp=stskdis,
             precio = case when '+@precio+'=1 then aprecio else 0 end  
             From ['+@base+'].dbo.MAEART  a
             Inner Join ['+@base+'].dbo.STKART b on ACodigo=STCodigo
             left Join ['+@base+'].dbo.familia c on afamilia=fam_codigo
             Where Stalma='''+@almacen+''' and isnull(a.afstock,1)=''1'' '
if @fam1 <>'%%' and @fam2 <>'%%' set @cadena=@cadena+' and afamilia BETWEEN '''+@fam1 +''' and +'''+@fam2+'''' 
if @fam1 <>'%%' and @fam2 ='%%' set @cadena=@cadena+' and afamilia >='''+@fam1 +''' ' 
if @where<>'0' set @cadena=@cadena+ ' and b.stskdis <> 0  '
set @cadena=@cadena+ '  ) as yy '

execute(@cadena) 


