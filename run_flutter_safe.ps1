# Script PowerShell pour lancer Flutter en évitant les problèmes de chemins avec espaces
# Ce script configure l'environnement avant de lancer Flutter

Write-Host "Configuration de l'environnement pour éviter les problèmes de chemins avec espaces..." -ForegroundColor Yellow
Write-Host ""

# Définir le répertoire de build Gradle dans un endroit sans espaces
$tempDir = $env:TEMP
$gradleBuildDir = Join-Path $tempDir "keneya_muso_gradle_build"

# Créer le répertoire s'il n'existe pas
if (-not (Test-Path $gradleBuildDir)) {
    New-Item -ItemType Directory -Path $gradleBuildDir -Force | Out-Null
}

# Définir les variables d'environnement pour cette session
$env:GRADLE_USER_HOME = $gradleBuildDir
$env:ANDROID_USER_HOME = Join-Path $tempDir "android_home"

Write-Host "GRADLE_USER_HOME défini sur: $gradleBuildDir" -ForegroundColor Green
Write-Host ""

# Vérifier si l'argument "clean" est passé
if ($args -contains "clean") {
    Write-Host "Nettoyage du cache..." -ForegroundColor Yellow
    & C:\flutter\bin\flutter.bat clean
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors du nettoyage" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host "Lancement de Flutter..." -ForegroundColor Green
Write-Host ""

# Lancer Flutter
& C:\flutter\bin\flutter.bat run

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Erreur lors du lancement de Flutter" -ForegroundColor Red
    Write-Host "Conseil: Essayez de travailler depuis C:\Projects\Keneya_muso qui n'a pas d'espaces dans le chemin" -ForegroundColor Yellow
    exit $LASTEXITCODE
}

