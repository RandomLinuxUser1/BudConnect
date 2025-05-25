#!/bin/bash

# Minimal BudConnect v3.5 - Netcat Edition
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if netcat exists
if ! command -v nc &>/dev/null; then
    echo -e "${RED}Error: netcat (nc) not installed${NC}"
    echo "Install with:"
    echo "  Linux: sudo apt install netcat"
    echo "  Termux: pkg install netcat-openbsd"
    exit 1
fi

# Main function
case $1 in
    -l|--listen)
        [ -z "$3" ] && echo -e "${RED}Port required${NC}" && exit 1
        echo -e "${GREEN}Listening on port $3${NC}"
        case $4 in
            chat) nc -lvnp $3 ;;
            file) nc -lvnp $3 > received_file ;;
            *) nc -lvnp $3 -e /bin/bash ;;
        esac
        ;;
    -c|--connect)
        [ -z "$3" ] && echo -e "${RED}IP and port required${NC}" && exit 1
        echo -e "${GREEN}Connecting to $2:$3${NC}"
        case $4 in
            chat) nc $2 $3 ;;
            file) [ -z "$5" ] && echo "File path required" && exit 1
                  nc $2 $3 < "$5" ;;
            *) nc $2 $3 ;;
        esac
        ;;
    *)
        echo "Usage:"
        echo "  ./budconnect.sh -l -p PORT [mode]"
        echo "  ./budconnect.sh -c IP PORT [mode]"
        echo "Modes: shell (default), chat, file"
        ;;
esac
