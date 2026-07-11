# PKD - Post Kreatif Downloader, Windows'ta TEK KOMUTLA kurulum.
# Baslat menusune "powershell" yazip actiktan sonra sunu yapistirmak yeterli:
#   irm https://raw.githubusercontent.com/hakan-svg/PKD-Post-Kreatif-Downloader/main/windows-kur.ps1 | iex
# Python ve ffmpeg dahil her seyi kendisi kurar; yonetici yetkisi gerekmez.
# (kur.bat da ayni dosyayi calistirir; o zaman indirme adimi atlanir.)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$DEPO = 'https://github.com/hakan-svg/PKD-Post-Kreatif-Downloader'
$PYTHON_KURUCU = 'https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe'
$FFMPEG_ZIP = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'

# kur.bat ile programin icinden calisiyorsak o klasoru kullan;
# tek komutla (irm | iex) calisiyorsak once programi indirecegiz.
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'sunucu.py'))) {
    $DIZIN = $PSScriptRoot
    $PROGRAMI_INDIR = $false
} else {
    $DIZIN = Join-Path $env:USERPROFILE 'video-indirici'
    $PROGRAMI_INDIR = $true
}

Write-Host "==> PKD kuruluyor: $DIZIN"

function Python-Uygun($exe) {
    if (-not $exe -or -not (Test-Path $exe)) { return $false }
    try {
        & $exe -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null
        return ($LASTEXITCODE -eq 0)
    } catch { return $false }
}

function Python-Bul {
    # py baslaticisi
    if (Get-Command py -ErrorAction SilentlyContinue) {
        try {
            $exe = (& py -3 -c "import sys; print(sys.executable)" 2>$null)
            if ($exe) { $exe = $exe.Trim(); if (Test-Path $exe) { return $exe } }
        } catch {}
    }
    # PATH'teki python (Microsoft Store'un sahte python.exe'sini ele)
    foreach ($ad in 'python', 'python3') {
        $k = Get-Command $ad -ErrorAction SilentlyContinue
        if ($k -and $k.Source -and $k.Source -notmatch 'WindowsApps') { return $k.Source }
    }
    # Bilinen kurulum yerleri
    $adaylar = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe" `
        -ErrorAction SilentlyContinue | Sort-Object FullName -Descending
    if ($adaylar) { return $adaylar[0].FullName }
    return $null
}

# 1) Python (yoksa python.org'dan sessiz kurulur; PATH'e de eklenir)
$PY = Python-Bul
if (-not (Python-Uygun $PY)) {
    Write-Host '==> Python kuruluyor (birkac dakika surebilir)...'
    $kurucu = Join-Path $env:TEMP 'python-kurucu.exe'
    Invoke-WebRequest $PYTHON_KURUCU -OutFile $kurucu -UseBasicParsing
    $islem = Start-Process $kurucu -Wait -PassThru `
        -ArgumentList '/quiet', 'InstallAllUsers=0', 'PrependPath=1', 'Include_test=0'
    if ($islem.ExitCode -ne 0) { throw "Python kurulumu basarisiz oldu (kod $($islem.ExitCode))." }
    Remove-Item $kurucu -ErrorAction SilentlyContinue
    $PY = Python-Bul
    if (-not (Python-Uygun $PY)) { throw 'Python kuruldu ama bulunamadi. Bilgisayari yeniden baslatip tekrar dene.' }
}

# 2) Programi indir (git gerekmez)
if ($PROGRAMI_INDIR) {
    Write-Host '==> Program indiriliyor...'
    New-Item -ItemType Directory -Force -Path $DIZIN | Out-Null
    $zip = Join-Path $env:TEMP 'pkd.zip'
    $acilan = Join-Path $env:TEMP 'pkd-acilan'
    Invoke-WebRequest "$DEPO/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
    Remove-Item $acilan -Recurse -Force -ErrorAction SilentlyContinue
    Expand-Archive $zip -DestinationPath $acilan
    $ic = Get-ChildItem $acilan -Directory | Select-Object -First 1
    Copy-Item (Join-Path $ic.FullName '*') $DIZIN -Recurse -Force
    Remove-Item $zip, $acilan -Recurse -Force -ErrorAction SilentlyContinue
}

# 3) ffmpeg (PATH'te yoksa program klasorune indirilir; sunucu orayi da bilir)
$ffmpegKlasoru = Join-Path $DIZIN 'ffmpeg'
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue) `
    -and -not (Test-Path (Join-Path $ffmpegKlasoru 'ffmpeg.exe'))) {
    Write-Host '==> ffmpeg indiriliyor (birkac dakika surebilir)...'
    $fzip = Join-Path $env:TEMP 'ffmpeg.zip'
    $facilan = Join-Path $env:TEMP 'ffmpeg-acilan'
    Invoke-WebRequest $FFMPEG_ZIP -OutFile $fzip -UseBasicParsing
    Remove-Item $facilan -Recurse -Force -ErrorAction SilentlyContinue
    Expand-Archive $fzip -DestinationPath $facilan
    New-Item -ItemType Directory -Force -Path $ffmpegKlasoru | Out-Null
    Get-ChildItem $facilan -Recurse -Include 'ffmpeg.exe', 'ffprobe.exe' |
        Copy-Item -Destination $ffmpegKlasoru -Force
    Remove-Item $fzip, $facilan -Recurse -Force -ErrorAction SilentlyContinue
}

# 4) Calisan eski sunucu varsa durdur (dosyalari kilitlemesin)
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'sunucu\.py' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

# 5) Python ortami
Write-Host '==> Python ortami hazirlaniyor...'
& $PY -m venv (Join-Path $DIZIN '.venv')
& (Join-Path $DIZIN '.venv\Scripts\python.exe') -m pip install -q -U pip 'yt-dlp[default,curl-cffi]'
if ($LASTEXITCODE -ne 0) { throw 'yt-dlp kurulumu basarisiz oldu.' }

# 6) Oturum acilisinda otomatik baslatma + sunucuyu hemen baslat
$VBS = Join-Path ([Environment]::GetFolderPath('Startup')) 'VideoIndirici.vbs'
@"
Set ws = CreateObject("Wscript.Shell")
ws.Run """$DIZIN\baslat.bat""", 0
"@ | Set-Content -Path $VBS -Encoding Unicode
Start-Process wscript.exe -ArgumentList "`"$VBS`""

# 7) Chrome'da eklenti sayfasini, Explorer'da eklenti klasorunu ac
Start-Process explorer.exe "/select,`"$DIZIN\eklenti`""
try { Start-Process chrome.exe 'chrome://extensions/' } catch {}

Write-Host ''
Write-Host '[OK] Kurulum bitti. Sunucu calisiyor ve bilgisayar her acildiginda kendiliginden baslayacak.'
Write-Host ''
Write-Host 'Son adim - Chrome''da (30 saniye, bir kereligine):'
Write-Host "  1) Acilan chrome://extensions sayfasinda sag ustten 'Gelistirici modu'nu ac"
Write-Host "  2) 'Paketlenmemis oge yukle' dugmesine tikla, Explorer'da isaretlenen"
Write-Host "     'eklenti' klasorunu sec (veya klasoru sayfanin uzerine surukle)"
