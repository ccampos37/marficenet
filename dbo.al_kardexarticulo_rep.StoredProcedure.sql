SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [al_kardexarticulo_rep]
@base varchar(50)
as
declare @cadena varchar(4000)
set @cadena='select c1,c2,c3,c4,c5,c6,c7,c8,C11,alma,tipdocrf,numdocrf,adescri,
             tt_tipmov ,carftdoc,carfndoc
             from ['+@base+'].dbo.kardexaux
	     inner join ['+@base+'].dbo.maeart
	     on c1=acodigo
             left join ['+@base+'].dbo.tabtransa
             on c4=tt_codmov 
             left join ['+@base+'].dbo.movalmcab
             on alma+c2+c5=caalma+catd+canumdoc           '		
execute(@cadena)
---EXECUTE al_kardexarticulo_rep 'invaqplanta'
GO
