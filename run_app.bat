@echo off
echo Lancement de KéneyaMouso App...
echo.
echo Choisissez votre plateforme :
echo 1. Chrome (Web)
echo 2. Edge (Web)  
echo 3. Windows (Desktop)
echo.
set /p choice="Entrez votre choix (1-3): "

if "%choice%"=="1" (
    echo Lancement sur Chrome...
    C:\flutter\bin\flutter.bat run -d chrome
) else if "%choice%"=="2" (
    echo Lancement sur Edge...
    C:\flutter\bin\flutter.bat run -d edge
) else if "%choice%"=="3" (
    echo Lancement sur Windows...
    C:\flutter\bin\flutter.bat run -d windows
) else (
    echo Choix invalide. Lancement par défaut sur Chrome...
    C:\flutter\bin\flutter.bat run -d chrome
)

pause

