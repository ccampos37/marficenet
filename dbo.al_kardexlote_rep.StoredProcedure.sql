SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [al_kardexlote_rep]
--declare
@base varchar(50)
as
--set @base='green'
declare @cadena as varchar(1000)
set @cadena='select distinct TT_DESCRI,a.c1,a.c2,a.c3,a.c4,a.c5,a.c6,a.c7,a.c8,a.c11,
             a.tipdocrf,a.numdocrf,b.adescri,d.clienterazonsocial 
             from ['+@base+'].dbo.kardexaux A
	     inner join ['+@base+'].dbo.maeart B
	     on a.c1=b.acodigo  
             left outer join ['+@base+'].dbo.stklote C 	     
	     on a.c1 = c.stscodigo and a.c11 = c.stslote 
             left outer join ['+@base+'].dbo.cp_proveedor D
  	     on c.stscodprov = d.clientecodigo 
             left join ['+@base+'].dbo.tabtransa E ON a.c4=e.tt_codmov'		
exec (@cadena)
--execute al_kardexlote_rep 'playacasma'
GO
