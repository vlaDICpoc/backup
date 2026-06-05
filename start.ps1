for ($i = 1; $i -le 20; $i++) {
    Write-Host "Запуск №$i"

    & ".\backup.ps1"

    Start-Sleep -Seconds 2
}
