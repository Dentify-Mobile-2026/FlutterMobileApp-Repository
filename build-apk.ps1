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
if ($LASTEXITCODE -ne 0) { throw "Error en flutter pub get" }
flutter build apk --release --dart-define="API_BASE_URL=$ApiBaseUrl"
if ($LASTEXITCODE -ne 0) { throw "Error al compilar APK Release" }

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "==> APK generado en: $apkPath" -ForegroundColor Green

if ($FirebaseAppId -ne "") {
    Write-Host "==> Subiendo APK a Firebase App Distribution..." -ForegroundColor Cyan
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    firebase appdistribution:distribute $apkPath `
        --app $FirebaseAppId `
        --groups $TestersGroup `
        --release-notes $ReleaseNotes
    $fbCode = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($fbCode -ne 0) {
        throw "Fallo la subida a Firebase (HTTP/Auth). Ejecuta 'firebase login --reauth' con tu cuenta propietaria del proyecto o sube $apkPath arrastrandolo en Firebase Console."
    }
    Write-Host "==> APK distribuido correctamente al grupo '$TestersGroup'!" -ForegroundColor Green
}
