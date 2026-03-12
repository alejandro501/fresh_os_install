# Current System Tool Inventory

Snapshot from this machine (2026-03-12), focused on `/usr/local/bin`, `~/go/bin`, and `/opt`.

## /usr/local/bin
- aquatone
- docker-compose
- ffuf
- generate_dork_links
- generate_dorks
- h2csmuggler
- idle3.14
- kr
- ollama
- packettracer
- palera1n
- pip3.14
- postman
- pydoc3.14
- python3.14
- python3.14-config
- r2
- r2-indent
- r2agent
- r2p
- r2pm
- r2r
- rabin2
- radare2
- radiff2
- rafind2
- ragg2
- rahash2
- rapatch2
- rarun2
- rasign2
- rasm2
- ravc2
- rax2

## ~/go/bin
- amass
- anew
- assetfinder
- crush
- ffuf
- gobuster
- gopls
- html-tool
- httprobe
- httpx
- jsluice
- nuclei
- sj
- staticcheck
- subfinder
- swag
- toxicache
- waybackurls

## /opt/bin (custom scripts)
- color_me.sh
- enumerate_subdomains.sh
- generate_dork_links.sh
- message_discord.sh
- postman_extract_url.sh
- setup_tor.sh
- sort_http.sh

## /opt (installed apps/tools directories)
- /opt/Caido
- /opt/Cursor
- /opt/Postman
- /opt/Session
- /opt/bin
- /opt/brave.com
- /opt/google
- /opt/microsoft
- /opt/nessus
- /opt/platform-tools
- /opt/pt
- /opt/redisinsight

## Desktop Entries (explicitly deployed apps)
- /usr/share/applications/caido.desktop
- /usr/share/applications/cursor.desktop
- /usr/share/applications/cursor-url-handler.desktop
- /home/rojo/.local/share/applications/postman.desktop
- /usr/share/applications/brave-browser.desktop
- /usr/share/applications/com.brave.Browser.desktop
- /usr/share/applications/code.desktop
- /usr/share/applications/code-url-handler.desktop
- /usr/share/applications/google-chrome.desktop
- /usr/share/applications/com.google.Chrome.desktop
- /usr/share/applications/firefox.desktop
- /home/rojo/.local/share/applications/userapp-Firefox-Z7WNV2.desktop
- /usr/share/applications/CiscoPacketTracer-9.0.0.desktop
- /usr/share/applications/CiscoPacketTracerPtsa-9.0.0.desktop
- /usr/share/applications/redisinsight.desktop
- /home/rojo/.local/share/applications/session.desktop
- /var/lib/snapd/desktop/applications/dbeaver-ce_dbeaver-ce.desktop
- /var/lib/snapd/desktop/applications/marktext_marktext.desktop
- /var/lib/snapd/desktop/applications/spotify_spotify.desktop

---

# Fresh Ubuntu Setup

Use `setup_toolkit.sh` for a full setup on a new Ubuntu system.

Reference tool/install list: `tools2setup.md`

## Planned Desktop Deployment (After Pruning)
- Keep: `caido`, `brave-browser`, `firefox`, `postman`, `spotify`, `searchsploit`, `radare2`, `marktext`, `google-cloud-cli`, `doctl`
- Removed from installer: `cursor`, `redisinsight`, `dbeaver-ce`, `code`, `google-chrome-stable`
- Desktop entry handling:
  - Apps installed via APT/Snap rely on their package-provided `.desktop` files.
  - Manual desktop-entry creation is only needed if an app is not available in APT/Snap.
