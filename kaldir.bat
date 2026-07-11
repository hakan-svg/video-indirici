@echo off
rem PKD - Post Kreatif Downloader'i Windows'tan tamamen kaldirir.
rem Indirilen videolara DOKUNMAZ (Downloads\PKD durur).

echo ==^> PKD kaldiriliyor...

rem 1) Baslangictaki otomatik baslatma kisayolu
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\VideoIndirici.vbs" 2>nul

rem 2) Calisan sunucuyu durdur
wmic process where "CommandLine like '%%sunucu.py%%'" delete >nul 2>nul

echo.
echo Kaldirildi. Son iki adim (elle):
echo   1) Chrome ^> chrome://extensions ^> PKD kartinda 'Kaldir'a tikla
echo   2) Bu klasoru (PKD-Post-Kreatif-Downloader) copa tasi
echo.
echo Indirilen videolar duruyor: Downloads\PKD - istersen elle silebilirsin.
pause
