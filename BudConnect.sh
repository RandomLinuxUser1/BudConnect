#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if ! command -v nc &> /dev/null; then
    echo -e "${RED}Error: netcat (nc) not found${NC}"
    echo "Install with:"
    echo "  Linux: sudo apt install netcat"
    echo "  Termux: pkg install netcat-openbsd"
    exit 1
fi

case $1 in
    -l|--listen)
        echo -e "${GREEN}[*] Listening on port $3${NC}"
        case $4 in
            chat) nc -lvp $3 ;;
            file) nc -lvp $3 > received_file ;;
            *) nc -lvp $3 -e /bin/bash ;;
        esac
        ;;
    -c|--connect)
        echo -e "${GREEN}[*] Connecting to $2:$3${NC}"
        case $4 in
            chat) nc $2 $3 ;;
            file) [ -z "$5" ] && echo "Specify file path" && exit 1
                  nc $2 $3 < $5 ;;
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
