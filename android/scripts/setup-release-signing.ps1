# One-time setup: upload keystore + key.properties for Play Store release builds.
# Run from repo root or mirumobileapp/android:
#   .\android\scripts\setup-release-signing.ps1

$ErrorActionPreference = "Stop"

function Resolve-KeytoolPath {
    if ($env:JAVA_HOME) {
        $fromJavaHome = Join-Path $env:JAVA_HOME "bin\keytool.exe"
        if (Test-Path $fromJavaHome) { return $fromJavaHome }
    }

    $candidates = @(
        "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
        "$env:LOCALAPPDATA\Programs\Android\Android Studio\jbr\bin\keytool.exe",
        "$env:ProgramFiles\Java\*\bin\keytool.exe",
        "$env:ProgramFiles\Eclipse Adoptium\*\bin\keytool.exe",
        "$env:ProgramFiles\Microsoft\jdk-*\bin\keytool.exe"
    )

    foreach ($pattern in $candidates) {
        $match = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) { return $match.FullName }
    }

    throw "keytool tidak ditemukan. Install JDK/Android Studio, atau set JAVA_HOME."
}

$androidDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$keystorePath = Join-Path $androidDir "upload-keystore.jks"
$keyPropsPath = Join-Path $androidDir "key.properties"
$keytool = Resolve-KeytoolPath

Write-Host "Menggunakan keytool: $keytool" -ForegroundColor DarkGray

if (Test-Path $keystorePath) {
    Write-Host "Keystore sudah ada: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Buat ulang? (y/N)"
    if ($overwrite -ne "y") { exit 0 }
}

$storePass = Read-Host "Password keystore (storePassword)" -AsSecureString
$keyPass = Read-Host "Password key (keyPassword, Enter = sama dengan keystore)" -AsSecureString

$storePassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePass)
)
$keyPassPlain = if ($keyPass.Length -eq 0) {
    $storePassPlain
} else {
    [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPass)
    )
}

$dname = "CN=MIRU Bank Sampah, OU=Mobile, O=MIRU, L=Mimika, ST=Papua, C=ID"

& $keytool -genkeypair -v `
    -keystore $keystorePath `
    -alias upload `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass $storePassPlain `
    -keypass $keyPassPlain `
    -dname $dname

@"
storePassword=$storePassPlain
keyPassword=$keyPassPlain
keyAlias=upload
storeFile=../upload-keystore.jks
"@ | Set-Content -Path $keyPropsPath -Encoding utf8NoBOM

Write-Host ""
Write-Host "Selesai." -ForegroundColor Green
Write-Host "  Keystore : $keystorePath"
Write-Host "  Config   : $keyPropsPath"
Write-Host ""
Write-Host "Build AAB (PowerShell):" -ForegroundColor Cyan
Write-Host '  cd mirumobileapp'
Write-Host '  flutter build appbundle --dart-define=API_BASE_URL=https://api.dev.mirubanksampah.id'
Write-Host ""
Write-Host "Simpan password dan backup keystore di tempat aman. Jangan commit ke git." -ForegroundColor Yellow
