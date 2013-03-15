SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext al_repodetalle_rep
CREATE   procedure [al_repodetalle2_rep]
@base varchar(50),
@alma varchar(2),
@tipo varchar(1),
@fini varchar(10),
@ffin varchar(10),
@dalma varchar(2),
@dtransa varchar(2)
as
declare @ncadena as nvarchar(4000)
declare @a as char(1)
set @a='A'
if @tipo='T' 
 begin
	set @ncadena=
		'SELECT MovAlmCab.CATD,MovAlmCab.CANUMDOC,MovAlmCab.CAFECDOC,
	                MovAlmDet.DECODIGO,MAEART.ADESCRI,MovAlmDet.decantid,
	                isnull(MovAlmDet.decanref,isnull(MovAlmDet.decanref1,0)) as decanref1,
	                MovAlmCab.CATIPMOV,MovAlmCab.CARFTDOC,MovAlmCab.CARFNDOC,
	                MovAlmCab.CACODMOV,movalmdet.decencos +''-''+costos.CENCOST_DESCRIPCION as cacencos,
						 MovAlmCab.canumord as num_ord,MovAlmdet.deprecio as precio
	         FROM ['+@base+'].dbo.MovAlmCab movalmcab 
	             INNER JOIN ['+@base+'].dbo.MovAlmDet movalmdet 
	              ON MovAlmCab.CAALMA = MovAlmDet.DEALMA  AND 
	                 MovAlmCab.CATD = MovAlmDet.DETD AND 
	                 MovAlmCab.CANUMDOC = MovAlmDet.DENUMDOC
                     Left JOIN ['+@BASE+'].dbo.centro_costos costos
 		     ON movalmdet.decencos=costos.CENCOST_CODIGO			
	             INNER JOIN ['+@base+'].dbo.MaeArt  maeart 
	              ON MovAlmDet.DECODIGO = MaeArt.ACODIGO 
	         WHERE movAlmCab.catipmov<>'''+@a+''' and movalmdet.dealma = '''+@alma+''' and 
	          MovAlmCab.CAFECDOC>='''+@fini+''' and MovAlmCab.CAFECDOC<='''+@ffin+''''
               if @dalma<>'%' 
		  begin
                     set @ncadena=@ncadena + ' and MovAlmdet.DECENCOS like '''+@dalma+''''
                  end  
	       if @dtransa<>'%' 
		  begin
                     set @ncadena=@ncadena+ ' and MovAlmcab.CACODMOV LIKE '''+@dtransa+''''                      
                  end 
		
 	 set @ncadena=@ncadena+ ' ORDER BY MovAlmCab.CAfecdoc,MovAlmCab.CATD,MovAlmCab.CANUMDOC'
	
	execute( @ncadena)
   end
if @tipo<>'T'
begin
	set @ncadena=
		'SELECT MovAlmCab.CATD,MovAlmCab.CANUMDOC,MovAlmCab.CAFECDOC,
	                MovAlmDet.DECODIGO,MAEART.ADESCRI,MovAlmDet.decantid,
	                isnull(MovAlmDet.decanref,isnull(MovAlmDet.decanref1,0)) as decanref1,
	                MovAlmCab.CATIPMOV,MovAlmCab.CARFTDOC,MovAlmCab.CARFNDOC,
	                MovAlmCab.CACODMOV,movalmdet.decencos+''-''+costos.CENCOST_DESCRIPCION as cacencos,
						 MovAlmCab.canumord as num_ord,MovAlmdet.deprecio as precio
	         FROM ['+@base+'].dbo.MovAlmCab movalmcab 
	             INNER JOIN ['+@base+'].dbo.MovAlmDet movalmdet 
	              ON MovAlmCab.CAALMA = MovAlmDet.DEALMA  AND 
	                 MovAlmCab.CATD = MovAlmDet.DETD AND 
	                 MovAlmCab.CANUMDOC = MovAlmDet.DENUMDOC
                     Left JOIN ['+@BASE+'].dbo.centro_costos costos
		     ON movalmdet.decencos=costos.CENCOST_CODIGO			
	             INNER JOIN ['+@base+'].dbo.MaeArt  maeart 
	              ON MovAlmDet.DECODIGO = MaeArt.ACODIGO 
	         WHERE movAlmCab.catipmov='''+@tipo+''' and movalmdet.dealma = '''+@alma+''' and 
                 MovAlmCab.CAFECDOC>='''+@fini+''' and MovAlmCab.CAFECDOC<='''+@ffin+'''' 
              if @dalma<>'%'  
                 begin  
                    set @ncadena=@ncadena + ' and MovAlmDet.DECENCOS like '''+@dalma+'''' 
                 end 
	      if @dtransa<>'%' 
		 begin	
                    set @ncadena=@ncadena+ ' and MovAlmCab.CACODMOV LIKE '''+@dtransa+''''                      
		 end 
   	      set @ncadena=@ncadena+ ' ORDER BY MovAlmCab.CAfecdoc,MovAlmCab.CATD,MovAlmCab.CANUMDOC'
	
	execute( @ncadena)
   end
GO
