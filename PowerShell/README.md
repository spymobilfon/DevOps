|Script|Description|
|---|---|
|remote-install-metricbeat.ps1|Script for remote install/update Metricbeat on Windows. Example run: `.\remote-install-metricbeat.ps1 -Path "CHANGE_PATH_TO_SERVER_LIST\metricbeatServer.txt" -Version "5.6.8" -Template "Main"`|
|install-metricbeat.ps1|Script for remote install/update Metricbeat on Windows. Example run: `.\install-metricbeat.ps1 -Version "5.6.8" -Template "Main"`|
|Get-VM-SCVMM.ps1|Script for get list virtual machine with parameters from System Center Virtual Machine Manager. Example run: `.\Get-VM-SCVMM.ps1 SCVMM.example.local`|
|Enable-WinRM-HTTPS.ps1|Script for enable HTTPS listener WinRM. Set domain name in script code. Example run: `.\Enable-WinRM-HTTPS.ps1`|
|Win-Locker.ps1|Windows locker example script. Example run: `.\Win-Locker.ps1`|
|Get-SharedFolder-Permission.ps1|Script for get shared folder permission, helper script for Get-List-SharedFolder.ps1|
|Get-List-SharedFolder.ps1|Script for get list of shared folders with permissions. Example run: `.\Get-List-SharedFolder.ps1`|