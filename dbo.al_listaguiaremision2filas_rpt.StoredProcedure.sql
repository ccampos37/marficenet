SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute al_listaguiaremision2filas_rpt 'ziyaz','00200016668','02','13'
select * from ziyaz.DBO.movalmcab where  carfndoc='00200007744'
SELECT * FROM ziyaz.dBO.tabalm

-- drop al_listaguiaremision2filas_rpt
*/

CREATE        procedure [al_listaguiaremision2filas_rpt]
@base varchar(50),
@numdoc varchar(11),
@empresa varchar(2),
@almacen varchar(2)
as
declare @cadena as nvarchar(1500)
--''Alamcen ''+rtrim(a.cadirenv)+''-''+rtrim(t.tadescri) as Almacen
SET @cadena =N' SELECT a.carfndoc,A.canomcli,
''Alamcen ''+rtrim(a.cadirenv)+''-''+rtrim(t.tadescri) as Almacen,
a.cacodtran,C.decodigo,c.decantid,c.deunidad,D.adescri,E.tranombre,
a.caruc,a.contacto,empresadescripcion,pv.direccioncomercial as direcentrega,isnull(e.trabreve,0) as Brevete,
factura=pe.pedidotipofac+''-''+pedidonrofact ,EMPRESARUC, direcdestino=rtrim(tt.tadirecc)+ '' ''+rtrim(tt.tadistri)
FROM ['+@base+'].dbo.MOVALMCAB A 
INNER JOIN ['+@base+'].dbo.movalmdet C ON a.caalma+a.catd+a.canumdoc=c.dealma+c.detd+C.denumdoc
INNER JOIN ['+@base+'].dbo.MAEART D ON C.decodigo=D.ACODIGO
inner join ['+@base+'].dbo.co_multiempresas m on a.empresacodigo=m.empresacodigo
inner join ['+@base+'].dbo.tabalm t on a.caalma=t.taalma 
left join['+@base+'].dbo.al_transporte E on a.cacodtran=E.tracodigo
left join['+@base+'].dbo.vt_pedido pe on a.empresacodigo+a.canroped=pe.empresacodigo+pe.pedidonumero
left join['+@base+'].dbo.tabalm tt on a.cadirenv=tt.taalma
left join['+@base+'].dbo.vt_puntoventa pv on t.puntovtacodigo=pv.puntovtacodigo
where a.carftdoc=''GR'' and a.carfndoc='''+@numdoc+'''  and a.empresacodigo='''+@empresa+''' and a.caalma='''+@almacen+'''  ' 

execute(@cadena)
GO
