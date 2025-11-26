@echo off
echo ========================================
echo   KENEYA MUSO - Demarrage Debug
echo ========================================
echo.

echo Nettoyage du cache...
C:\flutter\bin\flutter.bat clean

echo.
echo Recuperation des dependances...
C:\flutter\bin\flutter.bat pub get

echo.
echo Lancement de l'application en mode debug...
C:\flutter\bin\flutter.bat run

pause

