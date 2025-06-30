#!/bin/bash

# =============================================
# Vulnerability Scanner - MultiTool Edition
# Created by: Deep.code | Deepani V S
# Project: Vulnerability Scanning Tool | Marwadi University
# Version: 1.0
# =============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
function show_banner() {
    clear
    echo -e "${GREEN}"
    echo "███████╗██╗     ███████╗███████╗"
    echo "██╔════╝██║     ██╔════╝██╔════╝"
    echo "█████╗  ██║     █████╗  █████╗  "
    echo "██╔══╝  ██║     ██╔══╝  ██╔══╝  "
    echo "███████╗███████╗██║     ███████╗"
    echo "╚══════╝╚══════╝╚═╝     ╚══════╝"
    echo -e "${CYAN}"
    echo "███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██████╗ "
    echo "╚══███╔╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔════╝██╔══██╗"
    echo "  ███╔╝ ██║     ███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝"
    echo " ███╔╝  ██║     ██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗"
    echo "███████╗╚██████╗██║  ██║██║ ╚████║██║ ╚████║███████╗██║  ██║"
    echo "╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"
    echo -e "${BLUE}===================================================${NC}"
    echo -e " ${YELLOW}Multi-Tool Vulnerability Scanner v3.0${NC}"
    echo -e " ${GREEN}Created by: Deep.code | Deepani V S${NC}"
    echo -e " ${CYAN}Project: Vulnerability Scanning Tools | Marwadi University${NC}"
    echo -e " ${YELLOW}LinkedIn: www.linkedin.com/in/deepani-v-s-272b62259${NC}"
    echo -e "${BLUE}===================================================${NC}"
    echo ""
}

# Tools Installation Check
function check_tools() {
    local missing=()
    
    # Required tools
    local tools=("nmap" "whatweb" "dnsrecon" "dirb" "gobuster" "nikto" "sqlmap" "whois" "sublist3r" "theharvester")
    
    for tool in "${tools[@]}"; do
        if ! command -v $tool &>/dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}[!] Missing tools: ${missing[*]}${NC}"
        read -p "Would you like to install missing tools? (y/n): " install_choice
        if [ "$install_choice" = "y" ]; then
            if command -v apt &>/dev/null; then
                sudo apt update
                sudo apt install -y ${missing[*]}
            elif command -v yum &>/dev/null; then
                sudo yum install -y ${missing[*]}
            else
                echo -e "${RED}[!] Package manager not found. Please install manually.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}[!] Some features may not work without these tools.${NC}"
            sleep 2
        fi
    fi
}

# Scan Functions

# Advanced Nmap Scan
function advanced_nmap() {
    echo -e "${YELLOW}[*] Running Advanced Nmap Scan...${NC}"
    local options=("Full Scan (-A -T4)" "Quick Scan (-F)" "Vulnerability Scan (--script vuln)" "Custom Scan")
    PS3="Select scan type: "
    select opt in "${options[@]}"; do
        case $opt in
            "Full Scan (-A -T4)")
                nmap -A -T4 "$target"
                break
                ;;
            "Quick Scan (-F)")
                nmap -F "$target"
                break
                ;;
            "Vulnerability Scan (--script vuln)")
                nmap --script vuln "$target"
                break
                ;;
            "Custom Scan")
                read -p "Enter custom Nmap arguments: " custom_args
                nmap $custom_args "$target"
                break
                ;;
            *) echo -e "${RED}Invalid option!${NC}";;
        esac
    done
}

# Web Security Suite
function web_security_suite() {
    echo -e "${YELLOW}[*] Running Web Security Suite...${NC}"
    whatweb -a 3 "$target"
    echo -e "\n${BLUE}[*] Checking for SQL Injection vulnerabilities...${NC}"
    sqlmap -u "$target" --batch --crawl=2
}

# DNS Reconnaissance Suite
function dns_recon() {
    echo -e "${YELLOW}[*] Running DNS Reconnaissance...${NC}"
    dnsrecon -d "$target"
    echo -e "\n${BLUE}[*] Running Sublist3r for subdomains...${NC}"
    sublist3r -d "$target"
    echo -e "\n${CYAN}[*] Running TheHarvester for intelligence gathering...${NC}"
    theHarvester -d "$target" -b all
}

