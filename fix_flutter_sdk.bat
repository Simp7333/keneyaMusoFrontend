@echo off
echo ========================================
echo   REPARATION DU SDK FLUTTER
echo ========================================
echo.

echo Etape 1: Fermeture des processus Flutter...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM flutter_tester.exe 2>nul
timeout /t 2 >nul

echo.
echo Etape 2: Suppression du cache problematique...
rmdir /s /q "C:\flutter\bin\cache\dart-sdk" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache" 2>nul

echo.
echo Etape 3: Nettoyage du projet...
cd /d "%~dp0"
C:\flutter\bin\flutter.bat clean

echo.
echo Etape 4: Reparation du SDK Flutter...
C:\flutter\bin\flutter.bat doctor

echo.
echo Etape 5: Recuperation des dependances...
C:\flutter\bin\flutter.bat pub get

echo.
echo ========================================
echo   REPARATION TERMINEE
echo ========================================
echo.
echo Vous pouvez maintenant lancer:
echo   C:\flutter\bin\flutter.bat run
echo.
pause


