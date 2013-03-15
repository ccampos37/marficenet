SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec ct_ResumenMovimientosCuentas 'PLANTA_CASMA','01','2008',('%)',6




*/


CREATE     procedure [ct_ResumenMovimientosCuentas] (
@base 	as varchar(30),
@empresa varchar(2),
@anno 	as varchar(4),
@cuenta 	as varchar(2000),
@numdig 	as int )
as
Declare @cadsql as varchar(6000)
set @cadsql='Select zz.*,C.saldodebe00,C.saldohaber00,Total=(C.saldodebe00-C.saldohaber00)+(EneD-EneH)+(FebD-FebH)+(MarD-MarH)+(AbrD-AbrH)+(MayD-MayH)+(JunD-JunH)+(JulD-JulH)+(AgoD-AgoH)+(SetD-SetH)+(OctD-OctH)+(NovD-NovH)+(DicD-DicH) from 
(select empresacodigo,Cod2=left(B.cuentacodigo,2),B.cuentacodigo,B.cuentadescripcion,
  EneD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=1),0) as Numeric(15,2)),
  EneH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=1),0) as Numeric(15,2)),
  FebD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=2),0) as Numeric(15,2)),
  FebH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=2),0) as Numeric(15,2)),
  MarD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=3),0) as Numeric(15,2)),
  MarH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=3),0) as Numeric(15,2)),
  AbrD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=4),0) as Numeric(15,2)),
  AbrH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=4),0) as Numeric(15,2)),
  MayD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=5),0) as Numeric(15,2)),
  MayH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=5),0) as Numeric(15,2)),
  JunD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=6),0) as Numeric(15,2)),
  JunH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=6),0) as Numeric(15,2)),
  JulD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=7),0) as Numeric(15,2)),
  JulH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=7),0) as Numeric(15,2)),
  AgoD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=8),0) as Numeric(15,2)),
  AgoH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=8),0) as Numeric(15,2)),
  SetD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=9),0) as Numeric(15,2)),
  SetH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=9),0) as Numeric(15,2)),
  OctD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=10),0) as Numeric(15,2)),
  OctH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=10),0) as Numeric(15,2)),
  NovD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=11),0) as Numeric(15,2)),
  NovH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=11),0) as Numeric(15,2)),
  DicD=cast(isnull((select sum(A.detcomprobdebe) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=12),0) as Numeric(15,2)),
  DicH=cast(isnull((select sum(A.detcomprobhaber) from ' +@base+ '.dbo.ct_detcomprob' +@anno+ ' A 
			where A.cuentacodigo=B.cuentacodigo and A.cabcomprobmes=12),0) as Numeric(15,2))
from ' +@base+ '.dbo.ct_cuenta B
inner join ' +@base+ '.dbo.ct_saldos'+@anno+' C 
on zz.empresacodigo=c.empresacodigo and ZZ.cuentacodigo=C.cuentacodigo
where empresacodigo='''+@empresa+''' and left(B.cuentacodigo,''' +cast(@numdig as varchar(2))+ ''' ) 
LIKE (' +@cuenta+ '%) and len(cuentacodigo)=6 ) as ZZ
order by ZZ.cuentacodigo'

PRINT(@cadsql)
GO
