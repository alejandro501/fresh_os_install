#!/bin/bash

# Constants
APT_LIBS=("unzip" "curl" "tor" "xclip" "jq" "nmap")
GO_LIBS=("github.com/tomnomnom/assetfinder@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/tomnomnom/httprobe@master"
    "github.com/tomnomnom/hacks/html-tool@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/OJ/gobuster/v3@latest"
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/BishopFox/sj@latest"
    "github.com/xhzeem/toxicache@latest"
    "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest" #v3
    "github.com/BishopFox/jsluice/cmd/jsluice@latest"
    "github.com/owasp-amass/amass/v4/...@master" #v4
)
BINARIES=("https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip"     #latest
    "https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_386.tar.gz" # 11.04.2021 - this is the latest version in 2024
)

AMASS_CONFIG=("https://raw.githubusercontent.com/owasp-amass/amass/refs/heads/master/examples/config.yaml"
    "https://raw.githubusercontent.com/owasp-amass/amass/refs/heads/master/examples/datasources.yaml"
)

WORDLISTS=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
    "https://raw.githubusercontent.com/hAPI-hacker/Hacking-APIs/refs/heads/main/api_docs_path"
    "https://gist.githubusercontent.com/alejandro501/b74499c764ec8b77c6579320db97c073/raw/4ddc1ebf8a08a55094ac71c488c8851d74db5df7/common-headers-small.txt"
    "https://gist.githubusercontent.com/alejandro501/fd7c2e16d957ef01662ed9e7f6eb2115/raw/e3f3b8c825853eb491a5730f5ecb2be4ae63a03c/common-headers-medium.txt"
)

CLONE_WORDLISTS=(
    "https://github.com/danielmiessler/SecLists.git"
)

KITERUNNER_JSONS=("https://wordlists-cdn.assetnote.io/rawdata/kiterunner/routes-large.json.tar.gz"
    "https://wordlists-cdn.assetnote.io/rawdata/kiterunner/routes-small.json.tar.gz")

GIT_CLONE="https://github.com/ffuf/ffuf"

# alejandro
BINARY_REPO_URL="https://github.com/alejandro501/bin.git"
RESOURCES_REPO_URL="git@github.com:alejandro501/resources.git"

# Functions
add_my_binaries() {
    TARGET_DIR="/opt/bin"

    sudo mkdir -p "$TARGET_DIR"

    if [ ! -d "$TARGET_DIR/bin" ]; then
        sudo git clone "$BINARY_REPO_URL" "$TARGET_DIR/bin"
        echo "Cloned $BINARY_REPO_URL into $TARGET_DIR."
    else
        echo "$TARGET_DIR/bin already exists. Skipping clone."
    fi

    for script in "$TARGET_DIR/bin/"*; do
        if [ -x "$script" ]; then
            script_name=$(basename "$script")
            sudo ln -sf "$script" "/usr/local/bin/$script_name"
            echo "Created symlink for $script_name in /usr/local/bin."
        fi
    done
}

install_ffuf() {
    git clone $GIT_CLONE
    cd ffuf || exit
    go get
    go build
    sudo mv ffuf /usr/local/bin/
    cd ..
    rm -rf ffuf
    echo "ffuf installed."
}

install_h2csmuggler() {
    git clone https://github.com/assetnote/h2csmuggler.git
    cd h2csmuggler || exit
    go build -o h2csmuggler ./cmd/h2csmuggler
    sudo mv h2csmuggler /usr/local/bin/
    cd ..
    rm -rf h2csmuggler
    echo "h2csmuggler installed."
}

install_aquatone() {
    DOWNLOAD_URL="https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip" # 19.05.2019

    curl -L -o aquatone.zip "$DOWNLOAD_URL"
    unzip aquatone.zip
    sudo mv aquatone /usr/local/bin/
    sudo chmod +x /usr/local/bin/aquatone
    rm aquatone.zip
    echo "aquatone installed."
}

install_command_line_tools() {
    sudo apt update && sudo apt upgrade -y
    sudo apt autoclean && sudo apt autoremove -y

    # Install APT libraries
    for lib in "${APT_LIBS[@]}"; do
        sudo apt install -y $lib
    done

    # Install binaries
    for url in "${BINARIES[@]}"; do
        filename=$(basename "$url")
        if [[ $url == *"findomain"* ]]; then
            curl -LO $url && unzip findomain-linux-i386.zip
            sudo mv findomain /usr/bin/findomain
        elif [[ $url == *"kiterunner"* ]]; then
            wget $url && tar -xf $filename
            make build
            sudo mv kr /usr/local/bin/
        fi
    done

    # Install go tools
    for lib in "${GO_LIBS[@]}"; do
        go install -v $lib
    done

    install_ffuf
    install_h2csmuggler
}

