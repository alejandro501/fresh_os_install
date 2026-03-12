# Tools Installed by `setup_toolkit.sh`

This file reflects what the current script installs on fresh Ubuntu.

## APT packages
- build-essential
- ca-certificates
- curl
- git
- gnupg
- jq
- lsb-release
- make
- nmap
- npm
- python3
- python3-pip
- software-properties-common
- tor
- unzip
- wget
- whois
- brave-browser
- firefox
- caido (if available in APT repositories)

## Go-installed tools
- assetfinder (`github.com/tomnomnom/assetfinder`)
- anew (`github.com/tomnomnom/anew`)
- httprobe (`github.com/tomnomnom/httprobe`)
- html-tool (`github.com/tomnomnom/hacks/html-tool`)
- waybackurls (`github.com/tomnomnom/waybackurls`)
- gobuster (`github.com/OJ/gobuster/v3`)
- subfinder (`github.com/projectdiscovery/subfinder/v2/cmd/subfinder`)
- httpx (`github.com/projectdiscovery/httpx/cmd/httpx`)
- nuclei (`github.com/projectdiscovery/nuclei/v3/cmd/nuclei`)
- sj (`github.com/BishopFox/sj`)
- jsluice (`github.com/BishopFox/jsluice/cmd/jsluice`)
- toxicache (`github.com/xhzeem/toxicache`)
- amass (`github.com/owasp-amass/amass/v4/cmd/amass`)
- ffuf (`github.com/ffuf/ffuf/v2`)
- h2csmuggler (`github.com/assetnote/h2csmuggler/cmd/h2csmuggler`)
- kiterunner (`github.com/assetnote/kiterunner/cmd/kiterunner`)

## Direct binary installs
- findomain (GitHub release binary)
- aquatone (GitHub release binary, desktop mode only)

## Snap packages (desktop mode)
- doctl
- google-cloud-cli
- marktext
- postman
- radare2
- searchsploit
- spotify

## Git-cloned resources and wordlists
- `https://github.com/alejandro501/bin.git` -> linked into `/usr/local/bin`
- `https://github.com/alejandro501/resources.git`
- `https://github.com/danielmiessler/SecLists.git`
- `https://github.com/projectdiscovery/nuclei-templates.git`

## Downloaded files/config
- Amass configs: `config.yaml`, `datasources.yaml`
- Wordlist files from:
  - `tomnomnom/meg` configfiles
  - `hAPI-hacker/Hacking-APIs` api_docs_path
  - your two header gists
- Kiterunner datasets:
  - routes-large.json.tar.gz
  - routes-small.json.tar.gz
