SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Function [fn_FormatoNumDoc](@NumeroComprob varchar(30))
returns  varchar(30)
as
Begin
Declare @Resultcomprob varchar(30) 
Declare @lenDato bigint
Declare @Serie varchar(4),@NDocumento varchar(10)
declare @tipo bigint
set @tipo=isnumeric(@NumeroComprob)
set @lendato = len(@NumeroComprob)
If @tipo=1
   Begin
   If @LenDato <=3
   begin
     Set @serie='   '
     set @NDocumento=@NumeroComprob
   End
   If @LenDato >3 and @lendato <=10 
   Begin
     Set @Serie=left(@NumeroComprob,3)   
     Set @NDocumento=right(ltrim(rtrim(@NumeroComprob)),len(ltrim(rtrim(@NumeroComprob)))-3)
   End
   If @LenDato =11 
   Begin
     Set @Serie=left(@NumeroComprob,4)   
     Set @NDocumento=right(ltrim(rtrim(@NumeroComprob)),7)
   End
   If @LenDato <=14 and @lenDato >11 
   Begin
     Set @Serie=left(@NumeroComprob,4)   
     Set @NDocumento=right(ltrim(rtrim(@NumeroComprob)),len(ltrim(rtrim(@NumeroComprob)))-4)
   End
  Set @Resultcomprob=@Serie+' - '+@NDocumento
  End 
Else  
Begin
  Set @Resultcomprob=@NumeroComprob
End
Return @Resultcomprob
End
GO
