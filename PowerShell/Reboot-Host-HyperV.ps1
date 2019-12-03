#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for stop virtual machine, reboot Hyper-V host, start virtual machine
#

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[String]$hostName
)

# Функция записи в лог и вывода в консоль
function Write-Log ([string]$logString)
{
	$logString = (Get-Date -Format "yyyy.MM.dd HH:mm:ss") + " => " + $logString
	Add-Content -Path $logFile -Value $logString -Force
	Write-Host $logString
}

# Задаем переменные
$logFile = "\\CHANGE_TO_FILESERVER.example.org\CHANGE_TO_FILESHARE\RebootHostHyperV\" + $hostName + ".log"

# Начало
Write-Log "--------------------------------------------------"

Write-Log "User $env:username"

# Загружаем модуль PowerShell
Import-Module Hyper-V

# Получаем список запущенных на хосте виртуальных машин и сохраняем в переменную
$runVM = (Get-VM -ComputerName $hostName | Where-Object {$_.State -eq 'Running'}).Name
Write-Log "Running VM on host $hostName :"
Write-Log ([string]$runVM)

# Завершаем работу запущенных на хосте виртуальных машин
Write-Log "Stop VM"
Stop-VM -ComputerName $hostName -Name $runVM

# Перезагружаем целевой хост
Write-Log "Shutdown host $hostName"
shutdown /r /f /t 300 /m "\\$hostName" /c "Script reboot"

# Ожидаем выключения целевого хоста
Start-Sleep -Seconds 300

do {
	# Ожидаем запуска целевого хоста
	Start-Sleep -Seconds 300

	# Очищаем значения переменных
	$pingHost = $null
	$procHost = $null

	# Проверяем доступность целевого хоста (пинг и количество логических процессоров)
	$pingHost = (New-Object System.Net.NetworkInformation.Ping).Send("$hostName")
	$procHost = (Get-VMHost -ComputerName $hostName).LogicalProcessorCount
}
until (($pingHost.Status -eq "Success") -and ($procHost -gt 0))

Write-Log "Host $hostName is available"

do {
	# Очищаем значения переменных
	$Error.Clear()

	# Через удаленную сессию запускаем виртуальные машины, которые работали до перезагрузки
	$session = New-PSSession -ComputerName $hostName
	Invoke-Command -Session $session -ScriptBlock {
		Param($hostName,$runVM)
		$runVM | ForEach-Object {
			Start-Sleep -Seconds 300
			Start-VM -ComputerName $hostName -Name $_
		}
	} -ArgumentList $hostName,$runVM
}
until (!$Error)

Write-Log "Running all VM on host $hostName"

# Конец
Write-Log "--------------------------------------------------"