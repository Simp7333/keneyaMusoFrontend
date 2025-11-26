@echo off
REM Script pour lancer l'application Android en évitant les problèmes de chemins avec espaces
echo Configuration de l'environnement pour éviter les problèmes de chemins avec espaces...
echo.

REM Définir le répertoire de build dans un endroit sans espaces
set GRADLE_USER_HOME=%TEMP%\gradle_home
set ANDROID_USER_HOME=%TEMP%\android_home

REM Nettoyer le cache si nécessaire
if "%1"=="clean" (
    echo Nettoyage du cache...
    C:\flutter\bin\flutter.bat clean
    cd android
    call gradlew.bat clean
    cd ..
)

echo Lancement de l'application Android...
C:\flutter\bin\flutter.bat run

pause

