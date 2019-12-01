#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for remote install/update Metricbeat on Windows
#

[CmdletBinding()]
Param (

    [Alias("Path")]
    [String]$serverListPath = "CHANGE_PATH_TO_SERVER_LIST\metricbeatServer.txt",
    [Alias("Version")]
    [String]$metricbeatVersion = "5.6.8",
    [Alias("Template")]
    [ValidateSet("Main", "DB", "IIS")]
    [String]$metricbeatTemplate = "Main"

)

Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Script is started:" $MyInvocation.MyCommand.Name
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Server list: $serverListPath"
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat version: $metricbeatVersion"
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat template: $metricbeatTemplate"

# Set credential
$cred = Get-Credential

# Get server list for remote install
$serverList = Get-Content $serverListPath
# Start remote session and run remote command
$serverList | ForEach-Object {

    Enable-WSManCredSSP -Role "Client" -DelegateComputer $_ -Force
    Enable-WSManCredSSP -Role "Server" -Force
    $currentSession = New-PSSession $_ -Authentication Credssp -Credential $cred
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat began installed on server $_"
    Invoke-Command -Session $currentSession -FilePath CHANGE_PATH_TO_INSTALL_SCRIPT\install-metricbeat.ps1 -ArgumentList $metricbeatVersion, $metricbeatTemplate
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat installed on server $_"
    Get-PSSession | Remove-PSSession

}

Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Script is finished:" $MyInvocation.MyCommand.Name