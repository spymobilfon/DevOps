#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for get list of local tasks
#

# Создаем функцию получения папок и подпапок планировщика заданий
Function Get-TaskSubFolders {
	[CmdletBinding()]
	Param (
		$FolderRef
	)

	# Создаем массив для папок и подпапок
	$FolderArr = @()
	$Folders = $FolderRef.GetFolders(1)
	if ($Folders) {
		$Folders | ForEach-Object {
			$FolderArr = $FolderArr + $_
			if ($_.GetFolders(1)) {
				# ... исключаем папки и подпапки Microsoft
				Get-TaskSubFolders -FolderRef $_ | Where-Object Path -NotMatch 'Microsoft'
			}
		}
	}

	Return $FolderArr

}

# Задаем переменные
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
$logPath = "\\CHANGE_TO_FILESERVER.example.org\CHANGE_TO_FILESHARE\LocalTasks\LocalTasks_" + $date + "_" + $time + ".csv"

# Подключаем модуль PowerShell
Import-Module ActiveDirectory

# Получаем список всех компьютеров в домене
$computers = Get-ADComputer -Filter * | Sort-Object -Property Name | Select-Object -Property Name

# Начинаем обработку каждого компьютера по отдельности
$computers | ForEach-Object {

	# Очищаем переменную ошибок
	$error.Clear()
	# Включаем игнорирование ошибок
	$ErrorActionPreference = "SilentlyContinue"
	# Очищаем переменную
	$computerName = $null
	# Получаем имя компьютера
	$computerName = $_.Name
	# Очищаем переменную
	$dnsResult = $null
	# Разрешаем имя компьютера в IP адрес
	$dnsResult = [System.Net.Dns]::Resolve("$computerName")
	# Продолжаем, если нет ошибок
	if (!$error) {

		# Очищаем переменную
		$ipAddress = $null
		# Получаем IP адрес
		$ipAddress = $dnsResult.AddressList
		# Проверяем доступность компьютера через пинг
		$pingFunc = (New-Object System.Net.NetworkInformation.Ping).Send("$ipAddress")
		# Продолжаем, если успешно
		if ($pingFunc.Status -eq "Success") {

			# Подключаемся к службе планировщика заданий
			$schService = New-Object -ComObject Schedule.Service
			$schService.Connect($computerName)
			# Продолжаем, если нет ошибок
			if (!$error) {

				# Получаем полный путь папок и подпапок
				$RootFolder = $schService.GetFolder("\")
				$Folders = @($RootFolder)
				$Folders += Get-TaskSubFolders -FolderRef $RootFolder

				# Формируем информацию по каждому заданию
				$Folders | ForEach-Object {

					# Очищаем переменную
					$FolderCur = $null
					# Задаем имя текущего каталога
					$FolderCur = $_
					# Получаем список всех заданий в текущем каталоге и задаем исключения
					$Tasks = $_.GetTasks(1) | Where-Object {
						($_.Name -NotMatch 'Optimize Start Menu Cache') -and ($_.Name -NotMatch 'Adobe Acrobat Update Task') -and ($_.Name -NotMatch 'Adobe Flash Player') -and ($_.Name -NotMatch 'DropboxUpdateTask') -and ($_.Name -NotMatch 'GoogleUpdateTask') -and ($_.Name -NotMatch 'OneDrive Standalone Update Task') -and ($_.Name -NotMatch 'Opera scheduled Autoupdate') -and ($_.Name -NotMatch 'ShadowCopyVolume') -and ($_.Name -NotMatch 'User_Feed_Synchronization')
					}
					# Формируем таблицу данных
					$Tasks | ForEach-Object {

						$outputObj = New-Object -TypeName PSobject
						$outputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $computerName
						$outputObj | Add-Member -MemberType NoteProperty -Name TaskName -Value $_.Name
						$outputObj | Add-Member -MemberType NoteProperty -Name TaskFolder -Value $FolderCur.Path
						$outputObj | Add-Member -MemberType NoteProperty -Name IsEnabled -Value $_.Enabled
						$outputObj | Add-Member -MemberType NoteProperty -Name LastRunTime -Value $_.LastRunTime
						$outputObj | Add-Member -MemberType NoteProperty -Name NextRunTime -Value $_.NextRunTime
						$outputObj | Add-Member -MemberType NoteProperty -Name LastTaskResult -Value $_.LastTaskResult

						$xmlTask = $_.Xml
						[xml]$xmlObj = $xmlTask

						$outputObj | Add-Member -MemberType NoteProperty -Name Author -Value $xmlObj.Task.RegistrationInfo.Author
						$outputObj | Add-Member -MemberType NoteProperty -Name Description -Value $xmlObj.Task.RegistrationInfo.Description
						$outputObj | Add-Member -MemberType NoteProperty -Name RunUser -Value $xmlObj.Task.Principals.Principal.UserId
						$outputObj | Add-Member -MemberType NoteProperty -Name Command -Value ($xmlObj.Task.Actions.Exec.Command + " " + $xmlObj.Task.Actions.Exec.Arguments)
						$outputObj | Export-CSV $logPath –Append -NoTypeInformation -Delimiter "`t" -Encoding Unicode

					}
				}
			}
		}
	}
}