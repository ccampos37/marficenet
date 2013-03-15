SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [co_estalistaocc_rpt]
--Declare 
	@Base Varchar(100),
	@Estado varchar(1)
as
Declare @SqlCad varchar(4000)
Set @SqlCad='
	Select a.*, b.*, 
    Descripcion=
       case a.CompraTipo
           when 1 then ( Select HiloDescripcion from ['+@base+'].dbo.[Maestro Hilos] d where  d.HiloCodigo=b.codigo )
           when 2 then ( Select TelaCrudaDescripcion from ['+@base+'].dbo.[Maestro Tela Cruda] d where  d.TelaCrudaID=b.codigo )
           when 5 then ( Select QuimicoDescripcion from ['+@base+'].dbo.[Maestro Quimicos] d where  d.QuimicoId=b.codigo )
       end,      
    ContactoNombres=isnull(c.clienterazonsocial,''''),
    ContactoDireccion=isnull(c.clientedireccion,''''),ContactoTelefonos=isnull(c.clientetelefono,'''') ,
    ContactoRuc=isnull(c.clienteruc,''''),contactoFaxes=isnull(clientefax,'''') , 
	e.UnidadMedida as UAlma, e.UnidadMedida2 as UCompr,	Factor = case UnidadOperador when ''m'' then unidaddimension else 1/unidaddimension end,
	f.PagoCondDescripcion, 	MonedaNomb = case a.moneda when 1 then ''Soles'' else ''Dolares'' end, g.Fecha as CronoFech, g.Cant as CronCant,
    Estado=Case a.estado 
              when 1 then ''Pendiente'' 
              when 2 then ''Parcialm. Atendido'' 
              when 3 then ''Atendido''
           End
	from  ['+@base+'].dbo.OrdenCompra a INNER JOIN
    ['+@base+'].dbo.OrdenCompraDetalle b ON a.OrdenNro = b.OrdenNro INNER JOIN
    ventas_prueba.dbo.[cp_proveedor] c ON a.ContactoNro collate Modern_Spanish_CI_AI = c.clientecodigo collate Modern_Spanish_CI_AI INNER JOIN
    ['+@base+'].dbo.Unidades e ON b.Um = e.UnidadMedidaID  INNER JOIN
    ['+@base+'].dbo.PagoCondicion f ON a.PagoCondId = f.PagoCondId LEFT OUTER JOIN
    ['+@base+'].dbo.OrdenCompraCronograma g ON b.OrdenNro = g.OrdenNro AND b.Item = g.Item
    WHERE Estado='+@Estado    
Exec(@SqlCad)
GO
