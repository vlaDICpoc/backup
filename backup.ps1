# Путь к ветке реестра, где хранятся параметры для работа скрипта.
$registryBranch = "HKLM:\Software\Backup_1C"

$secureCredentialPath = Get-ItemPropertyValue -Path $registryBranch -Name SecureCredentialPath
$credential1c = Import-Clixml "$secureCredentialPath\1c.xml"
# ./$credentialSFTP = Import-Clixml "$secureCredentialPath\sftp.xml" 

Write-Host "Проверка наличия прав администратора..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process Powershell -ArgumentList $PSCommandPath -Verb RunAs
    Exit
}

# Путь к 1сv8.exe
$1cv8exe = Get-ItemPropertyValue -Path $registryBranch -Name 1cv8exe


$baseSettings  = [PSCustomObject]@{
    user = $credential1c.UserName
        password = [System.Net.NetworkCredential]::new(
        "",
        $credential1c.Password
    ).Password
    infoBase = Get-ItemPropertyValue -Path $registryBranch -Name InfoBase
    tempBackupFolder = Get-ItemPropertyValue -Path $registryBranch -Name TempBackupFolder
}

$backupDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Start-Process -FilePath $1cv8exe -ArgumentList @(
    "CONFIG",
    "/F`"$($baseSettings.infoBase)`"",
    "/N`"$($baseSettings.user)`"",
    "/P`"$($baseSettings.password)`"",
    "/DumpIB`"$($baseSettings.tempBackupFolder)\${backupDate}_backup.dt`"",
    "/Out`"$($baseSettings.tempBackupFolder)\${backupDate}_dump.log`""
) -Wait -PassThru

$compressDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$compressSettings = @{
    Path = "$($baseSettings.tempBackupFolder)\${backupDate}_backup.dt"
    DestinationPath = "$($baseSettings.tempBackupFolder)\${compressDate}_backup.zip"
    CompressionLevel = "Optimal"
}
Compress-Archive @compressSettings