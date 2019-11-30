$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm-ss"
$logName = "\\CHANGE_TO_FILESERVER.example.org\CHANGE_TO_FILESHARE\who_run.log"
$text = 'Пользователь ' + $env:username + ' на компьютере ' + $env:computername + ' запустил подозрительный файл ' + $date + ' в ' + $time + ' .'

$text | Out-File -FilePath $logName -Append -Encoding Unicode

Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object System.Windows.Forms.Form
$Form.TopMost = $true # Принудительно открывать окно поверх других диалоговых окон
$Form.FormBorderStyle = 0 # Убрать границы у окна
$Form.BackColor = '#ff0000'
$Form.WindowState = "Maximized"
$Form.ShowInTaskbar = $false # Не показывать в панели задач
$Form.Opacity = 0.8 # Прозрачность 0.0 - 1.0

$Button = New-Object System.Windows.Forms.Button
$Button.Text = 'OK'
$Button.ForeColor = '#ffffff'
$Button.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold) # Шрифт
$Button.Anchor = 0
$Button.Width = 130
$Button.Height = 30
$Button.Left = ($Form.ClientSize.Width - $Button.Width)/2
$Button.Top = ($Form.ClientSize.Height - $Button.Height)/2 + 130
$Form.Controls.Add($Button)

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold) # Шрифт
$TextBox.Anchor = 0
$TextBox.Width = 130
$TextBox.Left = ($Form.ClientSize.Width - $TextBox.Width)/2
$TextBox.Top = ($Form.ClientSize.Height - $TextBox.Height)/2 + 100
$Form.Controls.Add($TextBox)

$Label = New-Object System.Windows.Forms.Label
$Label.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) # Шрифт
$Label.ForeColor = '#ffffff'
$Label.AutoSize = $false
$Label.Dock = "Fill"
$Label.TextAlign = "MiddleCenter"
$Label.Text = "Все ваши файлы теперь зашифрованы!

В следующий раз перед тем,
как открывать полный доступ к папке
и запускать подозрительные файлы,
хорошо подумайте о возможных последствиях.

Для разблокировки компьютера, пожалуйста, введите код:"
$Form.Controls.Add($Label)

$notClose = $true # Не позволять закрывать форму

# Функция проверки введенного кода
function checkCode() {
	$code = '123456789'
	if ($TextBox.Text -eq $code) {
		$notClose = $false
		$Form.Close()
	}
}
 
# Функция для текстового поля
function keyDown() {
	$ret = 'Return'
	if ($_.KeyCode -eq $ret) {
		Invoke-Expression "checkCode"
	}
}

# Функция закрытия окна
function formClosing() {
	if ($notClose) {
		$_.Cancel = $true
	}
}

# Обработчик события для кнопки
$Button.add_Click({ Invoke-Expression "checkCode" })

# Обработчик события для текстового поля
$TextBox.add_KeyDown({ Invoke-Expression "keyDown" })

# Обработчик события закрытия окна
$Form.add_FormClosing({ Invoke-Expression "formClosing" })

$Form.ShowDialog() | Out-Null