SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Execute al_kardexvalresumidoEmpresa_rpt 'ziyaz','02','201201'
select a.smcodigo , 
saldoene=(a.smmnvali+a.smmnent-a.SMMNSAL) ,
feb=(b.smmnvali),
* from ziyaz.dbo.AL_MOVRESMES a  
LEFT join ( select * from ziyaz.dbo.AL_MOVRESMES where empresacodigo='02' and smmespro='201002' ) b
on a.smcodigo=b.smcodigo 
where a.empresacodigo='02' AND A.smmespro='201001'
AND ROUND((a.smmnvali+a.smmnent-a.SMMNSAL),2) <>ROUND( (b.smmnvali),2)


*/


CREATE  procedure [al_kardexvalresumidoEmpresa_rpt]
(
@base varchar(50),
@empresa varchar(2),
@mes varchar(6)
)
as
Declare @cadena nvarchar(2000)
Declare @nparame nvarchar(2000)

SET @cadena='SELECT puntovtadescripcion,fam_nombre , SMCODIGO,adescri, aunidad, SMUSPREANT , SMMNPREANT, SMUSPREUNI, SMMNPREUNI, SMSALDOINI, SMMNVALI , SMUSVALI, SMCANENT, SMUSENT, 
                    SMMNENT , SMCANSAL, smmnsal, smUSsal, SMACTCAN, SMMNACTVAL , SMUSACTVAL, SMULTMOV, SMGRUPO, SMFAMILIA, SMLINEA,  SMTIPO
                     from ['+@base+'].dbo.AL_MOVRESMES a 
                     inner join ['+@base+'].dbo.maeart b on a.smcodigo=b.acodigo
                     left join ['+@base+'].dbo.familia c on b.AFAMILIA=c.FAM_CODIGO
                     left join ['+@base+'].dbo.vt_puntoventa d on a.puntovtacodigo=d.puntovtacodigo
                      WHERE  a.empresacodigo = '''+@empresa+''' and a.smmespro='''+@mes+'''  '
--if @mes<='201006'  set @cadena=@cadena + 'and a.puntovtacodigo='''' ' 
--if @mes>'201006' set @cadena=@cadena + 'and a.puntovtacodigo<>'''' ' 
 
execute(@CADENA)
GO