# Directory Bruteforce Analysis
function dir_bruteforce() {
    echo -e "${YELLOW}[*] Running Directory Bruteforce Analysis...${NC}"
    
    # Wordlist selection
    local wordlists=("common.txt" "big.txt" "directory-list-2.3-medium.txt" "Custom")
    PS3="Select wordlist: "
    select wordlist in "${wordlists[@]}"; do
        case $wordlist in
            "common.txt") wordlist_path="/usr/share/wordlists/dirb/common.txt"; break;;
            "big.txt") wordlist_path="/usr/share/wordlists/dirb/big.txt"; break;;
            "directory-list-2.3-medium.txt") wordlist_path="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"; break;;
            "Custom")
                read -p "Enter path to custom wordlist: " wordlist_path
                break;;
            *) echo -e "${RED}Invalid option!${NC}";;
        esac
    done
    
    read -p "Enter file extensions (comma separated, leave empty for none): " extensions
    
    echo -e "\n${BLUE}[*] Running Dirb...${NC}"
    if [ -z "$extensions" ]; then
        dirb "http://$target" "$wordlist_path"
    else
        dirb "http://$target" "$wordlist_path" -X ".$extensions"
    fi
    
    echo -e "\n${CYAN}[*] Running GoBuster...${NC}"
    if [ -z "$extensions" ]; then
        gobuster dir -u "http://$target" -w "$wordlist_path"
    else
        gobuster dir -u "http://$target" -w "$wordlist_path" -x "$extensions"
    fi
}

# Web Vulnerability Analysis (Nikto)
function web_vuln_analysis() {
    echo -e "${YELLOW}[*] Running Web Vulnerability Analysis...${NC}"
    nikto -h "$target"
    echo -e "\n${BLUE}[*] Checking for XSS vulnerabilities with XSStrike...${NC}"
    if command -v xsstrike &>/dev/null; then
        xsstrike -u "http://$target" --crawl
    else
        echo -e "${RED}[!] XSStrike not found. Consider installing for XSS detection.${NC}"
    fi
}

# Network Analysis Suite
function network_analysis() {
    echo -e "${YELLOW}[*] Running Network Analysis Suite...${NC}"
    echo -e "${BLUE}[*] Ping test...${NC}"
    ping -c 4 "$target"
    echo -e "\n${CYAN}[*] Traceroute...${NC}"
    traceroute "$target"
    echo -e "\n${GREEN}[*] WHOIS lookup...${NC}"
    whois "$target"
}

# Automated Report Generation
function generate_report() {
    local report_file="scan_report_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "Vulnerability Scan Report"
        echo "Generated on: $(date)"
        echo "Target: $target"
        echo ""
        echo "=== Nmap Results ==="
        nmap -A -T4 "$target"
        echo ""
        echo "=== Web Application Scan ==="
        whatweb -a 3 "$target"
        echo ""
        echo "=== DNS Reconnaissance ==="
        dnsrecon -d "$target"
        echo ""
        echo "=== WHOIS Information ==="
        whois "$target"
    } > "$report_file"
    
    echo -e "${GREEN}[*] Report generated: $report_file${NC}"
}

# Main Menu
function main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}Select an option:${NC}"
        echo ""
        echo -e "1) ${CYAN}Advanced Nmap Scanner${NC}"
        echo -e "2) ${PURPLE}Web Security Suite${NC}"
        echo -e "3) ${YELLOW}DNS Reconnaissance${NC}"
        echo -e "4) ${BLUE}Directory Bruteforce${NC}"
        echo -e "5) ${RED}Web Vulnerability Analysis${NC}"
        echo -e "6) ${GREEN}Network Analysis${NC}"
        echo -e "7) ${PURPLE}Automated Report Generation${NC}"
        echo -e "8) ${RED}Exit${NC}"
        echo ""
        
        read -p "Enter your choice (1-8): " choice
        
        case $choice in
            1|2|3|4|5|6|7)
                echo ""
                read -p "Enter target (URL/IP): " target
                if [ -z "$target" ]; then
                    echo -e "${RED}[!] Target cannot be empty!${NC}"
                    sleep 1
                    continue
                fi
                ;;
        esac
        
        case $choice in
            1) advanced_nmap ;;
            2) web_security_suite ;;
            3) dns_recon ;;
            4) dir_bruteforce ;;
            5) web_vuln_analysis ;;
            6) network_analysis ;;
            7) generate_report ;;
            8)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 1
                ;;
        esac
        
        echo ""
        read -p "Press Enter to return to menu..."
    done
}

# Initial checks
check_tools

# Start main menu
main_menu
