SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [vt_CopiaDatos_pro]
@base varchar(50),
@destino varchar(100),    --Ruta de archivo
@archivo1 varchar(50),    --Nombre de Dispositivo 1
@archivo2 varchar(50),    --Nombre de Archivo.DAT
@larchivo1 varchar(50),   --Nombre de Dispositivo 2
@larchivo2 varchar(50)   --Nombre de Archivo.DAT 
as
Declare @ncadena as nvarchar(4000)
Declare @disposi as varchar(100)
---- Create the backup device for the full MyNwind backup.
--USE master
--EXEC sp_addumpdevice 'disk', 'MyNwind_2',
--   'c:\Program Files\Microsoft SQL Server\MSSQL\BACKUP\MyNwind_2.dat'
--Create the log backup device.
--USE master
--EXEC sp_addumpdevice 'disk', 'MyNwindLog1',
--  'c:\Program Files\Microsoft SQL Server\MSSQL\BACKUP\MyNwindLog1.dat'
-- Back up the full MyNwind database.
--BACKUP DATABASE MyNwind TO MyNwind_2
-- Update activity has occurred since the full database backup.
-- Back up the log of the MyNwind database.
--BACKUP LOG MyNwind 
--   TO MyNwindLog1
set @disposi='disk'
set @ncadena='USE master'
EXEC @ncadena
--Crear copia de backups de data
set @ncadena='EXEC sp_addumpdevice '+@disposi+','+@archivo1+
	     ','+@destino+'\'+@archivo2
EXEC @ncadena
--Crear copia de backups de log.
set @ncadena='USE master'
EXEC @ncadena
set @ncadena='EXEC sp_addumpdevice '+@disposi+','+@larchivo1+
	     ','+@destino+'\'+@larchivo2
EXEC @ncadena
-- Backups completo de la base de datos
--BACKUP DATABASE MyNwind TO MyNwind_2
set @ncadena='BACKUP DATABASE '+@base +' TO '+@archivo1
EXEC @ncadena
-- Backups completo de log
set @ncadena='BACKUP LOG '+@base+' TO '+@archivo2
EXEC @ncadena
GO
