# Automated Environment Setup

This script sets up a full development and reconnaissance environment with necessary tools, extensions, and configurations. It installs:

- **APT Libraries**
- **Go-Based Tools**
- **Binaries**
- **FFUF**
- **Desktop Applications**
- **Firefox Extensions**

## Features

### Extensions

- **Wappalyzer**: Technology profiler to identify the software on websites.
- **FoxyProxy**: Easily switch between proxy configurations.
- **Firefox Containers**: Helps isolate different browsing sessions for security and privacy.

### Command-Line Tools

#### APT Libraries
- `unzip`: Utility to extract ZIP files.
- `curl`: Tool for transferring data with URLs.
- `tor`: Anonymous network access tool.
- `xclip`: Command line clipboard copy/paste.
- `jq`: JSON processor.
- `nmap`: Network discovery and security auditing tool.

#### Go-Based Tools
- **assetfinder**: Find domains and subdomains related to target.
- **anew**: Appends new results to a file.
- **httprobe**: Probes domains for HTTP/HTTPS.
- **fff**: File find tool.
- **gf**: Pattern matching utility.
- **html-tool**: HTML parsing and manipulation.
- **waybackurls**: Fetch archived URLs from the Wayback Machine.
- **gobuster**: Directory and DNS brute-forcing.
- **subfinder**: Subdomain discovery tool.
- **sj (SwaggerJacker)**: Swagger file manipulation.
- **toxicache**: Tool for cache poisoning.

#### Binaries
- **Findomain**: Fast subdomain discovery tool.
- **Kiterunner**: Web path brute-forcing tool.

#### FFUF
- **ffuf**: Fast web fuzzer.

### Desktop Applications

- **Postman**: API development environment.
- **Caido**: Security analysis tool.
- **Discord**: Communication platform.

## Setup Instructions

### Prerequisites
Ensure you have `golang-go` and `python3` installed on your system.

### Running the Script

To run the script, execute the following command:

```sh
chmod +x setup_script.sh
./setup_script.sh
```
### Options
Run with --desktop to include desktop applications or --no-desktop to exclude them. """
Save the content to a README.md file
```sh
readme_file_path = "/mnt/data/README.md" with open(readme_file_path, "w") as file: file.write(readme_content)

readme_file_path
```
