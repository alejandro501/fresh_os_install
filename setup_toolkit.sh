#!/usr/bin/env bash
set -euo pipefail

APT_LIBS=(
  "build-essential"
  "ca-certificates"
  "curl"
  "git"
  "gnupg"
  "jq"
  "lsb-release"
  "make"
  "nmap"
  "npm"
  "python3"
  "python3-pip"
  "software-properties-common"
  "tor"
  "unzip"
  "wget"
  "whois"
)

GO_TOOLS=(
  "github.com/tomnomnom/assetfinder@latest"
  "github.com/tomnomnom/anew@latest"
  "github.com/tomnomnom/httprobe@latest"
  "github.com/tomnomnom/hacks/html-tool@latest"
  "github.com/tomnomnom/waybackurls@latest"
  "github.com/OJ/gobuster/v3@latest"
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/BishopFox/sj@latest"
  "github.com/BishopFox/jsluice/cmd/jsluice@latest"
  "github.com/xhzeem/toxicache@latest"
  "github.com/owasp-amass/amass/v4/cmd/amass@latest"
  "github.com/ffuf/ffuf/v2@latest"
  "github.com/assetnote/h2csmuggler/cmd/h2csmuggler@latest"
  "github.com/assetnote/kiterunner/cmd/kiterunner@latest"
)

AMASS_CONFIG=(
  "https://raw.githubusercontent.com/owasp-amass/amass/refs/heads/master/examples/config.yaml"
  "https://raw.githubusercontent.com/owasp-amass/amass/refs/heads/master/examples/datasources.yaml"
)

WORDLISTS=(
  "https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
  "https://raw.githubusercontent.com/hAPI-hacker/Hacking-APIs/refs/heads/main/api_docs_path"
  "https://gist.githubusercontent.com/alejandro501/b74499c764ec8b77c6579320db97c073/raw/4ddc1ebf8a08a55094ac71c488c8851d74db5df7/common-headers-small.txt"
  "https://gist.githubusercontent.com/alejandro501/fd7c2e16d957ef01662ed9e7f6eb2115/raw/e3f3b8c825853eb491a5730f5ecb2be4ae63a03c/common-headers-medium.txt"
)

CLONE_WORDLISTS=(
  "https://github.com/danielmiessler/SecLists.git"
)

SNAP_PACKAGES=(
  "doctl"
  "google-cloud-cli"
  "marktext"
  "postman"
  "radare2"
  "searchsploit"
  "spotify"
)

KITERUNNER_JSONS=(
  "https://wordlists-cdn.assetnote.io/rawdata/kiterunner/routes-large.json.tar.gz"
  "https://wordlists-cdn.assetnote.io/rawdata/kiterunner/routes-small.json.tar.gz"
)

EXTRA_APT_PACKAGES=("brave-browser" "firefox" "caido")

BINARY_REPO_URL="https://github.com/alejandro501/bin.git"
RESOURCES_REPO_URL="https://github.com/alejandro501/resources.git"

ensure_bashrc_line() {
  local line="$1"
  grep -Fqx "$line" "$HOME/.bashrc" || echo "$line" >>"$HOME/.bashrc"
}

add_extra_repos() {
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSLo /tmp/brave.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  sudo install -D -m 0644 /tmp/brave.gpg /etc/apt/keyrings/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" |
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null

  rm -f /tmp/brave.gpg
}

apt_has_candidate() {
  local pkg="$1"
  local candidate
  candidate=$(apt-cache policy "$pkg" 2>/dev/null | awk '/Candidate:/ {print $2}')
  [[ -n "$candidate" && "$candidate" != "(none)" ]]
}

add_my_binaries() {
  local target_dir="/opt/bin"

  if [[ -d "$target_dir/.git" ]]; then
    sudo git -C "$target_dir" pull --ff-only
  elif [[ -e "$target_dir" ]]; then
    echo "$target_dir exists but is not a git repo. Skipping clone for safety."
  else
    sudo git clone "$BINARY_REPO_URL" "$target_dir"
  fi

  for script in "$target_dir/"*; do
    if [[ -x "$script" ]]; then
      local script_name
      script_name=$(basename "$script")
      sudo ln -sf "$script" "/usr/local/bin/$script_name"
      echo "Linked /usr/local/bin/$script_name"
    fi
  done
}

install_findomain_binary() {
  local tmp_dir
  tmp_dir=$(mktemp -d)
  local urls=(
    "https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip"
    "https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip"
  )

  for url in "${urls[@]}"; do
    if curl -fsSL "$url" -o "$tmp_dir/findomain.zip"; then
      unzip -qo "$tmp_dir/findomain.zip" -d "$tmp_dir"
      if [[ -f "$tmp_dir/findomain" ]]; then
        sudo install -m 0755 "$tmp_dir/findomain" /usr/local/bin/findomain
        rm -rf "$tmp_dir"
        echo "Installed findomain from $url"
        return
      fi
    fi
  done

  rm -rf "$tmp_dir"
  echo "Failed to install findomain binary." >&2
}

install_aquatone() {
  local download_url="https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  curl -fsSL "$download_url" -o "$tmp_dir/aquatone.zip"
  unzip -qo "$tmp_dir/aquatone.zip" -d "$tmp_dir"
  sudo install -m 0755 "$tmp_dir/aquatone" /usr/local/bin/aquatone

  rm -rf "$tmp_dir"
  echo "Installed aquatone."
}

