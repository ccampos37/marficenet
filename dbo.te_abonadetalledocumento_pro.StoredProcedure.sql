SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [te_abonadetalledocumento_pro]
@base varchar(50),
@tipo char(1),
@numrecibo varchar(6),
@estadoreg varchar(1)='',
@item varchar(3)='',
@emisioncheque varchar(1)='',
@tipodocconcepto char(2)='',
@numdocumento varchar(15)='',
@carabo char(1)='',
@formacan char(1)='',
@tdqc char(2)='',
@ndqc varchar(15)='',
@tipocajabanco char(1)='',
@cajabanco char(2)='',
@numctacte char(30)='',
@adicionactacte char(1)='',
@monedadocumento char(2)='',
@monedacancela char(2)='',
@importesoles float=0,
@importedolares float=0,
@contabledisponi char(1)='',
@fechacancela varchar(10)='01/01/2000',
@observacion varchar(50)='',
@gastos varchar(20)='',
@usuario char(8)='',
@fechaact datetime='01/01/2000',
@entidad char(11)='',
@centrocosto varchar (10)='00',
@nosaldos varchar (1)='0',
@cliente varchar(11)='00'

As
Declare @ncadena as nvarchar(4000)
Declare @parame  as nvarchar(4000)
if @tipo=1
  Begin 
   set @ncadena=N'INSERT INTO ['+@base+'].dbo.te_detallerecibos
                  (cabrec_numrecibo,detrec_estadoreg,detrec_item,detrec_emisioncheque,
                   detrec_tipodoc_concepto,detrec_numdocumento,detrec_carabo,
                   detrec_forcan,detrec_tdqc,detrec_ndqc,detrec_tipocajabanco,
                   detrec_cajabanco1,detrec_numctacte,detrec_adicionactacte,
                   detrec_monedadocumento,detrec_monedacancela,detrec_importesoles,
                   detrec_importedolares,detrec_contadispo,detrec_fechacancela,
                   detrec_observacion,
                   detrec_gastos,usuariocodigo,fechaact,entidadcodigo,
		   centrocostocodigo,detalle_no_saldos, clientecodigo )
		
		VALUES(
			@numrecibo,
			@estadoreg,
			@item,
			@emisioncheque,
			@tipodocconcepto,
			@numdocumento,
			@carabo,
			@formacan,
			@tdqc,
			@ndqc,
			@tipocajabanco,
			@cajabanco,
			@numctacte,
			@adicionactacte,
			@monedadocumento,
			@monedacancela,
			@importesoles,
			@importedolares,
			@contabledisponi,
			@fechacancela,
			@observacion,
			@gastos,
			@usuario,
			@fechaact,
            @entidad,
			@centrocosto,
			@nosaldos,
			@cliente  )'           
   
	set @parame=N'@numrecibo varchar(6),
			@estadoreg varchar(1),
			@item varchar(3),
			@emisioncheque varchar(1),
			@tipodocconcepto char(2),
			@numdocumento varchar(15),
			@carabo char(1),
			@formacan char(1),
			@tdqc char(2),
			@ndqc varchar(15),
			@tipocajabanco char(1),
			@cajabanco char(2),
			@numctacte char(30),
			@adicionactacte char(1),
			@monedadocumento char(2),
			@monedacancela char(2),
			@importesoles float,
			@importedolares float,
			@contabledisponi char(1),
			@fechacancela datetime,
			@observacion varchar(50),
			@gastos varchar(20),
			@usuario char(8),
			@fechaact datetime,
			@entidad char(11),
			@centrocosto varchar(10),
			@nosaldos varchar(1) ,
			@cliente varchar(11) '
	Exec sp_executesql @ncadena,@parame,@numrecibo,
						@estadoreg,
						@item,
						@emisioncheque,
						@tipodocconcepto,
						@numdocumento,
						@carabo,
						@formacan,
						@tdqc,
						@ndqc,
						@tipocajabanco,
						@cajabanco,
						@numctacte,
						@adicionactacte,
						@monedadocumento,
						@monedacancela,
						@importesoles,
						@importedolares,
						@contabledisponi,
						@fechacancela,
						@observacion,
						@gastos,
						@usuario,
						@fechaact,
						@entidad,
						@centrocosto,
						@nosaldos,
						@cliente  
   end	
if @tipo=2
  Begin 
	
   set @ncadena=N'DELETE  ['+@base+'].[dbo].[te_detallerecibos]
       WHERE  cabrec_numrecibo=@numrecibo'
   
   set @parame=N'@numrecibo varchar(6)'
   Exec sp_executesql @ncadena,@parame,@numrecibo
  End
IF @tipo=3 --Recuperar los Datos
BEGIN
       set @parame=N'@numrecibo varchar(6)'
        SET @ncadena='Select item=detrec_item,
                     tipodoc_concepto=detrec_tipodoc_concepto,
                     numdocumento=detrec_numdocumento,
                     tdqc=detrec_tdqc,
                     ndqc=detrec_ndqc,
                     cajabanco1=detrec_cajabanco1,
                     numctacte=detrec_numctacte, 
                     monedadocumento=isnull(detrec_monedadocumento,''01''), 
                     monedacancela=isnull(detrec_monedacancela,''01''), 
                     importesoles=detrec_importesoles,
                     importedolares=detrec_importedolares,
					 fechacancela=detrec_fechacancela,
                     entidad=entidadcodigo,
                     costos=centrocostocodigo,
                     gastos=detrec_gastos,
					 observacion=detrec_observacion,
                     rendicionnumero=rendicionnumero,
                     clientecodigo=clientecodigo
                FROM ['+@base+'].dbo.te_detallerecibos 
                WHERE ( [cabrec_numrecibo] = @numrecibo ) '
   
execute sp_executesql @ncadena,@parame,@numrecibo
END
IF @tipo=4 -- Actualizacion de los Datos
BEGIN
        SET @ncadena='update ['+@base+'].dbo.te_detallerecibos
                      set detrec_tdqc='''+@tdqc+''',
                          detrec_ndqc='''+@ndqc+''',
   						  detrec_fechacancela='''+@fechacancela+''' ,
						  entidadcodigo='''+@entidad+''',
						  centrocostocodigo='''+@centrocosto+''',
                          detrec_gastos='''+@gastos+''',
					      detrec_observacion='''+@observacion+'''
                WHERE cabrec_numrecibo ='''+@numrecibo+''' and detrec_item='''+rtrim(@item)+'''  '
       execute ( @ncadena) 
END



--execute te_abonadetalledocumento_pro 'pacific_tacna','3','100023'
GO
