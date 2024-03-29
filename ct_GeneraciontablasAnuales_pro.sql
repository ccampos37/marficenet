SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

execute [ct_GeneraciontablasAnuales_pro] 'empresax','2013','2012'

*/
ALTER proc [ct_GeneraciontablasAnuales_pro]
(
@base varchar(50),
@aaaa varchar(4),
@nnnn varchar(4)
) 
as

declare @sql varchar(8000)
set @sql=' use '+@base+' 
go '

execute(@sql)

set @sql=' IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''ct_cabcomprob'+@aaaa+''' and type = ''U'')   
            CREATE TABLE '+@base+'.[dbo].[ct_cabcomprob'+@aaaa+'](
	[empresacodigo] [nvarchar](2) NOT NULL,
	[cabcomprobmes] [int] NOT NULL,
	[asientocodigo] [char](3) NOT NULL,
	[subasientocodigo] [char](4) NOT NULL,
	[cabcomprobnumero] [char](10) NOT NULL,
	[cabcomprobfeccontable] [datetime] NOT NULL,
	[usuariocodigo] [nchar](8) NOT NULL,
	[estcomprobcodigo] [char](2) NULL,
	[cabcomprobobservaciones] [varchar](150) NULL,
	[fechaact] [datetime] NULL,
	[cabcomprobglosa] [varchar](30) NOT NULL,
	[cabcomprobtotdebe] [numeric](20, 4) NOT NULL,
	[cabcomprobtothaber] [numeric](20, 4) NOT NULL,
	[cabcomprobtotussdebe] [numeric](20, 4) NOT NULL,
	[cabcomprobtotusshaber] [numeric](20, 4) NOT NULL,
	[cabcomprobgrabada] [bit] NULL,
	[cabcomprobnref] [varchar](20) NULL,
	[cabcomprobnlibro] [varchar](10) NULL,
	[cabcomprobnprovi] [varchar](20) NULL,
 CONSTRAINT [PK_ct_cabcomprob'+@aaaa+'] PRIMARY KEY CLUSTERED 
(
	[empresacodigo] ASC,
	[cabcomprobmes] ASC,
	[asientocodigo] ASC,
	[subasientocodigo] ASC,
	[cabcomprobnumero] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] '

execute( @sql)




/****** Object:  Table '+@base+'.[dbo].[ct_detcomprob''+@aaaa+'']    Script Date: 01/03/''+@aaaa+'' 10:59:35 ******/


set @sql=' IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''ct_detcomprob'+@aaaa+''' and type = ''U'') 
     CREATE TABLE '+@base+'.[dbo].[ct_detcomprob'+@aaaa+'](
	[empresacodigo] [nvarchar](2) NOT NULL,
	[cabcomprobmes] [int] NOT NULL,
	[asientocodigo] [char](3) NOT NULL,
	[subasientocodigo] [char](4) NOT NULL,
	[cabcomprobnumero] [char](10) NOT NULL,
	[detcomprobitem] [char](5) NOT NULL,
	[analiticocodigo] [char](15) NULL,
	[monedacodigo] [char](2) NOT NULL,
	[centrocostocodigo] [nvarchar](10) NOT NULL,
	[documentocodigo] [char](2) NOT NULL,
	[operacioncodigo] [char](2) NOT NULL,
	[cuentacodigo] [varchar](20) NOT NULL,
	[detcomprobnumdocumento] [varchar](50) NULL,
	[detcomprobfechaemision] [datetime] NOT NULL,
	[detcomprobfechavencimiento] [datetime] NULL,
	[detcomprobglosa] [nvarchar](50) NOT NULL,
	[detcomprobdebe] [decimal](20, 4) NOT NULL,
	[detcomprobhaber] [decimal](20, 4) NOT NULL,
	[detcomprobusshaber] [decimal](20, 4) NOT NULL,
	[detcomprobussdebe] [decimal](20, 4) NOT NULL,
	[detcomprobtipocambio] [decimal](20, 4) NOT NULL,
	[detcomprobruc] [char](13) NULL,
	[detcomprobauto] [bit] NOT NULL,
	[detcomprobformacambio] [char](2) NULL,
	[detcomprobajusteuser] [bit] NULL,
	[plantillaasientoinafecto] [bit] NULL,
	[tipdocref] [char](2) NULL,
	[detcomprobnumref] [varchar](20) NULL,
	[detcomprobconci] [int] NULL,
	[detcomprobnlibro] [varchar](10) NULL,
	[detcomprobfecharef] [datetime] NULL,
	[detcomprobnumerodetraccion] [varchar](20) NULL,
	[detcomprobfechadetraccion] [datetime] NULL,
 CONSTRAINT [PK_ct_detcomprob'+@aaaa+'] PRIMARY KEY CLUSTERED 
(
	[empresacodigo] ASC,
	[cabcomprobmes] ASC,
	[asientocodigo] ASC,
	[subasientocodigo] ASC,
	[cabcomprobnumero] ASC,
	[detcomprobitem] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] '
execute(@sql)

set @sql='  IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''FK_ct_detcomprob'+@aaaa+'_ct_cabcomprob'+@aaaa+''' )
           ALTER TABLE '+@base+'.[dbo].[ct_detcomprob'+@aaaa+']  WITH CHECK ADD  CONSTRAINT [FK_ct_detcomprob'+@aaaa+'_ct_cabcomprob'+@aaaa+'] 
           FOREIGN KEY([empresacodigo], [cabcomprobmes],[asientocodigo], [subasientocodigo], [cabcomprobnumero])
            REFERENCES '+@base+'.[dbo].[ct_cabcomprob'+@aaaa+'] ([empresacodigo], [cabcomprobmes], [asientocodigo], [subasientocodigo], [cabcomprobnumero])
           ON UPDATE CASCADE
           ON DELETE CASCADE '
      
 execute(@sql)

set @sql=' ALTER TABLE '+@base+'.[dbo].[ct_detcomprob'+@aaaa+'] CHECK CONSTRAINT [FK_ct_detcomprob'+@aaaa+'_ct_cabcomprob'+@aaaa+']
           ALTER TABLE '+@base+'.[dbo].[ct_detcomprob'+@aaaa+'] ADD  DEFAULT ('''') FOR [detcomprobnumerodetraccion] '

execute(@sql)

   set @sql=' IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''ct_ctacteanalitico'+@aaaa+''' and type = ''U'') 
    CREATE TABLE '+@base+'.[dbo].[ct_ctacteanalitico'+@aaaa+'](
	[empresacodigo] [nvarchar](2) NULL,
	[cabcomprobmes] [int] NOT NULL,
	[asientocodigo] [char](3) NOT NULL,
	[subasientocodigo] [char](4) NOT NULL,
	[cabcomprobnumero] [char](10) NOT NULL,
	[detcomprobitem] [char](5) NOT NULL,
	[documentocodigo] [char](2) NOT NULL,
	[operacioncodigo] [char](2) NULL,
	[cuentacodigo] [varchar](20) NOT NULL,
	[ctacteanaliticofechaconta] [datetime] NOT NULL,
	[analiticocodigo] [char](15) NOT NULL,
	[ctacteanaliticonumdocumento] [varchar](23) NOT NULL,
	[ctacteanaliticofechadoc] [datetime] NOT NULL,
	[ctacteanaliticoglosa] [varchar](60) NULL,
	[ctacteanaliticodebe] [numeric](20, 4) NOT NULL,
	[ctacteanaliticoussdebe] [numeric](20, 4) NOT NULL,
	[ctacteanaliticohaber] [numeric](20, 4) NOT NULL,
	[ctacteanaliticousshaber] [numeric](20, 4) NOT NULL,
	[ctacteanaliticocancel] [varchar](6) NULL,
	[ctacteanaliticofechaven] [datetime] NULL,
	[monedacodigo] [char](2) NULL,
	[fechaact] [datetime] NULL,
	[ctacteanaliticoajustedifcambio] [char](1) NULL
    ) ON [PRIMARY] '
  execute(@sql)

  set @sql=' ALTER TABLE '+@base+'.[dbo].[ct_ctacteanalitico'+@aaaa+'] ADD  DEFAULT (getdate()) FOR [fechaact] 
             ALTER TABLE '+@base+'.[dbo].[ct_ctacteanalitico'+@aaaa+'] ADD  DEFAULT ((0)) FOR [ctacteanaliticoajustedifcambio] '
  execute (@sql)

  set @sql=' IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''ct_gastos'+@aaaa+''' and type = ''U'') 
    CREATE TABLE '+@base+'.[dbo].[ct_gastos'+@aaaa+'](
	[empresacodigo] [nvarchar](2) NOT NULL,
	[cuentacodigo] [nvarchar](20) NOT NULL,
	[centrocostocodigo] [nvarchar](10) NOT NULL,
	[gastos00] [decimal](20, 4) NOT NULL,
	[gastosuss00] [decimal](20, 4) NOT NULL,
	[gastos01] [decimal](20, 4) NOT NULL,
	[gastosacum01] [decimal](20, 4) NOT NULL,
	[gastosuss01] [decimal](20, 4) NOT NULL,
	[gastosacumuss01] [decimal](20, 4) NOT NULL,
	[gastos02] [decimal](20, 4) NOT NULL,
	[gastosacum02] [decimal](20, 4) NOT NULL,
	[gastosuss02] [decimal](20, 4) NOT NULL,
	[gastosacumuss02] [decimal](20, 4) NOT NULL,
	[gastos03] [decimal](20, 4) NOT NULL,
	[gastosacum03] [decimal](20, 4) NOT NULL,
	[gastosuss03] [decimal](20, 4) NOT NULL,
	[gastosacumuss03] [decimal](20, 4) NOT NULL,
	[gastos04] [decimal](20, 4) NOT NULL,
	[gastosacum04] [decimal](20, 4) NOT NULL,
	[gastosuss04] [decimal](20, 4) NOT NULL,
	[gastosacumuss04] [decimal](20, 4) NOT NULL,
	[gastos05] [decimal](20, 4) NOT NULL,
	[gastosacum05] [decimal](20, 4) NOT NULL,
	[gastosuss05] [decimal](20, 4) NOT NULL,
	[gastosacumuss05] [decimal](20, 4) NOT NULL,
	[gastos06] [decimal](20, 4) NOT NULL,
	[gastosacum06] [decimal](20, 4) NOT NULL,
	[gastosuss06] [decimal](20, 4) NOT NULL,
	[gastosacumuss06] [decimal](20, 4) NOT NULL,
	[gastos07] [decimal](20, 4) NOT NULL,
	[gastosacum07] [decimal](20, 4) NOT NULL,
	[gastosuss07] [decimal](20, 4) NOT NULL,
	[gastosacumuss07] [decimal](20, 4) NOT NULL,
	[gastos08] [decimal](20, 4) NOT NULL,
	[gastosacum08] [decimal](20, 4) NOT NULL,
	[gastosuss08] [decimal](20, 4) NOT NULL,
	[gastosacumuss08] [decimal](20, 4) NOT NULL,
	[gastos09] [decimal](20, 4) NOT NULL,
	[gastosacum09] [decimal](20, 4) NOT NULL,
	[gastosuss09] [decimal](20, 4) NOT NULL,
	[gastosacumuss09] [decimal](20, 4) NOT NULL,
	[gastos10] [decimal](20, 4) NOT NULL,
	[gastosacum10] [decimal](20, 4) NOT NULL,
	[gastosuss10] [decimal](20, 4) NOT NULL,
	[gastosacumuss10] [decimal](20, 4) NOT NULL,
	[gastos11] [decimal](20, 4) NOT NULL,
	[gastosacum11] [decimal](20, 4) NOT NULL,
	[gastosuss11] [decimal](20, 4) NOT NULL,
	[gastosacumuss11] [decimal](20, 4) NOT NULL,
	[gastos12] [decimal](20, 4) NOT NULL,
	[gastosacum12] [decimal](20, 4) NOT NULL,
	[gastosuss12] [decimal](20, 4) NOT NULL,
	[gastosacumuss12] [decimal](20, 4) NOT NULL,
	[usuariocodigo] [nchar](8) NOT NULL,
	[fechaact] [datetime] NOT NULL,
    CONSTRAINT [PK_ct_gastos'+@aaaa+'] PRIMARY KEY CLUSTERED 
    (
	[empresacodigo] ASC,
	[cuentacodigo] ASC,
	[centrocostocodigo] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
    ) ON [PRIMARY] '
  execute (@sql)  

  set @sql= ' ALTER TABLE '+@base+'.[dbo].[ct_gastos'+@aaaa+'] ADD  CONSTRAINT [DF_ct_gastos'+@aaaa+'_usuariocodigo]  DEFAULT (''sa'') FOR [usuariocodigo] 
              ALTER TABLE '+@base+'.[dbo].[ct_gastos'+@aaaa+'] ADD  CONSTRAINT [DF_ct_gastos'+@aaaa+'_fechaact]  DEFAULT (getdate()) FOR [fechaact] '
  execute(@sql)

   set @sql='  IF NOT EXISTS (SELECT * FROM '+@base+'.sys.objects  WHERE name=''ct_saldos'+@aaaa+''' and type = ''U'') 
    CREATE TABLE '+@base+'.[dbo].[ct_saldos'+@aaaa+'](
	[empresacodigo] [nvarchar](2) NOT NULL,
	[cuentacodigo] [varchar](20) NOT NULL,
	[saldodebe00] [dbo].[numvalor] NOT NULL,
	[saldohaber00] [dbo].[numvalor] NOT NULL,
	[saldoussdebe00] [dbo].[numvalor] NOT NULL,
	[saldousshaber00] [dbo].[numvalor] NOT NULL,
	[saldodebe01] [dbo].[numvalor] NOT NULL,
	[saldohaber01] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe01] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber01] [dbo].[numvalor] NOT NULL,
	[saldoussdebe01] [dbo].[numvalor] NOT NULL,
	[saldousshaber01] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe01] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber01] [dbo].[numvalor] NOT NULL,
	[saldodebe02] [dbo].[numvalor] NOT NULL,
	[saldohaber02] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe02] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber02] [dbo].[numvalor] NOT NULL,
	[saldoussdebe02] [dbo].[numvalor] NOT NULL,
	[saldousshaber02] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe02] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber02] [dbo].[numvalor] NOT NULL,
	[saldodebe03] [dbo].[numvalor] NOT NULL,
	[saldohaber03] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe03] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber03] [dbo].[numvalor] NOT NULL,
	[saldoussdebe03] [dbo].[numvalor] NOT NULL,
	[saldousshaber03] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe03] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber03] [dbo].[numvalor] NOT NULL,
	[saldodebe04] [dbo].[numvalor] NOT NULL,
	[saldohaber04] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe04] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber04] [dbo].[numvalor] NOT NULL,
	[saldoussdebe04] [dbo].[numvalor] NOT NULL,
	[saldousshaber04] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe04] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber04] [dbo].[numvalor] NOT NULL,
	[saldodebe05] [dbo].[numvalor] NOT NULL,
	[saldohaber05] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe05] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber05] [dbo].[numvalor] NOT NULL,
	[saldoussdebe05] [dbo].[numvalor] NOT NULL,
	[saldousshaber05] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe05] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber05] [dbo].[numvalor] NOT NULL,
	[saldodebe06] [dbo].[numvalor] NOT NULL,
	[saldohaber06] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe06] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber06] [dbo].[numvalor] NOT NULL,
	[saldoussdebe06] [dbo].[numvalor] NOT NULL,
	[saldousshaber06] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe06] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber06] [dbo].[numvalor] NOT NULL,
	[saldodebe07] [dbo].[numvalor] NOT NULL,
	[saldohaber07] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe07] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber07] [dbo].[numvalor] NOT NULL,
	[saldoussdebe07] [dbo].[numvalor] NOT NULL,
	[saldousshaber07] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe07] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber07] [dbo].[numvalor] NOT NULL,
	[saldodebe08] [dbo].[numvalor] NOT NULL,
	[saldohaber08] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe08] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber08] [dbo].[numvalor] NOT NULL,
	[saldoussdebe08] [dbo].[numvalor] NOT NULL,
	[saldousshaber08] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe08] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber08] [dbo].[numvalor] NOT NULL,
	[saldodebe09] [dbo].[numvalor] NOT NULL,
	[saldohaber09] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe09] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber09] [dbo].[numvalor] NOT NULL,
	[saldoussdebe09] [dbo].[numvalor] NOT NULL,
	[saldousshaber09] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe09] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber09] [dbo].[numvalor] NOT NULL,
	[saldodebe10] [dbo].[numvalor] NOT NULL,
	[saldohaber10] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe10] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber10] [dbo].[numvalor] NOT NULL,
	[saldoussdebe10] [dbo].[numvalor] NOT NULL,
	[saldousshaber10] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe10] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber10] [dbo].[numvalor] NOT NULL,
	[saldodebe11] [dbo].[numvalor] NOT NULL,
	[saldohaber11] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe11] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber11] [dbo].[numvalor] NOT NULL,
	[saldoussdebe11] [dbo].[numvalor] NOT NULL,
	[saldousshaber11] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe11] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber11] [dbo].[numvalor] NOT NULL,
	[saldodebe12] [dbo].[numvalor] NOT NULL,
	[saldohaber12] [dbo].[numvalor] NOT NULL,
	[saldoacumdebe12] [dbo].[numvalor] NOT NULL,
	[saldoacumhaber12] [dbo].[numvalor] NOT NULL,
	[saldoussdebe12] [dbo].[numvalor] NOT NULL,
	[saldousshaber12] [dbo].[numvalor] NOT NULL,
	[saldoacumussdebe12] [dbo].[numvalor] NOT NULL,
	[saldoacumusshaber12] [dbo].[numvalor] NOT NULL,
	[usuariocodigo] [nvarchar](8) NOT NULL,
	[fechaact] [datetime] NOT NULL,
	[saldoacumdebe00] [float] NULL,
	[saldoacumhaber00] [float] NULL,
	[saldoacumussdebe00] [float] NULL,
	[saldoacumussHaber00] [float] NULL,
 CONSTRAINT [PK_ct_saldos'+@aaaa+'] PRIMARY KEY CLUSTERED 
(
	[empresacodigo] ASC,
	[cuentacodigo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] '

execute(@sql)


set @sql='  insert '+@base+'.[dbo].ct_librocorre ( empresacodigo,librocodigo,libroanno )
           select empresacodigo,librocodigo,'''+@aaaa+''' from '+@base+'.[dbo].ct_librocorre where libroanno='''+@nnnn+'''
           and empresacodigo+librocodigo+'''+@aaaa+''' not in 
           ( select empresacodigo+librocodigo+libroanno from '+@base+'.[dbo].ct_librocorre where libroanno='''+@aaaa+''' )

            insert '+@base+'.[dbo].ct_asientocorre ( empresacodigo,asientocodigo,asientoanno )
            select empresacodigo,asientocodigo,'''+@aaaa+''' from '+@base+'.[dbo].ct_asientocorre where asientoanno='''+@nnnn +'''
            and empresacodigo+asientocodigo+'''+@aaaa+''' not in 
           ( select empresacodigo+asientocodigo+asientoanno from '+@base+'.[dbo].ct_asientocorre where asientoanno='''+@aaaa+''' ) '

execute(@sql)


/****** Object:  Trigger [dbo].[tri_insertaranalitico''+@aaaa+'']    Script Date: 01/03/''+@aaaa+'' 10:59:36 ******/

set @sql='CREATE TRIGGER  '+@base+'.[dbo].[tri_insertaranalitico'+@aaaa+']  ON '+@base+'.[dbo].[ct_detcomprob'+@aaaa+']
    FOR INSERT,delete,update
    AS
    Declare @Fecha datetime
    delete dbo.ct_ctacteanalitico'+@aaaa+'
    from deleted a 
    inner join ct_ctacteanalitico'+@aaaa+'  d  on a.empresacodigo=d.empresacodigo and 
           A.cabcomprobmes=d.cabcomprobmes and 
           A.cabcomprobnumero=d.cabcomprobnumero and 
           a.detcomprobitem=d.detcomprobitem
    Insert dbo.ct_ctacteanalitico'+@aaaa+'
    (empresacodigo,cabcomprobmes, detcomprobitem, cabcomprobnumero, subasientocodigo, asientocodigo, documentocodigo, operacioncodigo, cuentacodigo, 
 ctacteanaliticofechaconta, analiticocodigo, ctacteanaliticonumdocumento, ctacteanaliticofechadoc, ctacteanaliticoglosa, ctacteanaliticodebe, 
 ctacteanaliticoussdebe, ctacteanaliticohaber, ctacteanaliticousshaber, ctacteanaliticocancel, ctacteanaliticofechaven,monedacodigo)
select 
   d.empresacodigo,d.cabcomprobmes,d.detcomprobitem, d.cabcomprobnumero, d.subasientocodigo, d.asientocodigo,d.documentocodigo,
   d.operacioncodigo,d.cuentacodigo, b.cabcomprobfeccontable, d.analiticocodigo, d.detcomprobnumdocumento,d.detcomprobfechaemision,
   Case When isnull(d.detcomprobglosa,'''')='''' Then b.cabcomprobglosa Else d.detcomprobglosa End , d.detcomprobdebe,
   d.detcomprobussdebe, d.detcomprobhaber,d.detcomprobusshaber,0,d.detcomprobfechavencimiento,d.monedacodigo
from inserted d 
inner join ct_cabcomprob'+@aaaa+'  b  on d.empresacodigo=b.empresacodigo and d.cabcomprobmes=B.cabcomprobmes and d.asientocodigo=B.asientocodigo and 
                     d.subasientocodigo=B.subasientocodigo and d.cabcomprobnumero=B.cabcomprobnumero 
inner join ct_cuenta C on d.empresacodigo = c.empresacodigo and d.cuentacodigo=c.cuentacodigo
where  not (analiticocodigo =''00'' or analiticocodigo is null or rtrim(analiticocodigo)='''' ) and 
            not (documentocodigo =''00'' or  documentocodigo is null or rtrim(documentocodigo)='''' )  and  
            not      (rtrim(detcomprobnumdocumento)=''''  or detcomprobnumdocumento is null) 
           and c.cuentaestadoanalitico=1  and (detcomprobdebe + detcomprobhaber) >0 
  end  '
          
execute(@sql) 

set @sql=' CREATE TRIGGER  '+@base+'.[dbo].[tri_insertarCuentaporPagar'+@aaaa+']  ON '+@base+'.[dbo].[ct_detcomprob'+@aaaa+']
FOR INSERT,delete
AS

Declare @ManejaAnalitico as varchar(1)
Declare @AdicionaCargo as char(1)
Declare @CabNumero as varchar(5)
Declare @detcomprobauto as bit
Declare @subasientocodigo as varchar(4)
Declare @operacioncodigo as varchar(2)
Declare @ExisteCliente as varchar(11)
Declare @AsientoCargo as varchar(3)
--Datos
Declare @empresacodigo as varchar(2)
Declare @documentocodigo as varchar(2)
Declare @detcomprobnumdocumento as varchar(50)
Declare @detcomprobfechaemision as datetime 
Declare @monedacodigo as varchar(2)
Declare @detcomprobdebe as decimal(20,4)
Declare @detcomprobtipocambio as decimal(20,4)
Declare @detcomprobglosa as nvarchar(50)
Declare @Fecha as smalldatetime 
Declare @Clientecodigo as varchar(11)


Select @ManejaAnalitico=a.cuentaestadoanalitico,@AdicionaCargo=a.cuentaadicionacargo 
From ct_cuenta a Inner Join Inserted b On  a.cuentacodigo=b.cuentacodigo And a.empresacodigo=b.empresacodigo
Select @detcomprobauto=h.detcomprobauto,@subasientocodigo=h.subasientocodigo,@operacioncodigo=h.operacioncodigo From Inserted h 
Select @AsientoCargo=a.asientoadicionacargo From ct_asiento a Inner Join Inserted b On a.asientocodigo=b.asientocodigo

Select @empresacodigo=empresacodigo,@documentocodigo=x.documentocodigo,@detcomprobnumdocumento=x.detcomprobnumdocumento,
    @detcomprobfechaemision=x.detcomprobfechaemision,
	@monedacodigo=x.monedacodigo,@detcomprobdebe=x.detcomprobhaber,@detcomprobtipocambio=x.detcomprobtipocambio,@detcomprobglosa=x.detcomprobglosa,
	@CabNumero=right(x.cabcomprobnumero,5) From Inserted x
Select @Clientecodigo=c.entidadcodigo From ct_analitico c Inner Join Inserted d On rtrim(ltrim(c.analiticocodigo))=rtrim(ltrim(d.analiticocodigo))
Select @ExisteCliente=isnull(clientecodigo,'''') From cp_proveedor Where clientecodigo=@Clientecodigo
If @ExisteCliente='''' Or @ExisteCliente is null
  Begin
     Insert Into cp_proveedor(clientecodigo,clienteruc,clienterazonsocial,clientetipopersona,clientetipopais,usuariocodigo,fechaact)
     Select entidadcodigo,entidadruc,entidadrazonsocial,''1'',''1'',''sa'',getdate() From ct_entidad Where entidadcodigo=@Clientecodigo
  End

Set @Fecha=getdate()

If (@detcomprobauto=''0'' And @subasientocodigo<>''0099'' And @operacioncodigo=''01'' And @AdicionaCargo=''1'' And @ManejaAnalitico=''1'' And @AsientoCargo=''1'' )
  Begin
      execute [marficeNet].[dbo].[cp_ingresacargo_pro] '+@base +',1,@empresacodigo,cp_cargo,@documentocodigo,@detcomprobnumdocumento,@Clientecodigo,''001'',
      Null,@detcomprobfechaemision,@monedacodigo,@detcomprobdebe,''sa'',@detcomprobtipocambio,@Fecha,''0'',''C'',Null,''CT'',@CabNumero,@detcomprobglosa
  End '
execute ( @sql)
   set @sql='  ALTER TABLE '+@base+'.[dbo].[ct_saldos'+@aaaa+'] ADD  CONSTRAINT [DF_ct_saldos'+@aaaa+'_usuariocodigo]  DEFAULT (''sa'') FOR [usuariocodigo]
               ALTER TABLE '+@base+'.[dbo].[ct_saldos'+@aaaa+'] ADD  CONSTRAINT [DF_ct_saldos'+@aaaa+'_fechaact]  DEFAULT (getdate()) FOR [fechaact] '
execute(@sql)


set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastos12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacum12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosuss12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_gastos'+@aaaa+'].[gastosacumuss12]'' , @futureonly=''futureonly'' '
execute(@sql)


/****** Object:  Table '+@base+'.[dbo].[ct_saldos''+@aaaa+'']    Script Date: 01/03/''+@aaaa+'' 11:16:05 ******/

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber01]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber02]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber03]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber04]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber05]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber06]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber07]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber08]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber09]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber10]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber11]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldodebe12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldohaber12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoussdebe12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldousshaber12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumusshaber12]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumdebe00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumhaber00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussdebe00]'' , @futureonly=''futureonly'' '
execute(@sql)

set @sql=' EXEC sys.sp_bindefault @defname=N''[dbo].[ceros]'', @objname=N'''+@base+'.[dbo].[ct_saldos'+@aaaa+'].[saldoacumussHaber00]'' , @futureonly=''futureonly'' '
execute(@sql)

