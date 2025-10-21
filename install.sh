#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print section headers (thin rule)
print_header_rule() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Big ASCII header using heredoc
big_header() {
    local title="$1"
    echo -e "${CYAN}"
    case "$title" in
        "MAIN MENU")
cat <<'EOF'
 __  __    _    ___ _   _    __  __ _____ _   _ _   _ 
|  \/  |  / \  |_ _| \ | |  |  \/  | ____| \ | | | | |
| |\/| | / _ \  | ||  \| |  | |\/| |  _| |  \| | | | |
| |  | |/ ___ \ | || |\  |  | |  | | |___| |\  | |_| |
|_|  |_/_/   \_\___|_| \_|  |_|  |_|_____|_| \_|\___/ 
EOF
            ;;
        "SYSTEM INFORMATION")
cat <<'EOF'
________ ____   ____ ___  ___
\___   // __ \ /    \\  \/  /
 /    /\  ___/|   |  \>    < 
/_____ \\___  >___|  /__/\_ \
      \/    \/     \/      \/
EOF
            ;;
        "WELCOME")
cat <<'EOF'
________ ____   ____ ___  ___
\___   // __ \ /    \\  \/  /
 /    /\  ___/|   |  \>    < 
/_____ \\___  >___|  /__/\_ \
      \/    \/     \/      \/
EOF
            ;;
        *)
            echo -e "${BOLD}${title}${NC}"
            ;;
    esac
    echo -e "${NC}"
}

# Function to print status messages
print_status() { echo -e "${YELLOW}⏳ $1...${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${MAGENTA}⚠️  $1${NC}"; }

# Check if curl is installed
check_curl() {
    if ! command -v curl &>/dev/null; then
        print_error "curl is not installed"
        print_status "Installing curl..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y curl
        else
            print_error "Could not install curl automatically. Please install it manually"
            exit 1
        fi
        print_success "curl installed successfully"
    fi
}

# Function to run remote scripts
run_remote_script() {
    local url=$1
    local script_name
    script_name=$(basename "$url" .sh)
    script_name=$(echo "$script_name" | sed 's/.*/\u&/')

    print_header_rule
    big_header "WELCOME"
    print_header_rule
    echo -e "${CYAN}Running: ${BOLD}${script_name}${NC}"
    print_header_rule

    check_curl
    local temp_script
    temp_script=$(mktemp)
    print_status "Downloading script"

    if curl -fsSL "$url" -o "$temp_script"; then
        print_success "Download successful"
        chmod +x "$temp_script"
        bash "$temp_script"
        local exit_code=$?
        rm -f "$temp_script"
        if [ $exit_code -eq 0 ]; then
            print_success "Script executed successfully"
        else
            print_error "Script execution failed with exit code: $exit_code"
        fi
    else
        print_error "Failed to download script"
    fi

    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function to show system info
system_info() {
    print_header_rule
    big_header "SYSTEM INFORMATION"
    print_header_rule

    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║               📊 SYSTEM STATUS               ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Hostname:${NC} ${WHITE}$(hostname)${NC}                  ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}User:${NC} ${WHITE}$(whoami)${NC}                          ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Directory:${NC} ${WHITE}$(pwd)${NC}           ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}System:${NC} ${WHITE}$(uname -srm)${NC}              ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Uptime:${NC} ${WHITE}$(uptime -p | sed 's/up //')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Memory:${NC} ${WHITE}$(free -h | awk '/Mem:/ {print $3"/"$2}')${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${CYAN}•${NC} ${GREEN}Disk:${NC} ${WHITE}$(df -h / | awk 'NR==2 {print $3"/"$2 " ("$5")"}')${NC}        ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"

    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
}

