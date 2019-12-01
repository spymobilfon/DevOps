DECLARE @pathName NVARCHAR(512)
SET @pathName = 'C:\backup_WSUS\wsus_db_backup_' + Convert(varchar(8), GETDATE(), 112) + '.bak'
BACKUP DATABASE SUSDB TO DISK = @pathName WITH NAME = N'WSUS Full Database Backup', NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10