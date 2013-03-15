SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [dbo].[al_stockfecha_rep] 'ziyaz','02','10/08/2008','10/12/2008'
CREATE   procedure [al_stockfecha_rep]
@base varchar(50),
@alma varchar(2),
@fini as varchar(10),
@ffin as varchar(10)
as
declare @ncadena nvarchar(1000)
declare @parame nvarchar(1000)
declare @i char(1)
declare @s char(1)
declare @a char(1)
set @i='I'
set @s='S'
set @a='A'
set @ncadena=N'Select acodigo,adescri,
	         sum(case catipmov when @i then decantid else 0 end) as ingreso,
                  sum(case catipmov when @s then decantid else 0 end) as salida ,
	          (ROUND(sum(case catipmov when @i then decantid else 0 end),2) -
                  ROUND(sum(case catipmov when @s then decantid else 0 end),2)) as Stock
	      From ['+@base+'].dbo.movalmdet inner join
		   ['+@base+'].dbo.movalmcab 
              on  dealma=caalma and detd=catd and denumdoc=canumdoc
              inner join ['+@base+'].dbo.maeart
	      on decodigo=acodigo
              where catipmov<>@a and cafecdoc>=@fini and cafecdoc<=@ffin and
                 caalma=@alma
              group by acodigo,adescri
	      having 	
	      	(ROUND(sum(case catipmov when @i then decantid else 0 end),2) -
              	ROUND(sum(case catipmov when @s then decantid else 0 end),2) ) <> 0 '
set @parame=N'@alma varchar(2),@fini as varchar(10),@ffin as varchar(10),
	      @i char(1),@s char(1),@a char(1)'

execute sp_executesql @ncadena,@parame,@alma,@fini,@ffin,@i,@s,@a
 		
----order by acodigo
GO