# Function to display the main menu
show_menu() {
    clear
    print_header_rule
    echo -e "${CYAN}           🚀 ZENX HOSTING MANAGER            ${NC}"
    echo -e "${CYAN}              made by zenx                  ${NC}"
    print_header_rule

    big_header "MAIN MENU"
    print_header_rule

    echo -e "${WHITE}${BOLD}  1)${NC} ${CYAN}${BOLD}Panel Installation${NC}"
    echo -e "${WHITE}${BOLD}  2)${NC} ${CYAN}${BOLD}Wings Installation${NC}"
    echo -e "${WHITE}${BOLD}  3)${NC} ${CYAN}${BOLD}Panel Update${NC}"
    echo -e "${WHITE}${BOLD}  4)${NC} ${CYAN}${BOLD}Uninstall Tools${NC}"
    echo -e "${WHITE}${BOLD}  5)${NC} ${CYAN}${BOLD}Blueprint Setup${NC}"
    echo -e "${WHITE}${BOLD}  6)${NC} ${CYAN}${BOLD}Cloudflare Setup${NC}"
    echo -e "${WHITE}${BOLD}  7)${NC} ${CYAN}${BOLD}Change Theme${NC}"
    echo -e "${WHITE}${BOLD}  8)${NC} ${CYAN}${BOLD}System Information${NC}"
    echo -e "${WHITE}${BOLD}  9)${NC} ${CYAN}${BOLD}Tailscale (install + up)${NC}"
    echo -e "${WHITE}${BOLD}  0)${NC} ${RED}${BOLD}Exit${NC}"

    print_header_rule
    echo -e "${YELLOW}${BOLD}📝 Select an option [0-9]: ${NC}"
}

# Welcome animation with robust 'JISHNU' ASCII via heredoc
welcome_animation() {
    clear
    print_header_rule
    echo -e "${CYAN}"
cat <<'EOF'
________ ____   ____ ___  ___
\___   // __ \ /    \\  \/  /
 /    /\  ___/|   |  \>    < 
/_____ \\___  >___|  /__/\_ \
      \/    \/     \/      \/
EOF
    echo -e "${NC}"
    echo -e "${CYAN}                   Hosting Manager${NC}"
    print_header_rule
    sleep 1.2
}

# Main loop
welcome_animation

while true; do
    show_menu
    read -r choice

    case $choice in
        1) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/panel2.sh" ;;
        2) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/wing2.sh" ;;
        3) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/update2.sh" ;;
        4) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/uninstall2.sh" ;;
        5) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/Blueprint2.sh" ;;
        6) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/cloudflare.sh" ;;
        7) run_remote_script "https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/cd/th2.sh" ;;
        8) system_info ;;
        9)
            print_header_rule
            big_header "WELCOME"
            print_header_rule
            echo -e "${CYAN}Running: ${BOLD}Tailscale Installer${NC}"
            print_header_rule

            check_curl

            if curl -fsSL https://tailscale.com/install.sh | sh; then
                print_success "Tailscale installed successfully"
                if command -v systemctl &>/dev/null; then
                    sudo systemctl enable --now tailscaled || true
                fi
                echo -e "${CYAN}Bringing Tailscale up...${NC}"
                if [ -n "${TS_AUTH_KEY:-}" ]; then
                    sudo tailscale up --auth-key="$TS_AUTH_KEY" && print_success "Device authenticated via auth key" || print_error "tailscale up failed"
                else
                    sudo tailscale up && print_success "Device connected; approve/login completed" || print_error "tailscale up failed"
                    echo -e "${YELLOW}Tip: set TS_AUTH_KEY to enroll non-interactively next time.${NC}"
                fi
            else
                print_error "Tailscale installation failed"
            fi

            echo -e ""
            read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
            ;;
        0)
            echo -e "${GREEN}Exiting ZenX Hosting Manager...${NC}"
            print_header_rule
            echo -e "${CYAN}           Thank you for using our tools!       ${NC}"
            print_header_rule
            sleep 1
            exit 0
            ;;
        *)
            print_error "Invalid option! Please choose between 0-9"
            sleep 1.2
            ;;
    esac
done
