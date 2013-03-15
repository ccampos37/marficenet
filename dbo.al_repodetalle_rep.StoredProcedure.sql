SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute al_repodetalle_rep 'xx_almacen_ziyaz','50','T','31/12/2010','31/12/2010','%%','%%'
DROP PROC al_repodetalle_rep
*/

CREATE         procedure [al_repodetalle_rep]
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
	set @ncadena='select deprecio1=deprecio * tipocambio,total1=total*tipocambio,zz.* from 
   ( SELECT a.CATD,a.CANUMDOC,b.deitem,a.CAFECDOC,p.clienterazonsocial,casitgui=isnull(a.casitgui,'' ''),
            aamm=str(year(cafecdoc),4)+''-''+str(month(cafecdoc),2),
	       b.DECODIGO,c.ADESCRI,b.decantid,isnull(b.decanref,isnull(b.decanref1,0)) as decanref1,
	       a.CATIPMOV,a.CARFTDOC,a.CARFNDOC,a.CACODMOV,transa.tt_descri,
          canompro=case when isnull(a.casitgui,'' '')=''A'' then 
           '' A N U L A D O '' else a.canomcli end ,cacodmon,deprecio,
           factura=pe.pedidotipofac+''-''+pe.pedidonrofact,
           tipocambio=isnull(case when cacodmon=''02'' then 
                                 (select tipocambioventa from ['+@base+'].dbo.ct_tipocambio where tipocambiofecha=a.cafecdoc)
                           else 1 end,1), deordfab,aunidad,
			TOTAL=ROUND(DEPRECIO*DECANTID,2)
 	         FROM ['+@base+'].dbo.MovAlmCab a
      left JOIN ['+@base+'].dbo.MovAlmDet b ON a.CAALMA = b.DEALMA  AND a.CATD = b.DETD AND a.CANUMDOC = b.DENUMDOC
	  left JOIN ['+@base+'].dbo.MaeArt  c ON b.DECODIGO = c.ACODIGO 
	  left JOIN ['+@base+'].dbo.tabtransa  transa  ON a.catipmov+a.cacodmov =transa.tt_tipmov+transa.tt_codmov
	  left JOIN ['+@base+'].dbo.vt_cliente p ON a.cacodcli =p.clientecodigo
  	  left JOIN ['+@base+'].dbo.vt_pedido pe ON a.empresacodigo+a.canroped =pe.empresacodigo+pe.pedidonumero
      WHERE a.caalma = '''+@alma+''' and isnull(c.afstock,1)=1 and
           a.CAFECDOC>='''+@fini+''' and a.CAFECDOC<='''+@ffin+''''
	       if @dtransa<>'%%' 
		  begin
               set @ncadena=@ncadena+ ' and a.CACODMOV LIKE '''+@dtransa+''''                      
                  end 
		
 	 set @ncadena=@ncadena+ ' ) as zz ORDER BY zz.decodigo,zz.CAfecdoc,zz.CATD,zz.CANUMDOC'
	
	execute( @ncadena)
   end
if @tipo<>'T'
begin
set @ncadena= 'Select deprecio1=deprecio * tipocambio,total1=total*tipocambio,
    zz.* from 
  ( SELECT a.CATD,a.CANUMDOC,b.deitem,a.CAFECDOC,p.clienterazonsocial,casitgui=isnull(a.casitgui,'' ''),
           aamm=str(year(cafecdoc),4)+''-''+str(month(cafecdoc),2), b.DECODIGO,c.ADESCRI,b.decantid,
	       isnull(b.decanref,isnull(b.decanref1,0)) as decanref1,a.CATIPMOV,a.CARFTDOC,a.CARFNDOC,
	       a.CACODMOV,tr.tt_descri,
           canompro=case when isnull(a.casitgui,'' '')=''A'' then 
           '' A N U L A D O '' else a.canomcli end , cacodmon,deprecio,
           factura=pe.pedidotipofac+''-''+pe.pedidonrofact,
           tipocambio=isnull(case when cacodmon=''02'' then 
                     (select tipocambioventa from ['+@base+'].dbo.ct_tipocambio where tipocambiofecha=a.cafecdoc)
                     else 1 end,1),
           deordfab,c.aunidad,
		   TOTAL=ROUND(DEPRECIO*DECANTID,2)
, b.decencos+''-''+costos.centrocostoDESCRIPCION as cacencos
  FROM ['+@base+'].dbo.MovAlmCab a left JOIN ['+@base+'].dbo.MovAlmDet b 
	              ON a.CAALMA = b.DEALMA  AND a.CATD = b.DETD AND  a.CANUMDOC = b.DENUMDOC
      Left JOIN ['+@BASE+'].dbo.ct_centrocosto costos ON b.decencos=costos.centrocostocodigo			
	  left JOIN ['+@base+'].dbo.MaeArt  c  ON b.DECODIGO = c.ACODIGO 
	  left JOIN ['+@base+'].dbo.tabtransa  tr ON a.catipmov+a.cacodmov =tr.tt_tipmov+tr.tt_codmov
	  left JOIN ['+@base+'].dbo.vt_cliente p ON a.cacodcli =p.clientecodigo
  	  left JOIN ['+@base+'].dbo.vt_pedido pe ON a.empresacodigo+a.canroped =pe.empresacodigo+pe.pedidonumero
 WHERE a.caalma='''+@alma +''' and isnull(c.afstock,1)=1 '
 if @tipo='A'
     begin
      set @ncadena = @ncadena+ 'and a.casitgui=''A'' '
     end
   else 
     begin
       set @ncadena = @ncadena +' and a.catipmov='''+@tipo+''' '
     end 
set @ncadena = @ncadena +' and a.CAFECDOC>='''+@fini+''' and a.CAFECDOC<='''+@ffin+'''' 
      if @dtransa<>'%%' 
		 begin	
             set @ncadena=@ncadena+ ' and a.CACODMOV LIKE '''+@dtransa+''''                      
		 end 
       set @ncadena=@ncadena+ ' ) as zz ORDER BY zz.CAfecdoc,zz.CATD,zz.CANUMDOC'
	
	execute( @ncadena)
   end
GO
