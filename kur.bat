@echo off
rem Video Indirici kurulumu (Windows).
rem Python ve ffmpeg dahil eksik olan her seyi windows-kur.ps1 kendisi kurar.
cd /d %~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows-kur.ps1"
pause
