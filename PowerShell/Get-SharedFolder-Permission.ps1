#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for get shared folder permission
#

[CmdletBinding()]
Param
(
	[Parameter(Mandatory=$false)]
	[Alias('Computer')][String[]]$ComputerName=$Env:COMPUTERNAME,

	[Parameter(Mandatory=$false)]
	[Alias('NTFS')][Switch]$NTFSPermission,

	[Parameter(Mandatory=$false)]
	[Alias('Cred')][System.Management.Automation.PsCredential]$Credential,

	[Parameter(Mandatory=$false)]
	[Alias('File')][String]$FilePath
)

$RecordErrorAction = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

Function GetSharedFolderPermission($ComputerName)
{
	$PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
	if($PingResult)
	{
		if($Credential)
		{
			$SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
			-ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
		}
		else
		{
			$SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
			-ComputerName $ComputerName -ErrorAction SilentlyContinue
		}
		foreach($SharedFolderSec in $SharedFolderSecs)
		{
			$Objs = @()
			$SecDescriptor = $SharedFolderSec.GetSecurityDescriptor()
			foreach($DACL in $SecDescriptor.Descriptor.DACL)
			{
				$DACLDomain = $DACL.Trustee.Domain
				$DACLName = $DACL.Trustee.Name
				if($DACLDomain -ne $null)
				{
					$UserName = "$DACLDomain\$DACLName"
				}
				else
				{
					$UserName = "$DACLName"
				}
				$Properties = @{'ComputerName' = $ComputerName
								'ConnectionStatus' = "Success"
								'SharedFolderName' = $SharedFolderSec.Name
								'SecurityPrincipal' = $UserName
								'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
								$($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
								'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType}
				$SharedACLs = New-Object -TypeName PSObject -Property $Properties
				$Objs += $SharedACLs
			}
			$Objs | Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights,AccessControlType
		}
	}
	else
	{
		$Properties = @{'ComputerName' = $ComputerName
						'ConnectionStatus' = "Fail"
						'SharedFolderName' = "Not Available"
						'SecurityPrincipal' = "Not Available"
						'FileSystemRights' = "Not Available"
						'AccessControlType' = "Not Available"}
		$SharedACLs = New-Object -TypeName PSObject -Property $Properties
		$Objs += $SharedACLs
		$Objs | Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights,AccessControlType
	}
}

Function GetSharedFolderNTFSPermission($ComputerName)
{
	$PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
	if($PingResult)
	{
		if($Credential)
		{
			$SharedFolders = Get-WmiObject -Class Win32_Share `
			-ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
		}
		else
		{
			$SharedFolders = Get-WmiObject -Class Win32_Share `
			-ComputerName $ComputerName -ErrorAction SilentlyContinue
		}
		foreach($SharedFolder in $SharedFolders)
		{
			$Objs = @()
			$SharedFolderPath = [regex]::Escape($SharedFolder.Path)
			if($Credential)
			{
				$SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
				-Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName  -Credential $Credential
			}
			else
			{
				$SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
				-Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName
			}
			$SecDescriptor = $SharedNTFSSecs.GetSecurityDescriptor()
			foreach($DACL in $SecDescriptor.Descriptor.DACL)
			{
				$DACLDomain = $DACL.Trustee.Domain
				$DACLName = $DACL.Trustee.Name
				if($DACLDomain -ne $null)
				{
					$UserName = "$DACLDomain\$DACLName"
				}
				else
				{
					$UserName = "$DACLName"
				}
				$Properties = @{'ComputerName' = $ComputerName
								'ConnectionStatus' = "Success"
								'SharedFolderName' = $SharedFolder.Name
								'SecurityPrincipal' = $UserName
								'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
								$($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
								'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType
								'AccessControlFalgs' = [Security.AccessControl.AceFlags]$DACL.AceFlags}
				$SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
				$Objs += $SharedNTFSACL
			}
			$Objs | Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights,AccessControlType,AccessControlFalgs -Unique
		}
	}
	else
	{
		$Properties = @{'ComputerName' = $ComputerName
						'ConnectionStatus' = "Fail"
						'SharedFolderName' = "Not Available"
						'SecurityPrincipal' = "Not Available"
						'FileSystemRights' = "Not Available"
						'AccessControlType' = "Not Available"
						'AccessControlFalgs' = "Not Available"}
		$SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
		$Objs += $SharedNTFSACL
		$Objs | Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights,AccessControlType,AccessControlFalgs -Unique
	}
}

foreach($CN in $ComputerName)
{
	if($NTFSPermission)
	{
		GetSharedFolderNTFSPermission -ComputerName $CN | Export-CSV -Path $FilePath –Append -NoTypeInformation -Delimiter ";" -Encoding Unicode
	}
	else
	{
		GetSharedFolderPermission -ComputerName $CN | Export-CSV -Path $FilePath –Append -NoTypeInformation -Delimiter ";" -Encoding Unicode
	}
}

$ErrorActionPreference = $RecordErrorAction