SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Objeto:  procedimiento almacenado dbo.ct_plantillasubasientos_rpt    fecha de la secuencia de comandos: 19/12/2007 11:21:49 a.m. *****
drop   Procedure ct_plantillasubasientos_rpt
*/
CREATE  Procedure [ct_plantillasubasientos_rpt]
(@Base varchar(50),
 @empresa varchar(2),
 @anno varchar(4),
 @asientocodigo varchar(3), 
 @subasientocodigo varchar(4))
		
As
    Declare @sqlcad varchar(5000)
     /*set nocount on */
 set @sqlcad=''+ 'SELECT A.asientocodigo, 
    A.subasientocodigo, 
    A.plantillaasientocorrela, 
    A.cuentacodigo, 
    A.operacioncodigo, 
    A.iddebeohaber, 
    A.plantillaasientoinafecto, 
    A.plantillaasientocuentaigv, 
    A.plantillaasientovalorigv, 
    A.plantillaasientocomodin, 
    B.asientodescripcion, 
    C.subasientodescripcion, 
    D.operaciondescripcion, 
    E.cuentadescripcion
    FROM [' +@base+ '].dbo.[ct_plantillaasiento] A, 
         [' +@base+ '].dbo.[ct_asiento] B,
	 [' +@base+ '].dbo.[ct_subasiento] C,
	 [' +@base+ '].dbo.[ct_operacion] D,
	 [' +@base+ '].dbo.[ct_cuenta] E,
         [' +@base+ '].dbo.[ct_detcomprob' +@anno+ '] F
    WHERE 
	A.asientocodigo = B.asientocodigo AND A.subasientocodigo = C.subasientocodigo 
	AND A.asientocodigo=C.asientocodigo AND	B.asientocodigo=C.asientocodigo 
	AND A.operacioncodigo = D.operacioncodigo AND 
        A.cuentacodigo = E.cuentacodigo 
        AND A.asientocodigo like ''' +@asientocodigo+ '''
        AND A.subasientocodigo like ''' +@subasientocodigo+ '''
        AND f.empresacodigo like ''' +@empresa+ '''	
    ORDER BY 1, 2, 3'
    exec (@sqlcad)
---EXECUTE ct_plantillasubasientos_rpt 'mmj2008','01','2007','%%','%%'
GO
