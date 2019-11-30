#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for get list of shared folders with permissions
#

$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
$filePath = "\\CHANGE_TO_FILESERVER.example.org\CHANGE_TO_FILESHARE\SharedFolders\SharedFolders_" + $date + "_" + $time + ".csv"
$commandPath = ".\Get-SharedFolder-Permission.ps1"

Import-Module ActiveDirectory

$computers = Get-ADComputer -filter * | Sort-Object -Property Name | Select-Object -Property Name

foreach ($i in $computers)
	{
		$computer = $i.name
		powershell.exe -command "& {$commandPath -ComputerName $computer -FilePath $filePath}"
	}