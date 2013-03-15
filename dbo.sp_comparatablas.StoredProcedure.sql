SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
execute [sp_comparatablas] 'agro2000','ziyaz','%%',1

*/
CREATE proc [sp_comparatablas]
(
@base1 varchar(50),
@base2 varchar(50),
@tabla varchar(50)='%%',
@compara integer=0  --- 0: todo 1: todo existente , 2: diferente campos , 3: diferente tipode campos 
) as
declare @sql as varchar(4000)
declare @tipo as integer
if @base2<>'%%'  set @tipo=2
   set @sql=' select * from 
            ( SELECT so.name AS Tabla,sc.name AS Columna,st.name AS Tipo,
              Tamaño=case when st.name=''nvarchar''  then sc.max_length/2 else sc.max_length end , 
             ansi=sc.collation_name , nulo=sc.is_nullable 
             FROM '+@base1+'.sys.objects so 
             INNER JOIN  '+@base1+'.sys.columns sc ON so.object_id = sc.object_id 
             INNER JOIN '+@base1+'.sys.types st ON st.system_type_id = sc.system_type_id AND st.name != ''sysname''
             WHERE so.type = ''U'' '
             if @tabla<>''  set @sql=@sql+ ' and UPPER(so.name) like '''+@tabla+'''  
            ) a '
if @tipo=2 
   Begin            
if @compara=0  set @sql=@sql + 'full join '
if @compara<>0  set @sql=@sql + 'left join '
       set @sql=@sql +'( SELECT so.name AS Tabla,sc.name AS Columna,st.name AS Tipo,
             Tamaño=case when st.name=''nvarchar''  then sc.max_length/2 else sc.max_length end , 
			 ansi=sc.collation_name , nulo=sc.is_nullable 
              FROM '+@base2+'.sys.objects so 
              INNER JOIN  '+@base2+'.sys.columns sc ON so.object_id = sc.object_id 
              INNER JOIN '+@base2+'.sys.types st ON st.system_type_id = sc.system_type_id AND st.name != ''sysname''
              WHERE so.type = ''U'' '
              if @tabla<>''  set @sql=@sql+ ' and UPPER(so.name) like '''+@tabla+''' 
            ) b on a.tabla+a.columna=b.tabla+b.columna  '
    if @compara <=1 
       Begin
          set @sql= @sql +' where isnull(a.tabla+a.columna+a.tipo,'''')<>isnull(b.tabla+b.columna+b.tipo,'''') 
						  or  isnull(a.Tamaño,0)<>isnull(b.Tamaño,0) '
       end
    if @compara =2
       Begin
          set @sql= @sql +' where isnull(a.tabla+a.columna+a.tipo,'''')<>isnull(b.tabla+b.columna+b.tipo,'''') '
       end
    if @compara =3
       Begin
          set @sql= @sql +' where isnull(a.tabla+a.columna,'''')=isnull(b.tabla+b.columna,'''') '
       end
       set @sql= @sql +' order by 1,2 '
  end
execute (@sql)
GO
