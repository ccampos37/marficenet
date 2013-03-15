SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [cp_abonadocumento_pro]
@base varchar(50),
@tipo char(1),
@tipoplanilla char(2),
@numplanilla char(6),
@documentoabono char(2),
@abononumdoc varchar(15),
@abonocantd char(2),
@abonocannro char(15),
@banco char(2),
@ctabanco char(30),
@fechapro datetime=null,
@abonocannumpag char(2)=null,
@zonacodigo char(3)=NULL,
@vendedor char(3)=NULL,
@fechapla datetime=null,
@moneda char(2)=NULL,
@abonocancarabo char(1)=NULL,
@cuenta varchar(20)=NULL,
@tipocam float=NULL,
@abonoflpres char(1)=null,
@abonocanimpcan float=0,
@abonocanimpsol float=0,
@usuario char(8)=null,
@fechaact datetime=null,
@forma char(1)=null,
@monedacan char(2)=null,
@fechacan datetime=null,
@cliente varchar(11)=null,
@empresa char(2)='01'

As
Declare @ncadena as nvarchar(4000)
Declare @parame  as nvarchar(4000)
	set @parame=N'@empresa char(2) ,
            @documentoabono char(2),
			@abononumdoc varchar(15),
			@abonocannumpag char(2),
			@zonacodigo char(3),
			@tipoplanilla char(2),
			@vendedor char(3),
			@numplanilla char(6),
			@fechapla datetime,
			@fechapro datetime,
			@moneda char(2),
			@abonocancarabo char(1),
			@cuenta varchar(20),
			@banco char(2),
			@ctabanco char(30),
			@tipocam float,		
			@abonocanimpcan float,
			@abonocanimpsol float,
			@usuario char(8),
			@fechaact datetime,
			@forma char(1),
			@monedacan char(2),
			@abonocantd char(2),
			@abonocannro char(15),
			@fechacan datetime,
			@cliente varchar(11),
			@abonoflpres char(1)'
if @tipo=1
  Begin 
   
   set @ncadena=N'Insert Into ['+@base+'].dbo.cp_abono
	               (empresacodigo,
			documentoabono,
			abononumdoc,
			abonocannumpag,
			zonacodigo,
			abonotipoplanilla,
			vendedorcodigo,
			abononumplanilla,
			abonocanfecpla,
			abonocanfecpro,
			abonocanmoneda,
			abonocancarabo,
			abonocancuenta,
			abonocanbco,
			abonocanctabco,
			abonocantipcam,	
			abonocanimpcan,
			abonocanimcan,
			abonocanimpsol,
			usuariocodigo,
			fechaact,
			abonocanforcan,
			abonocanmoncan,
			abonocantdqc,
			abonocanndqc,
			abonocanfecan,
			abonocancli,
			abonocanflpres)
		  Values ( @empresa ,
			@documentoabono,
			@abononumdoc,
			@abonocannumpag,
			@zonacodigo,
			@tipoplanilla,
			@vendedor,
			@numplanilla,
			@fechapla,
			@fechapro,
			@moneda,
			@abonocancarabo,
			@cuenta,
			@banco,
			@ctabanco,  
			@tipocam,
			@abonocanimpcan,
			@abonocanimpcan,
			@abonocanimpsol,
			@usuario,
			@fechaact,
			@forma,
			@monedacan,
			@abonocantd,
			@abonocannro,
			@fechacan,
			@cliente,
			@abonoflpres)'
   end	
IF @tipo=2 -- Modificar
BEGIN
	Set @ncadena='		
	Update '+'['+@base+'].dbo.cp_abono
              set abonocanndqc='''+rtrim(@abonocannro)+''',
                  abonocantdqc='''+rtrim(@abonocantd)+''',   
                  abonocanbco='''+@banco+''',
                  abonocanctabco='''+rtrim(@ctabanco)+'''
	      WHERE  empresacodigo ='''+@empresa+'''
                     and abonotipoplanilla='''+@tipoplanilla+''' 
                     and abononumplanilla='''+@numplanilla +'''
                     and documentoabono='''+@documentoabono+''' 
                     and abononumdoc='''+@abononumdoc+''''
execute(@ncadena)
END
Exec sp_executesql @ncadena,@parame,@empresa ,
                        @documentoabono,
						@abononumdoc,
						@abonocannumpag,
						@zonacodigo,
						@tipoplanilla,
						@vendedor,
						@numplanilla,
						@fechapla,
						@fechapro,
						@moneda,
						@abonocancarabo,
						@cuenta,
						@banco,
						@ctabanco,
						@tipocam,						
						@abonocanimpcan,
						@abonocanimpsol,
						@usuario,
						@fechaact,
						@forma,
						@monedacan,
						@abonocantd,
						@abonocannro,
						@fechacan,
						@cliente,
						@abonoflpres
---select * from pacific_tacna.dbo.cp_abono where abononumplanilla='000673' and abononumdoc='01100000590'
--- execute cp_abonadocumento_pro 'pacific_tacna',2,'TE','000673','04','01000001545','77','7777','00','000','01/07/06'
GO