install_environment() {
  sudo apt update
  sudo apt upgrade -y
  sudo apt autoclean -y
  sudo apt autoremove -y

  sudo apt install -y golang-go

  ensure_bashrc_line 'export GOPATH="$HOME/go"'
  ensure_bashrc_line 'export GOBIN="$GOPATH/bin"'
  ensure_bashrc_line 'export PATH="$PATH:/usr/local/go/bin:$GOBIN"'
  ensure_bashrc_line 'export PATH="$PATH:/opt/bin"'
}

install_command_line_tools() {
  add_extra_repos
  sudo apt update

  for lib in "${APT_LIBS[@]}"; do
    sudo apt install -y "$lib"
  done

  for pkg in "${EXTRA_APT_PACKAGES[@]}"; do
    if apt_has_candidate "$pkg"; then
      sudo apt install -y "$pkg"
    else
      echo "Skipping $pkg (no APT candidate on this system)."
    fi
  done

  install_findomain_binary

  export GOPATH="${GOPATH:-$HOME/go}"
  export GOBIN="${GOBIN:-$GOPATH/bin}"
  export PATH="$PATH:$GOBIN"
  mkdir -p "$GOBIN"

  for lib in "${GO_TOOLS[@]}"; do
    go install -v "$lib"
  done
}

setup_config() {
  mkdir -p "$HOME/.config/.sol"
  mkdir -p "$HOME/.config/amass"

  for url in "${AMASS_CONFIG[@]}"; do
    local filename
    filename=$(basename "$url")
    curl -fsSL "$url" -o "$HOME/.config/amass/$filename"
  done
}

setup_wordlists() {
  local resources_dir="$HOME/hack/resources"
  local wordlists_dir="$resources_dir/wordlists"

  if [[ ! -d "$resources_dir/.git" ]]; then
    mkdir -p "$HOME/hack"
    git clone "$RESOURCES_REPO_URL" "$resources_dir"
  else
    git -C "$resources_dir" pull --ff-only
  fi

  mkdir -p "$wordlists_dir"

  for wordlist in "${WORDLISTS[@]}"; do
    local target
    target="$wordlists_dir/$(basename "$wordlist")"
    if [[ ! -f "$target" ]]; then
      curl -fsSL "$wordlist" -o "$target"
    fi
  done

  for repo in "${CLONE_WORDLISTS[@]}"; do
    local name
    name=$(basename "$repo" .git)
    local target_dir="$wordlists_dir/$name"

    if [[ ! -d "$target_dir/.git" ]]; then
      git clone "$repo" "$target_dir"
    else
      git -C "$target_dir" pull --ff-only
    fi
  done

  local kiterunner_dir="$resources_dir/kiterunner"
  mkdir -p "$kiterunner_dir"

  for json_url in "${KITERUNNER_JSONS[@]}"; do
    local archive_path="$kiterunner_dir/$(basename "$json_url")"
    curl -fsSL "$json_url" -o "$archive_path"
    tar -xf "$archive_path" -C "$kiterunner_dir/"
  done

  local nuclei_templates_dir="$wordlists_dir/nuclei-templates"
  if [[ ! -d "$nuclei_templates_dir/.git" ]]; then
    git clone https://github.com/projectdiscovery/nuclei-templates.git "$nuclei_templates_dir"
  else
    git -C "$nuclei_templates_dir" pull --ff-only
  fi
}

install_snap_packages() {
  if ! command -v snap >/dev/null 2>&1; then
    echo "snap is not available, skipping snap package installs."
    return
  fi

  for pkg in "${SNAP_PACKAGES[@]}"; do
    if [[ "$pkg" == "code" ]]; then
      sudo snap install --classic "$pkg"
    else
      sudo snap install "$pkg"
    fi
  done
}

generate_ssh_key() {
  if [[ -f "$HOME/.ssh/id_rsa" ]]; then
    echo "SSH key already exists. Skipping generation."
    return
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "$(whoami)@$(hostname).xyz"

  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_rsa"

  echo "SSH public key:"
  cat "$HOME/.ssh/id_rsa.pub"
}

verify_essential_tools() {
  local tools=(
    "go"
    "ffuf"
    "h2csmuggler"
    "kiterunner"
    "assetfinder"
    "anew"
    "httprobe"
    "waybackurls"
    "gobuster"
    "subfinder"
    "httpx"
    "nuclei"
    "jsluice"
    "amass"
    "findomain"
    "nmap"
    "jq"
    "curl"
  )

  echo
  echo "Essential tool check:"
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf '  [OK] %s -> %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  [MISSING] %s\n' "$tool"
    fi
  done
}

main() {
  local desktop=""

  while [[ "${1:-}" != "" ]]; do
    case "$1" in
    --no-desktop) desktop=0 ;;
    --desktop) desktop=1 ;;
    esac
    shift
  done

  if [[ -z "$desktop" ]]; then
    echo "Please choose one:"
    select choice in "Desktop" "No Desktop"; do
      case "$choice" in
      Desktop)
        desktop=1
        break
        ;;
      "No Desktop")
        desktop=0
        break
        ;;
      esac
    done
  fi

  install_environment
  install_command_line_tools
  add_my_binaries
  setup_config

  if [[ "$desktop" == "1" ]]; then
    install_aquatone
    install_snap_packages
  fi

  setup_wordlists
  generate_ssh_key
  verify_essential_tools
}

main "$@"
