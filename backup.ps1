# Путь к 1сv8.exe
$1cv8exe = "C:\Program Files (x86)\1cv8\8.3.26.1656\bin\1cv8.exe"

# Путь к папке хранения логов
$logDirectoryPath = "C:\Users\User\Documents\PowerShell\logs"
$logDirectoryExist = Test-Path $logDirectoryPath

$sftpSession = New-SFTPSession -ComputerName 192.168.0.103 -Credential (Get-Credential)

if(!($logDirectoryExist)) {
    $currentTime = Get-Date
    Write-Output "$currentTime | Папка хранения логов не найдена!"
}

if (!(Test-Path -Path $1cv8exe)) {
    $currentTime = Get-Date
    $logMessage = "$currentTime | 1сv8.exe - не найден!"

    Write-Output "$currentTime | 1сv8.exe - не найден!"

    if ($logDirectoryExist) {
        New-Item -Path $logDirectoryPath -Name "logs.txt" -Value $logMessage
    }

    Exit
}

$baseSettings  = [PSCustomObject]@{
    mode = "CONFIG"
    user = "Администратор"
    password = "061420"
    basePath = "C:\Users\User\Documents\InfoBase\BGU"
    backupPath = "C:\Users\User\Documents\PowerShell\backup"
}

$currentTime = Get-Date
$process = Start-Process -FilePath $1cv8exe -ArgumentList @(
    "CONFIG",
    "/F`"$($baseSettings.basePath)`"",
    "/N`"$($baseSettings.user)`"",
    "/P`"$($baseSettings.password)`"",
    "/DumpIB`"$($baseSettings.backupPath)\$currentTime-backup.dt`"",
    "/Out`"$($baseSettings.backupPath)\$currentTime-dump.log`""
) -Wait -PassThru

if (0 -ne $process.ExitCode) {
    $currentTime = Get-Date
    $logMessage = "$currentTime | Ошибка при выполнении 1сv8.exe. Код ошибки: $($process.ExitCode)"

    Write-Output $logMessage

    if ($logDirectoryExist) {
        Add-Content -Path "$logDirectoryPath\logs.txt" -Value $logMessage
    }

    Exit
}

$dumpLog = Get-Content -Path "$($baseSettings.backupPath)\$currentTime-dump.log"
if ($dumpLog -contains "Выгрузка информационной базы успешно завершена") {
    $currentTime = Get-Date
    $logMessage = "$currentTime | Выгрузка информационной базы успешно завершена."

    Write-Output $logMessage

    if ($logDirectoryExist) {
        Add-Content -Path "$logDirectoryPath\logs.txt" -Value $logMessage
    }

    remove-Item -Path "$($baseSettings.backupPath)\$currentTime-dump.log"
}

Set-SFTPItem -SessionId $sftpSession.SessionId -Path "$($baseSettings.backupPath)/$currentTime-backup.dt" -Destination "/sftpuser"

Remove-Item -Path "$($baseSettings.backupPath)/$currentTime-backup.dt"