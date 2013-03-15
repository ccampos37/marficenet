SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [cc_actualizacab]
@baseconta varchar(50),
@ano       varchar(4),
@mes       varchar(2),
@asiento   varchar(3)
As
/*Set @baseconta='contaprueba'
  Set @ano='2003'
  Set @mes='01'   
  Set @asiento='07%' */
Declare @SqlCad varchar(4000)
Set @SqlCad='
Update ['+@baseconta+'].dbo.ct_cabcomprob'+@ano+'
	Set cabcomprobtotdebe=X.Sdebe,
		cabcomprobtothaber=X.Shaber,
		cabcomprobtotussdebe=X.Sdebeuss,
		cabcomprobtotusshaber=X.Shaberuss
From ['+@baseconta+'].dbo.ct_cabcomprob'+@ano+' A,  
     (Select
		cabcomprobmes,cabcomprobnumero,asientocodigo,subasientocodigo, 
		Sdebe=Sum(detcomprobdebe),Shaber=Sum(detcomprobhaber),
		Sdebeuss=Sum(detcomprobussdebe),Shaberuss=Sum(detcomprobusshaber)
		from ['+@baseconta+'].dbo.ct_detcomprob'+@ano+'
		Where 
		cabcomprobmes='+@mes+' And
		asientocodigo LIKE '''+@asiento+'''
		Group By cabcomprobmes,cabcomprobnumero,asientocodigo,subasientocodigo 
      ) As X
Where  
	A.cabcomprobmes=X.cabcomprobmes and 
    A.cabcomprobnumero=X.cabcomprobnumero and 
    A.asientocodigo=X.asientocodigo and 
    A.subasientocodigo=X.subasientocodigo and 
	A.cabcomprobmes='+@mes+' And
	A.asientocodigo LIKE '''+@asiento+''''
Exec(@SqlCad)
GO
