#!/usr/bin/env bash
# macOS: sunucuyu oturum açılışında otomatik başlatır (LaunchAgent kurar).
set -e
cd "$(dirname "$0")"
KLASOR="$(pwd)"
PLIST="$HOME/Library/LaunchAgents/com.video-indirici.plist"

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.video-indirici</string>
  <key>ProgramArguments</key>
  <array>
    <string>${KLASOR}/.venv/bin/python</string>
    <string>${KLASOR}/sunucu.py</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>StandardErrorPath</key><string>/tmp/video-indirici.log</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Tamam — sunucu artık her oturum açılışında kendiliğinden başlayacak."
