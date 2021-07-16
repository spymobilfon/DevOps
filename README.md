# Supporting scripts for DevOps  

## PowerShell scripts  
See directory PowerShell  

|Script|Description|
|---|---|
|Backup-WSUS.ps1|Script for backup WSUS database. Example run: `.\Backup-WSUS.ps1`|
|Backup-WSUS.sql|Script for create dump WSUS database, helper script for Backup-WSUS.ps1|
|Enable-WinRM-HTTPS.ps1|Script for enable HTTPS listener WinRM. Example run: `.\Enable-WinRM-HTTPS.ps1`|
|Get-List-GPO.ps1|Script for get list of Group Policy Object. Example run: `.\Get-List-GPO.ps1`|
|Get-List-LocalTask.ps1|Script for get list of local tasks. Example run: `.\Get-List-LocalTask.ps1`|
|Get-List-SharedFolder.ps1|Script for get list of shared folders with permissions. Example run: `.\Get-List-SharedFolder.ps1`|
|Get-SharedFolder-Permission.ps1|Script for get shared folder permission, helper script for Get-List-SharedFolder.ps1|
|Get-VM-SCVMM.ps1|Script for get list virtual machine with parameters from System Center Virtual Machine Manager. Example run: `.\Get-VM-SCVMM.ps1 SCVMM.example.local`|
|update-list-VM.py|Script for update list virtual machine with parameters in Confluence, helper script for Get-VM-SCVMM.ps1|
|install-metricbeat.ps1|Script for install/update Metricbeat on Windows, helper script for remote-install-metricbeat.ps1. Example run: `.\install-metricbeat.ps1 -Version "5.6.8" -Template "Main"`|
|Reboot-Host-HyperV.ps1|Script for stop virtual machine, reboot Hyper-V host, start virtual machine. Example run: `.\Reboot-Host-HyperV.ps1 HOST.example.org`|
|remote-install-metricbeat.ps1|Script for remote install/update Metricbeat on Windows. Example run: `.\remote-install-metricbeat.ps1 -Path "CHANGE_PATH_TO_SERVER_LIST\metricbeatServer.txt" -Version "5.6.8" -Template "Main"`|
|Win-Locker.ps1|Windows locker example script. Example run: `.\Win-Locker.ps1`|

## Ansible roles  
See directory Ansible  

|Role|Description|
|---|---|
|curator|Role for install Curator Index Management for Elasticsearch|
|elasticsearch| Role for install Elasticsearch|
|filebeat|Role for install Filebeat|
|jenkins|Role for install Jenkins|
|kibana|Role for install Kibana|
|nginx-letsencrypt|Role for install Nginx + Letsencrypt|
|fail2ban|Role for install Fail2ban|

## Helm charts  
See directory Helm  

|Chart|Description|
|---|---|
|wiremock|Chart for WireMock.Net deployment on Kubernetes|
|loki|Chart for Loki deployment on Kubernetes|
|kibana|Chart for Kibana deployment on Kubernetes|
