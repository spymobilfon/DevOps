#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for install/update Metricbeat on Windows
#

[CmdletBinding()]
Param (

    [Alias("Version")]
    [String]$metricbeatVersion = "5.6.8",
    [Alias("Template")]
    [ValidateSet("Main", "DB", "IIS")]
    [String]$metricbeatTemplate = "Main"

)

# Set variables
$rootPath = "CHANGE_PATH_TO_ROOT_FOLDER"
$binariesPath = "$rootPath\binaries\metricbeat"
$templatesPath = "$rootPath\templates\metricbeat"

# Find, stop and delete Metricbeat service, move Metricbeat folder
if (Get-Service -Name *metricbeat* -ErrorAction SilentlyContinue) {

    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat service is found"
    $metricbeatServicePS = Get-Service -Name *metricbeat*
    if ($metricbeatServicePS.Status -ne "Stopped" -or $metricbeatServicePS.Status -ne "Stopping") {

        $metricbeatServicePS.Stop()

    }
    $metricbeatServicePS.WaitForStatus("Stopped", (New-TimeSpan -Minutes 1))
    if ($metricbeatServicePS.Status -ne "Stopped") {

        throw "Old Metricbeat service could not be stopped within the allotted timespan. Stop the service and try again)))"

    }
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat service is stopped"
    $metricbeatServiceC = Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -like '*metricbeat*' }
    $metricbeatFolder = ($metricbeatServiceC.PathName.Split('"')[1].Replace('\\', '\') -Split '\\metricbeat.exe')[0]
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat folder: $metricbeatFolder"
    $metricbeatServiceC.Delete()
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat service is deleted"
    Move-Item -Path "$metricbeatFolder" -Destination "$env:ProgramFiles\metricbeat.old" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles\metricbeat" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat folder is moved"

}
else {

    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat service is not found"

}

# Set Metricbeat source
$sourcePath = "$binariesPath\metricbeat-$metricbeatVersion-windows-x86_64.zip"
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat source: $sourcePath"

# Unzip Metricbeat archive to Program Files
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> PowerShell version:" $PSVersionTable.PSVersion.Major
if ($PSVersionTable.PSVersion.Major -lt 5) {

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sourcePath, $env:ProgramFiles)

}
else {

    Expand-Archive -Path $sourcePath -DestinationPath $env:ProgramFiles -Force

}
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat source extracted to Program Files"

# Rename Metricbeat folder
Rename-Item -Path "$env:ProgramFiles\metricbeat-$metricbeatVersion-windows-x86_64" -NewName "$env:ProgramFiles\metricbeat" -Force -ErrorAction SilentlyContinue

# Copy Metricbeat config
if ($metricbeatTemplate -eq "Main") {

    Copy-Item -Path "$templatesPath\metricbeat-main.yml" -Destination "$env:ProgramFiles\metricbeat\metricbeat.yml" -Force

}
if ($metricbeatTemplate -eq "DB") {

    Copy-Item -Path "$templatesPath\metricbeat-db.yml" -Destination "$env:ProgramFiles\metricbeat\metricbeat.yml" -Force

}
if ($metricbeatTemplate -eq "IIS") {

    Copy-Item -Path "$templatesPath\metricbeat-iis.yml" -Destination "$env:ProgramFiles\metricbeat\metricbeat.yml" -Force

}
else {

    Copy-Item -Path "$templatesPath\metricbeat-main.yml" -Destination "$env:ProgramFiles\metricbeat\metricbeat.yml" -Force

}

# Install new Metricbeat service
$workPath = "$env:ProgramFiles\metricbeat"
Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> Metricbeat work path: $workPath"
New-Service -Name metricbeat -DisplayName metricbeat -BinaryPathName "`"$workPath\\metricbeat.exe`" -c `"$workPath\\metricbeat.yml`" -path.home `"$workPath`" -path.data `"C:\\ProgramData\\metricbeat`""

# Check new Metricbeat service
if (Get-Service -Name *metricbeat* -ErrorAction SilentlyContinue) {

    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> New Metricbeat service is found"
    $metricbeatServiceNC = Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -like '*metricbeat*' }
    $metricbeatPath = $metricbeatServiceNC.PathName
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> New Metricbeat path to executable: $metricbeatPath"
    $metricbeatServiceNPS = Get-Service -Name *metricbeat*
    if ($metricbeatServiceNPS.Status -ne "Running") {

        $metricbeatServiceNPS.Start()

    }
    $metricbeatServiceNPS.WaitForStatus("Running", (New-TimeSpan -Minutes 1))
    if ($metricbeatServiceNPS.Status -ne "Running") {

        throw "New Metricbeat service could not be running within the allotted timespan. Start the service in manual mode)))"

    }
    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> New Metricbeat service is running"

}
else {

    Write-Host (Get-Date -Format "yyyy.MM.dd HH:mm:ss") "=> New Metricbeat service is not found"

}