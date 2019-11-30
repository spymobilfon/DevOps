#
# Author:      spymobilfon
# Company:     spymobilfon
# Description: Script for enable HTTPS listener WinRM
#

# Получаем список сертификатов Kerberos, в имени которых присутствует имя нашего домена, и выбираем первый
$certThumbprint = Get-ChildItem Cert:\LocalMachine\My | Where-Object {($_.EnrollmentPolicyEndPoint.AuthenticationType -eq "Kerberos") -and ($_.Subject -like "*.example.org") -and ($_.NotBefore.AddYears(5).Year -eq $_.NotAfter.Year)} | Select-Object -First 1 Thumbprint

# Получаем имя текущего прослушивателя HTTPS
$currentListener = $null
$currentListener = (Get-ChildItem WSMan:\localhost\Listener | Where-Object {$_.Keys -eq "Transport=HTTPS"}).Name

# Проверяем наличие прослушивателя HTTPS
if ($currentListener -eq $null) {

	# Включаем прослушиватель HTTPS с выбранным ранее сертификатом
	New-Item WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $certThumbprint.Thumbprint -Force

} else {

	# Получаем текущий сертификат прослушивателя HTTPS
	$currentThumbprint = (Get-ChildItem WSMan:\localhost\Listener\$currentListener\CertificateThumbprint).Value -replace ' '

	# Сравниваем текущий и выбранный сертификаты
	if ($currentThumbprint.ToUpper() -ne $certThumbprint.Thumbprint) {

		# Удаляем текущий прослушиватель HTTPS
		Remove-Item WSMan:\localhost\Listener\$currentListener -Force

		# Включаем прослушиватель HTTPS с выбранным ранее сертификатом
		New-Item WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $certThumbprint.Thumbprint -Force

	}
}