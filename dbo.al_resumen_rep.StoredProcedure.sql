SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext al_repodetalle_rep
CREATE    procedure [al_resumen_rep]
@base varchar(50),
@alma varchar(2),
@tipo varchar(1),
@fini varchar(10),
@ffin varchar(10),
@dtransa varchar(2)
as
declare @ncadena as nvarchar(4000)
declare @a as char(1)
set @a='A'
if @tipo='T' 
 begin
	set @ncadena='SELECT b.DECODIGO,d.ADESCRI,c.tt_descri,
                      year(a.CAFECDOC) as aa,month(a.CAFECDOC) as mm,
	              sum(case a.catipmov when ''I'' then b.decantid else b.decantid*-1 end ) as cantidad
	         FROM ['+@base+'].dbo.MovAlmCab a 
	             INNER JOIN ['+@base+'].dbo.MovAlmDet b 
	                ON a.CAALMA = b.DEALMA  AND 
	                 a.CATD = b.DETD AND 
	                 a.CANUMDOC = b.DENUMDOC
                     INNER JOIN ['+@base+'].dbo.MaeArt  d 
	                 ON b.DECODIGO = d.ACODIGO 
	             left JOIN ['+@base+'].dbo.tabtransa  c 
	                ON a.catipmov+a.cacodmov =c.tt_tipmov+c.tt_codmov
	         WHERE a.catipmov<>'''+@a+''' and 
	          a.CAalma='''+@alma+''' and a.CAFECDOC>='''+@fini+'''
                  and a.CAFECDOC<='''+@ffin+''''
	       if @dtransa<>'%' 
		  begin
                     set @ncadena=@ncadena+ ' and a.CACODMOV LIKE '''+@dtransa+''''                      
                  end 
		
 	 set @ncadena=@ncadena+ ' group by b.DECODIGO,d.ADESCRI,c.tt_descri,
                                  year(a.CAFECDOC),month(a.CAFECDOC)
                                  ORDER BY b.decodigo,c.tt_descri '
execute(@ncadena)
end
--EXECUTE al_resumen_rep 'FOX','08','T','01/01/2005','31/12/2005','%%'
--select * from fox.dbo.movalmcab where caalma='08' and cafecdoc >='01/01/2005' and cafecdoc <='31/01/2005'
GO
