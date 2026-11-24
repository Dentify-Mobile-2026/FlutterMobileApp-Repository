<#
.SYNOPSIS
  Compila el APK release apuntando al backend en la nube y opcionalmente lo sube a Firebase App Distribution.
.EXAMPLE
  .\build-apk.ps1 -ApiBaseUrl "https://dentify-api-xxxx.azurewebsites.net/api/"
  .\build-apk.ps1 -ApiBaseUrl "https://dentify-api-xxxx.azurewebsites.net/api/" -FirebaseAppId "1:12345:android:abcde" -TestersGroup "equipo-dentify"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiBaseUrl,
    [string]$FirebaseAppId = "",
    [string]$TestersGroup = "equipo-dentify",
    [string]$ReleaseNotes = "Build release Dentify conectado a Azure"
)

$ErrorActionPreference = "Stop"

if (-not $ApiBaseUrl.EndsWith("/")) {
    $ApiBaseUrl = "$ApiBaseUrl/"
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue) -and (Test-Path "C:\Users\user\Documents\Programas\flutter\bin")) {
    $env:PATH = "C:\Users\user\Documents\Programas\flutter\bin;" + $env:PATH
}

Write-Host "==> Compilando APK Release apuntando a $ApiBaseUrl ..." -ForegroundColor Cyan
flutter pub get
flutter build apk --release --dart-define="API_BASE_URL=$ApiBaseUrl"

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "==> APK generado en: $apkPath" -ForegroundColor Green

if ($FirebaseAppId -ne "") {
    Write-Host "==> Subiendo APK a Firebase App Distribution..." -ForegroundColor Cyan
    firebase appdistribution:distribute $apkPath `
        --app $FirebaseAppId `
        --groups $TestersGroup `
        --release-notes $ReleaseNotes
    Write-Host "==> APK distribuido correctamente al grupo '$TestersGroup'!" -ForegroundColor Green
}