install_environment() {
    # go
    sudo apt install -y golang-go
    echo 'export GOPATH=$HOME/go' >>~/.bashrc
    echo 'export GOBIN=$GOPATH/bin' >>~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >>~/.bashrc
    echo 'export PATH=$PATH:~/go/bin' >>~/.bashrc
    source ~/.bashrc

    # python
    sudo apt install -y python3 python3-pip
}

setup_config() {
    # my custom config stuff
    mkdir -p ~/.config/.sol

    # amass
    mkdir -p "$HOME/.config/amass"

    for url in "${AMASS_CONFIG[@]}"; do
        filename=$(basename "$url") # Extract filename from URL
        curl -L "$url" -o "$HOME/.config/amass/$filename"
        echo "$filename downloaded to $HOME/.config/amass."
    done

    echo "Amass configuration and datasources set up at $HOME/.config/amass."

    # custom
}

setup_wordlists() {
    RESOURCES_DIR=~/hack
    if [[ ! -d $RESOURCES_DIR ]]; then
        git clone "$RESOURCES_REPO_URL" "$RESOURCES_DIR"
        echo "Resources cloned to $RESOURCES_DIR."
    else
        echo "Resources already exist in $RESOURCES_DIR."
    fi

    WORDLISTS_DIR="$RESOURCES_DIR/wordlists"
    [[ ! -d $WORDLISTS_DIR ]] && mkdir -p $WORDLISTS_DIR

    # gist
    for wordlist in "${WORDLISTS[@]}"; do
        if [[ ! -f "$WORDLISTS_DIR/$(basename $wordlist)" ]]; then
            wget -P "$WORDLISTS_DIR" "$wordlist"
        fi
    done

    # git
    for repo in "${CLONE_WORDLISTS[@]}"; do
        git clone "$repo"
        echo "Cloned $repo into the current directory."
    done

    # Download KiteRunner JSON datasets
    KITERUNNER_DIR="$RESOURCES_DIR/kiterunner"
    [[ ! -d $KITERUNNER_DIR ]] && mkdir -p $KITERUNNER_DIR
    for json_url in "${KITERUNNER_JSONS[@]}"; do
        wget -P "$KITERUNNER_DIR" "$json_url"
        tar -xf "$KITERUNNER_DIR/$(basename "$json_url")" -C "$KITERUNNER_DIR/"
    done

    # Download Nuclei templates
    NUCLEI_TEMPLATES_DIR="$WORDLISTS_DIR/nuclei-templates"
    if [[ ! -d $NUCLEI_TEMPLATES_DIR ]]; then
        git clone https://github.com/projectdiscovery/nuclei-templates.git "$NUCLEI_TEMPLATES_DIR"
        echo "Nuclei templates downloaded to $NUCLEI_TEMPLATES_DIR."
    else
        echo "Nuclei templates already exist in $NUCLEI_TEMPLATES_DIR."
    fi
}

generate_ssh_key() {
    if [[ -f "$HOME/.ssh/id_rsa" ]]; then
        echo "SSH key already exists. Skipping generation."
    else
        echo "Generating a new SSH key..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "$(whoami)@$(hostname).xyz"

        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa

        echo "SSH key generated. Your public key is:"
        cat ~/.ssh/id_rsa.pub
        echo "Copy this key and add it to your GitHub/Bitbucket/etc."
    fi
}

main() {
    DESKTOP=""

    while [[ "$1" != "" ]]; do
        case $1 in
        --no-desktop) DESKTOP=0 ;;
        --desktop) DESKTOP=1 ;;
        esac
        shift
    done

    if [[ "$DESKTOP" == "" ]]; then
        echo "Please choose one:"
        select choice in "Desktop" "No Desktop"; do
            case $choice in
            Desktop)
                DESKTOP=1
                break
                ;;
            "No Desktop")
                DESKTOP=0
                break
                ;;
            esac
        done
    fi

    install_environment
    install_command_line_tools
    add_my_binaries

    if [[ "$DESKTOP" == 1 ]]; then
        install_aquatone
    fi

    setup_wordlists
    generate_ssh_key
}

main "$@"
