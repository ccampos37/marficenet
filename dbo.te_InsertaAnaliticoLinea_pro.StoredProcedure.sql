SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP Proc te_InsertaAnaliticoLinea_pro
CREATE   Proc [te_InsertaAnaliticoLinea_pro]
/*
  Autor    : Fernando Cossio Peralta 
  Objetivo : Insertar analitico si no lo encuentra
*/
--Declare
 @BaseConta varchar(50),
 @BaseVenta varchar(50), 
 @Compu     varchar(50),
 @Analitico varchar(15) output,
 @Ruc       varchar(11) output   
As
Declare @SqlCad varchar(8000),@Tipo varchar(1),@Tabla varchar(100)
Set @Sqlcad='Declare Tipo cursor for  
            (Select C.operacioncontrolaclienteprov
            From ['+@BaseVenta+'].dbo.te_cabecerarecibos A,
            (Select top 1 *  From [##tmpgenasientodet'+@Compu+'] ) B,
            ['+@BaseVenta+'].dbo.te_operaciongeneral C     
            Where A.cabrec_numrecibo=B.Numprovi and  
                  A.Operacioncodigo=C.operacioncodigo) '
EXECUTE(@Sqlcad) 
Open Tipo 
Fetch next from tipo into @Tipo
Close Tipo
Deallocate Tipo 
Set @Tabla=Case upper(@Tipo)
                When 'C' then 'vt_cliente'
                When 'P' then 'cp_proveedor'
                Else ''
           End 
Set @Analitico='00'
Set @Ruc=''
/*Insertar Entidad*/
If @Tabla <>''
Begin
	Set @SqlCad='
	Insert into ['+@BaseConta+'].dbo.ct_entidad 
	Select entidadcodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
	                     when ''00000000000'' then A.clientecodigo 
	                     When '''' Then A.clientecodigo
	                      else  A.clienteruc end,
	       entidadrazonsocial=left(A.clienterazonsocial,40), 
	       entidaddireccion=left(A.clientedireccion,25), 
	       entidadruc=A.clienteruc, 
	       entidadtelefono=A.clientetelefono, 
	       entidadtipocontri=''00'',
	       usuariocodigo=''Sys25'', 
	       fechaact=Getdate()     
	from ['+@BaseVenta+'].dbo.'+@Tabla+' A
	where A.clientecodigo in (
	select distinct left(analiticocodigo,11)  from [##tmpgenasientodet'+@Compu+'] ) and 
	case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
	when ''00000000000'' then A.clientecodigo 
	When '''' Then A.clientecodigo
	else  A.clienteruc end
	not in ( Select entidadcodigo from ['+@BaseConta+'].dbo.ct_entidad) '
	execute(@SqlCad)
	
	/*Insertar Analitico*/
    If exists(Select name From tempdb.dbo.sysobjects where name='##tmpanali'+@Compu) 
		Exec('Drop Table ##tmpanali'+@Compu)   
    
    Set @SqlCad='Select distinct   
				   analiticocodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
			                     when ''00000000000'' then A.clientecodigo 
			                     When '''' Then A.clientecodigo
			                     else  A.clienteruc end + B.TipoAnaliticocodigo,
				   entidadcodigo=case Rtrim(ltrim(isnull(A.clienteruc,''''))) 
			                     when ''00000000000'' then A.clientecodigo 
			                     When '''' Then A.clientecodigo
			                     else  A.clienteruc end,
			       tipoanaliticocodigo=B.TipoAnaliticocodigo,       
			       usuariocodigo=''Sys25'',
			       fechaact=getdate(),
                   Ruc=isnull(A.clienteruc,'''')         
            Into  ##tmpanali'+@Compu+'      
			from  ['+@BaseVenta+'].dbo.'+@Tabla+' A,     
			      (select A.AnaliticoCodigo, B.TipoAnaliticocodigo
			      from [##tmpgenasientodet'+@Compu+'] A,['+@BaseConta+'].dbo.ct_cuenta  B
			      Where A.cuentacodigo=B.cuentacodigo and isnull(B.cuentaestadoanalitico,0)=1 ) B 
			where A.clientecodigo=B.AnaliticoCodigo and  
			      A.clientecodigo in (
			         select distinct left(analiticocodigo,15)  from [##tmpgenasientodet'+@Compu+'] )'    
    Exec(@SqlCad)
	Set @SqlCad='
	insert into ['+@BaseConta+'].dbo.ct_analitico
	Select analiticocodigo,entidadcodigo,tipoanaliticocodigo,usuariocodigo,fechaact
    from ##tmpanali'+@Compu+' 
	where analiticocodigo not in (select analiticocodigo from ['+@BaseConta+'].dbo.ct_analitico) '
	Exec(@SqlCad)
	
	--Recuperando el Analitico 
	Set @SqlCad='Declare analitico cursor for Select Top 1 analiticocodigo,ruc from ##tmpanali'++@Compu+''
    Exec(@SqlCad)
    Open analitico
	Fetch next from analitico into @Analitico,@Ruc 
	Close analitico
	Deallocate analitico   
End
GO
