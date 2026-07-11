@echo off
rem Windows: sunucuyu oturum acilisinda gizli pencerede otomatik baslatir.
cd /d %~dp0
set VBS=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\VideoIndirici.vbs
> "%VBS%" echo Set ws = CreateObject("Wscript.Shell")
>> "%VBS%" echo ws.Run """%~dp0baslat.bat""", 0
echo Tamam - sunucu artik her oturum acilisinda kendiliginden baslayacak.
echo Simdi baslatmak icin baslat.bat calistirin veya oturumu yeniden acin.
pause
