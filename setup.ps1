# Путь к исполняемому файлу 1С.
$1cv8exe = "C:\Program Files (x86)\1cv8\8.3.27.1936\bin\1cv8.exe"

# Путь к базе 1С
$infoBase = "C:\Users\vladi\Documents\ZKGU"

# Путь к папке временного хранения резервных копий и логов резервного копирования 1С.
$tempBackupFolder = "C:\Users\vladi\Documents\backup"

# Адрес SFTP
$addressSFTP = "192.168.0.136"

# Порт SFTP
$portSFTP = 22

# Папка сохранения архивов на SFTP
$folderSFTP = "/backup"

# Количество копий
$numberOfCopy = 10

# Путь к папке, где будет хранится файлы с зашифрованными учетными данными.
$secureCredentialPath = "C:\Users\vladi\Documents\PowerShell\backup\password"

# Путь к ветке реестра и имя новой ветки, где буду хранится параметры необходимые для работы скрипта.
$registryBranch = "HKLM:\Software\"
$registryBranchName = "Backup_1C"

Write-Host "Проверка наличия прав администратора..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process Powershell -ArgumentList $PSCommandPath -Verb RunAs
    Exit
}

if (-not (Get-Module Posh-SSH -ListAvailable)) {
    Install-Module Posh-SSH
}

$credential1c = Get-Credential -Message "Учетные данные пользователя 1С"
$credential1c | Export-Clixml -Path "$secureCredentialPath\1c.xml"

$credentialSFTP = Get-Credential -Message "Учётные данные пользователя SFTP"
$credentialSFTP | Export-Clixml -Path "$secureCredentialPath\sftp.xml"

New-Item -Path $registryBranch -Name $registryBranchName

New-ItemProperty -Path $registryBranch$registryBranchName -Name "1cv8exe"              -Value $1cv8exe              -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "TempBackupFolder"     -Value $tempBackupFolder     -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "SecureCredentialPath" -Value $secureCredentialPath -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "AddressSFTP"          -Value $addressSFTP          -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "PortSFTP"             -Value $portSFTP             -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "FolderSFTP"           -Value $folderSFTP           -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "NumberOfCopy"         -Value $numberOfCopy         -PropertyType String
New-ItemProperty -Path $registryBranch$registryBranchName -Name "InfoBase"             -Value $infoBase             -PropertyType String