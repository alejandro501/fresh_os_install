#!/bin/bash

APT_LIBS=("unzip" "curl")
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
)
BINARIES=("https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip" #latest
          "https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_386.tar.gz" # 11.04.2021
)
WORDLISTS=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
           "https://gist.githubusercontent.com/alejandro501/b74499c764ec8b77c6579320db97c073/raw/4ddc1ebf8a08a55094ac71c488c8851d74db5df7/common-headers-small.txt"
           "https://gist.githubusercontent.com/alejandro501/fd7c2e16d957ef01662ed9e7f6eb2115/raw/e3f3b8c825853eb491a5730f5ecb2be4ae63a03c/common-headers-medium.txt"
)

GIT_CLONE="https://github.com/ffuf/ffuf"

install_ffuf(){
    git clone $GIT_CLONE
    cd ffuf || exit
    go get
    go build
    sudo mv ffuf /usr/local/bin/
    cd ..
    rm -rf ffuf
    echo "ffuf installed."
}

install_h2csmuggler(){
    git clone https://github.com/assetnote/h2csmuggler.git
    cd h2csmuggler || exit
    go build -o h2csmuggler ./cmd/h2csmuggler
    sudo mv h2csmuggler /usr/local/bin/
    cd ..
    rm -rf h2csmuggler
    echo "h2csmuggler installed."
}

install_aquatone(){
    DOWNLOAD_URL="https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip" # 19.05.2019

    curl -L -o aquatone.zip "$DOWNLOAD_URL"
    unzip aquatone.zip
    sudo mv aquatone /usr/local/bin/
    sudo chmod +x /usr/local/bin/aquatone
    rm aquatone.zip
    echo "aquatone installed."
}

install_command_line_tools(){
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

    # Install Aquatone
    install_aquatone

    # Install go tools
    for lib in "${GO_LIBS[@]}"; do
        go install -v $lib
    done

    install_ffuf
    install_h2csmuggler
}

install_environment(){
    # Install Golang
    sudo apt install -y golang-go
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc
    echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc  # Add Go binaries path
    source ~/.bashrc

    sudo apt install -y python3 python3-pip
}

setup_wordlists(){
    # Check and create hack wordlists folder if necessary
    [[ ! -d ~/hack/resources/wordlists ]] && mkdir -p ~/hack/resources/wordlists/
    
    # Download additional wordlist resources if they don't already exist
    for wordlist in "${WORDLISTS[@]}"; do
        if [[ ! -f ~/hack/resources/wordlists/$(basename $wordlist) ]]; then
            wget -P ~/hack/resources/wordlists/ "$wordlist"
        fi
    done

    # Download Nuclei templates
    NUCLEI_TEMPLATES_DIR=~/hack/resources/wordlists/nuclei-templates
    if [[ ! -d $NUCLEI_TEMPLATES_DIR ]]; then
        git clone https://github.com/projectdiscovery/nuclei-templates.git $NUCLEI_TEMPLATES_DIR
        echo "Nuclei templates downloaded to $NUCLEI_TEMPLATES_DIR."
    else
        echo "Nuclei templates already exist in $NUCLEI_TEMPLATES_DIR."
    fi
}

main(){
    install_environment
    install_command_line_tools
    setup_wordlists
}

main

