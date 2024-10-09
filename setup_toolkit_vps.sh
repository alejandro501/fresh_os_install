#!/bin/bash

APT_LIBS=("unzip")
GO_LIBS=("github.com/tomnomnom/assetfinder@latest"
         "github.com/tomnomnom/anew@latest"
         "github.com/tomnomnom/httprobe@master"
         "github.com/tomnomnom/fff@latest"
         "github.com/tomnomnom/gf@latest"
         "github.com/tomnomnom/hacks/html-tool@latest"
         "github.com/tomnomnom/waybackurls@latest"
         "github.com/OJ/gobuster/v3@latest"
         "github.com/michenriksen/aquatone@latest"
)
BINARIES=("https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip"
          "https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_386.tar.gz"
)
RESOURCES=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
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
    rm -rf ffuf  # Clean up cloned repository
}

install_command_line_tools(){
    # Update, Upgrade, Cleanup
    sudo apt update && sudo apt upgrade -y
    sudo apt autoclean && sudo apt autoremove -y

    # Install APT libraries
    for lib in "${APT_LIBS[@]}"; do
        sudo apt install -y $lib
    done

    # Install FFUF
    install_ffuf

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

    # Install Go tools
    for lib in "${GO_LIBS[@]}"; do
        go install $lib
    done
}

install_environment() {
    # Remove old Golang version if any
    sudo apt remove -y golang-go
    sudo rm -rf /usr/local/go

    # Set the Go version to download
    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | awk '{print $1}') # get version
    GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"  # set download url

    # Download the Go binary
    wget "$GO_URL" -O "go${GO_VERSION}.linux-amd64.tar.gz"  # Download the latest Go version

    # Check if the download was successful
    if [ ! -f "go${GO_VERSION}.linux-amd64.tar.gz" ]; then
        echo "Failed to download Go version ${GO_VERSION}. Please check your network connection."
        exit 1
    fi

    # Extract and install Go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"  # Clean up

    # Set up Go environment variables
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc

    # Reload .bashrc to apply changes
    source ~/.bashrc

    # Verify Go installation
    if command -v go > /dev/null; then
        echo "Go installed successfully: $(go version)"
    else
        echo "Go installation failed. Please check the installation."
    fi

    # Install python
    sudo apt install -y python3 python3-pip
}

setup_resources(){
    # Create hack directory if it doesn't exist
    mkdir -p ~/hack/resources/

    # Download additional resources
    for resource in "${RESOURCES[@]}"; do
        resource_name=$(basename "$resource")
        if [ ! -f "~/hack/resources/$resource_name" ]; then
            wget -P ~/hack/resources/ "$resource"
        fi
    done
}

main(){
    install_environment
    install_command_line_tools
    setup_resources
}

main
