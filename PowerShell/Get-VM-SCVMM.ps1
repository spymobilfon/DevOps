#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for get list virtual machine with parameters from System Center Virtual Machine Manager
#

[CmdletBinding()]
Param (

    [Parameter(Mandatory=$true)]
    [String]$server

)

# Set time and date
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"

# Set path to list virtual machine
$pathListVM = $env:SystemDrive + "\List_VM_" + $date + "_" + $time + ".csv"

# Set work path
$workPath = $MyInvocation.MyCommand.Path | Split-Path -Parent

# Import PowerShell module for System Center Virtual Machine Manager
Import-Module -Name VirtualMachineManager

# Get list virtual machine
$listVM = Get-SCVirtualMachine -VMMServer $server | Sort-Object -Property Name

# Run cycle for create list virtual machine with parameters
$listVM | ForEach-Object {

    # VM
    $object = New-Object -TypeName PSObject
    # VM name
    $object | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name
    # VM status
    $object | Add-Member -MemberType NoteProperty -Name Status -Value $_.Status
    # CPU count
    $object | Add-Member -MemberType NoteProperty -Name CPUCount -Value $_.CPUCount
    # CPU type
    $object | Add-Member -MemberType NoteProperty -Name CPUType -Value $_.CPUType
    # Memory size
    $object | Add-Member -MemberType NoteProperty -Name MemoryMB -Value $_.Memory
    # Enabled or disabled dynamic memory
    $object | Add-Member -MemberType NoteProperty -Name DynamicMemoryEnabled -Value $_.DynamicMemoryEnabled
    # Dynamic memory maximum size
    $object | Add-Member -MemberType NoteProperty -Name DynamicMemoryMaximumMB -Value $_.DynamicMemoryMaximumMB
    # HDD
    $listHardDisk = $null
    $listHardDisk = Get-SCVirtualHardDisk -VMMServer $server -VM $_
    # Disk name
    $object | Add-Member -MemberType NoteProperty -Name Disk -Value ([String]$listHardDisk.Name -Replace(" "," | "))
    # Disk location
    $object | Add-Member -MemberType NoteProperty -Name DiskLocation -Value ([String]$listHardDisk.Location -Replace(" "," | "))
    # Disk size
    $listDiskSize = $null
    $listDiskSize = @()
    $listHardDisk.Size | ForEach-Object {

        $listDiskSize += @([Int]($_/1073741824))

    }
    $object | Add-Member -MemberType NoteProperty -Name DiskSizeGB -Value ([String]$listDiskSize -Replace(" "," | "))
    # Disk maximum size
    $listDiskMaximumSize = $null
    $listDiskMaximumSize = @()
    $listHardDisk.MaximumSize | ForEach-Object {

        $listDiskMaximumSize += @([Int]($_/1073741824))

    }
    $object | Add-Member -MemberType NoteProperty -Name DiskMaximumSizeGB -Value ([String]$listDiskMaximumSize -Replace(" "," | "))
    # IP
    $listIP = $null
    $listIP = Get-SCVirtualNetworkAdapter -VMMServer $server -VM $_
    # IPv4 addresses
    $object | Add-Member -MemberType NoteProperty -Name IP -Value ([String]$listIP.IPv4Addresses -Replace(" "," | "))
    # Operating system
    $object | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $_.OperatingSystem
    # VM generation
    $object | Add-Member -MemberType NoteProperty -Name Generation -Value $_.Generation
    # Hostname
    $object | Add-Member -MemberType NoteProperty -Name HostName -Value $_.HostName
    # Project
    $project = $null
    if ($_.Name -match "Project1") {
        $project = "Project1"
    } elseif ($_.Name -match "Project2") {
        $project = "Project2"
    } else {
        $project = ""
    }
    $object | Add-Member -MemberType NoteProperty -Name Project -Value $project
    # Group
    $group = $null
    if ($_.Name -match "Group1") {
        $group = "Group1"
    } elseif ($_.Name -match "Group2") {
        $group = "Group2"
    } else {
        $group = ""
    }
    $object | Add-Member -MemberType NoteProperty -Name Group -Value $group
    # Export
    $object | Export-CSV $pathListVM -Append -NoTypeInformation -Encoding UTF8

}

# Update page in Confluence
# Launch format:
# python .\update-list-VM.py "XML-RPS URL" "Login" "Password" "Page ID" "Space" "Title" "Parent ID" "CSV"
# DEV environment
if ($server -eq "DEV.example.local") {

    python $workPath\update-list-VM.py "http://fqdn_of_confluence/rpc/xmlrpc" "user1" "password1" "32158003" "SYSDOC" "DEV SCVMM cluster virtual machine list" "32157997" "$pathListVM"

}
# PROD environment
if ($server -eq "PROD.example.local") {

    python $workPath\update-list-VM.py "http://fqdn_of_confluence/rpc/xmlrpc" "user1" "password1" "32158000" "SYSDOC" "PROD SCVMM cluster virtual machine list" "32157997" "$pathListVM"

}

# Delete CSV file
Remove-Item -Path $pathListVM -Force -ErrorAction SilentlyContinue