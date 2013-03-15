SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    proc [te_ResumenesdeCaja_rpt]
--Declare 
@Base   varchar(50),
@tipo varchar(1), 
@Caja  varchar(2),
@Fechaini  varchar(10),
@Fechafin  varchar(10),
@concepto varchar(2),
@empresa varchar(2)
as 
/*
 Set @Base='Ventas_Prueba'
 Set @cuenta='011-350-0100008495-62' 
 set @concil='2' 
 Set @Fecharef='01/01/2003'  
 Set @fecha='01/12/2002'  
*/
Declare @Sqlcad varchar(4000),@Sqlcad1 varchar(4000),@Sqlvar varchar(4000)
Set @Sqlcad='
select * from ['+@Base+'].dbo.v_te_conciliacioncaja a
where detrec_tipocajabanco='''+@tipo+''' and cabrec_estadoreg <> 1 and 
      detrec_fechacancela >='''+@Fechaini+''' and 
      detrec_fechacancela <='''+@Fechafin+''' and 
      detrec_tipodoc_concepto like ('''+@concepto+''') and
      DETREC_cajabanco1='''+@caja+''' and 
      chkconcil=1 '
execute(@Sqlcad) 
--select * from acuaplayacasma.dbo.v_te_conciliacioncaja
---execute te_ResumenesdeCaja_rpt 'acuaplayacasma','C','30','01/01/2007','31/01/2007','%%','%%'
GO
