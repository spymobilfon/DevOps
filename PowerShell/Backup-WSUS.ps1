#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for backup WSUS database
#

# Задаем переменные
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
$backupFolder = "C:\backup_WSUS\"
$backupPath = $backupFolder + "wsus_db_backup_*.bak"
$backupLog = $backupFolder + "wsus_db_backup_" + $date + "_" + $time + ".log"
$archivePath = $backupFolder + "wsus_db_backup_" + $date + "_" + $time + ".zip"
$tempLog = $backupFolder + "wsus_db_backup.log"

# Функция записи в лог и вывода в консоль
function Write-Log ([string]$logString)
{
	$logString = ( Get-Date -Format "yyyy.MM.dd HH:mm:ss" ) + " => " + $logString
	Add-Content -Path $backupLog -Value $logString -Force
	Write-Host $logString
}

# Очищаем ошибки и консоль
$Error.Clear()
Clear-Host

# Создаем резервную копию базы данных WSUS
Write-Log "Запущено резервное копирование базы данных WSUS на сервере $env:ComputerName"
sqlcmd.exe -S "(local)\SQLExpress" -U "sa" -P "PASSWORD" -i ".\Backup-WSUS.sql" -o $tempLog
Get-Content $tempLog -Encoding Unicode | Out-File $backupLog -Append
Remove-Item $tempLog -Force
Add-Content -Path $backupLog -Value "`n" -Force
if (!$Error) { Write-Log "Резервное копирование базы данных WSUS выполнено успешно" }
else { Write-Log "С резервным копированием базы данных WSUS возникли проблемы" }

# Архивируем резервную копию базы данных WSUS
Write-Log "Запущено архивирование резервной копии базы данных WSUS"
.\7z.exe a -mx5 -bb3 -tzip $archivePath $backupPath >>$backupLog
Add-Content -Path $backupLog -Value "`n" -Force
if (!$Error) { Write-Log "Архивирование резервной копии базы данных WSUS выполнено успешно" }
else { Write-Log "С архивированием резервной копии базы данных WSUS возникли проблемы" }

# Удаляем временные файлы процесса создания резервной копии базы данных WSUS
$bakFile = ( Get-ChildItem -Path $backupFolder -Filter *.bak ).FullName
$bakFile | Remove-Item -Force
$bakCount = ( $bakFile | Measure-Object ).Count
Write-Log "Удалены bak-файлы ($bakCount):"
Write-Log "$bakFile"

# Удаляем резервные копии базы данных WSUS старше 1 месяца
$rmFile = ( Get-ChildItem -Path $backupFolder -Include *.zip, *.log | Where-Object {$_.LastWriteTime -lt $(Get-Date).AddMonths(-1)} ).FullName
$rmFile | Remove-Item -Force
$rmCount = ( $rmFile | Measure-Object ).Count
Write-Log "Удалены старые файлы ($rmCount):"
Write-Log "$rmFile"

Write-Log "Завершено резервное копирование базы данных WSUS на сервере $env:ComputerName"