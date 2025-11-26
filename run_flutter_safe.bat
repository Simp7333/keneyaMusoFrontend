@echo off
REM Script batch pour lancer Flutter en évitant les problèmes de chemins avec espaces
echo Configuration de l'environnement pour eviter les problemes de chemins avec espaces...
echo.

REM Définir le répertoire Gradle dans un endroit sans espaces
set GRADLE_USER_HOME=%TEMP%\keneya_muso_gradle
set ANDROID_USER_HOME=%TEMP%\android_home

REM Créer le répertoire s'il n'existe pas
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

echo GRADLE_USER_HOME defini sur: %GRADLE_USER_HOME%
echo.

REM Vérifier si l'argument "clean" est passé
if "%1"=="clean" (
    echo Nettoyage du cache...
    C:\flutter\bin\flutter.bat clean
    if errorlevel 1 (
        echo Erreur lors du nettoyage
        pause
        exit /b 1
    )
)

echo Lancement de Flutter...
echo.

REM Lancer Flutter
C:\flutter\bin\flutter.bat run

if errorlevel 1 (
    echo.
    echo Erreur lors du lancement de Flutter
    echo.
    echo CONSEIL IMPORTANT:
    echo Votre projet contient des espaces dans le chemin: %CD%
    echo Pour eviter ce probleme, travaillez depuis: C:\Projects\Keneya_muso
    echo.
    pause
    exit /b 1
)

pause

