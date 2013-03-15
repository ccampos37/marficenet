SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Function [fn_conviertenumdoc](@NumeroComprob varchar(30))
returns  varchar(30)
as
Begin
Declare @Resultcomprob varchar(30) 
---Set @NumeroComprob='1-1545'
Declare @Serie varchar(3),@NDocumento varchar(8)
Set @Serie=case when isnumeric(left(@NumeroComprob,charindex('-',@NumeroComprob)-1))=1
                then replicate('0',3-len(left(@NumeroComprob,charindex('-',@NumeroComprob)-1)))+
                     rtrim(ltrim(left(@NumeroComprob,charindex('-',@NumeroComprob)-1)))   
                Else rtrim(left(@NumeroComprob,charindex('-',@NumeroComprob)-1))
                End  
Set @NDocumento=case when isnumeric(right(@NumeroComprob,len(@NumeroComprob)-charindex('-',@NumeroComprob)))=1
                Then replicate('0',8-len(ltrim(right(ltrim(rtrim(@NumeroComprob)),len(ltrim(rtrim(@NumeroComprob)))-charindex('-',@NumeroComprob)))))+
                     ltrim(right(rtrim(@NumeroComprob),len(ltrim(rtrim(@NumeroComprob)))-charindex('-',@NumeroComprob)))  
		Else right(ltrim(rtrim(@NumeroComprob)),len(ltrim(rtrim(@NumeroComprob)))-charindex('-',@NumeroComprob))
                End
Set @Resultcomprob=@Serie+@NDocumento
Return @Resultcomprob
End
GO
