#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for get list of Group Policy Object
#

# Задаем переменные
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
# Задаем текущий каталог размещения файлов реестра групповых политик
$currentDirPath = "\\CHANGE_TO_FILESERVER.example.org\CHANGE_TO_FILESHARE\GPO"
# Задаем архив размещения файлов реестра групповых политик
$oldDirPath = $currentDirPath + "\OLD"
# Задаем имя файла реестра групповых политик
$filePath = $currentDirPath + "\All_GPO_" + $date + "_" + $time + ".csv"
# Задаем текущий каталог работы скрипта
$currentWorkPath = $MyInvocation.MyCommand.Definition | Split-Path -Parent

# Подключаем модуль PowerShell
Import-Module GroupPolicy

# Получаем список всех групповых политик отсортированных по наименованию
$allGPO = Get-GPO -All -Domain "example.org" | Sort-Object DisplayName

# Создаем цикл формирования реестра групповых политик
$allGPO | ForEach-Object {

	$outList = New-Object -TypeName PSobject
	# Добавляем имя групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name Name -Value $_.DisplayName
	# Разбиваем и форматируем комментарии к групповой политике
	$descriptionGPO = $null
	$authorGPO = $null
	$commentGPO = $null
	$commentGPO = $_.Description
	if ($commentGPO -ne $null) {
		$splitCommentGPO = $null
		$splitCommentGPO = $commentGPO.Split("\|")
		$descriptionGPO = $splitCommentGPO[0].Replace("`r`n"," ")
			if ($splitCommentGPO[1] -ne $null) {
				$splitAuthorGPO = $null
				$splitAuthorGPO = $splitCommentGPO[1].Split("\:")
					if ($splitAuthorGPO[1] -ne $null) {
						$authorGPO = $splitAuthorGPO[1] -Replace "^ "
					}
			}
	}
	# Добавляем описание групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name Description -Value $descriptionGPO
	# Добавляем автора групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name Author -Value $authorGPO
	# Добавляем статус групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name Status -Value $_.GpoStatus
	# Загружаем отчет по групповой политике в XML
	[xml]$xmlGPO = Get-GPOReport -Guid $_.Id -ReportType XML
	# Получаем размещение групповой политики
	$deploymentGPO = $null
	$deploymentGPO = $xmlGPO.GPO.LinksTo | ForEach-Object {
		$_.SOMPath
	}
	# Добавляем размещение групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name Deployment -Value ([string]$deploymentGPO)
	# Получаем фильтр безопасности групповой политики
	$filterGPO = $null
	$filterGPO = $xmlGPO.GPO.SecurityDescriptor.Permissions.TrusteePermissions | ForEach-Object {
		if ($_.Standard.GPOGroupedAccessEnum -eq "Apply Group Policy") {
			($_.Trustee.Name).'#text'
		}
	}
	# Добавляем фильтр безопасности групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name SecurityFilter -Value ([string]$filterGPO)
	# Добавляем время создания групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime
	# Добавляем время модификации групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name ModificationTime -Value $_.ModificationTime
	# Добавляем идентификатор групповой политики в реестр
	$outList | Add-Member -MemberType NoteProperty -Name ID -Value $_.Id
	# Экспортируем реестр групповых политик в CSV-файл
	$outList | Export-CSV $filePath –Append -NoTypeInformation -Delimiter "`t" -Encoding Unicode

}

# Делаем выборку файлов старше 1 месяца и размещенных в текущем каталоге
$mvFiles = (Get-ChildItem -Path $currentDirPath -Filter *.csv | Where-Object {$_.LastWriteTime -lt $(Get-Date).AddMonths(-1)}).FullName
# Переносим полученные файлы в архив
$mvFiles | Move-Item -Destination $oldDirPath -Force

# Делаем выборку файлов старше 1 года и размещенных в архиве
$rmFiles = (Get-ChildItem -Path $oldDirPath -Filter *.csv | Where-Object {$_.LastWriteTime -lt $(Get-Date).AddYears(-1)}).FullName
# Удаляем полученные файлы
$rmFiles | Remove-Item -Force

# Удаляем временные файлы
Remove-Item -Path ($currentWorkPath + "\%LOCALAPPDATA%") -Force -Recurse