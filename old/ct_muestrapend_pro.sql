SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
drop proc ct_MuestraPend_pro
execute ct_MuestraPend_pro 'campos2012','01','2012','121100','00002'
*/
ALTER  Proc [ct_MuestraPend_pro]
 @Base      varchar(50),
 @empresa varchar(2),
 @Ano       varchar(4),
 @cuenta    varchar(20),
 @analitico varchar(20)
AS
Declare @SqlCad1 varchar(8000)
SET @SqlCad1='select * from 
(
    Select AA.CuentaCodigo,AA.operacioncodigo,AA.analiticocodigo,AA.DocumentoCodigo,aa.ctacteanaliticonumdocumento,
	AA.ctacteanaliticofechadoc,	AA.monedacodigo,aa.cabcomprobnumero,
	MontoProv=	Case When AA.monedacodigo=''01'' 
              		Then (AA.ctacteanaliticodebe +  AA.ctacteanaliticohaber) 
               		Else (AA.ctacteanaliticoussdebe+AA.ctacteanaliticousshaber) 
          		End, 
    TotalPagado=Case When AA.monedacodigo=''01'' 
               		Then isnull((BB.Sdebe+BB.Shaber),0) 
               		Else isnull((BB.Sdebeuss+BB.Shaberuss),0) 
            	End,
 	Saldo=Case When AA.monedacodigo=''01'' 	Then (AA.ctacteanaliticodebe +  AA.ctacteanaliticohaber)-isnull((BB.Sdebe+BB.Shaber),0) 
               		Else (AA.ctacteanaliticoussdebe+AA.ctacteanaliticousshaber) - isnull((BB.Sdebeuss+BB.Shaberuss),0) 
          		End	
    From ['+@base+'].dbo.ct_ctacteanalitico'+@ano+' AA 
    left join (select A.CuentaCodigo,A.analiticocodigo,A.documentocodigo,A.ctacteanaliticonumdocumento,	   		
	           Sdebe=Sum(A.ctacteanaliticodebe),Shaber=sum(A.ctacteanaliticohaber),
               Sdebeuss=sum(A.ctacteanaliticoussdebe),Shaberuss=sum(A.ctacteanaliticousshaber)       
	           from ['+@base+'].dbo.ct_ctacteanalitico'+@ano+' A       
        	   where A.operacioncodigo <>''01'' and A.analiticocodigo <>''00'' and a.empresacodigo='''+@empresa+'''  
                    and A.CuentaCodigo='''+@cuenta+'''  and A.analiticocodigo='''+@analitico+'''
               Group by A.CuentaCodigo,A.analiticocodigo, A.documentocodigo,A.ctacteanaliticonumdocumento
	         ) as BB 
	 on AA.CuentaCodigo+AA.analiticocodigo+AA.documentocodigo+AA.ctacteanaliticonumdocumento=
	    BB.CuentaCodigo+BB.analiticocodigo+BB.documentocodigo+BB.ctacteanaliticonumdocumento         
	Where aa.empresacodigo='''+@empresa+''' and AA.CuentaCodigo='''+@cuenta+''' and 
        AA.analiticocodigo='''+@analitico+'''  and AA.operacioncodigo=''01''  
 ) z where Saldo <> 0 order by CuentaCodigo,analiticocodigo,documentocodigo,ctacteanaliticonumdocumento
       '  
    
execute (@SqlCad1)
