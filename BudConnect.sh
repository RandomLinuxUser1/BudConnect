#!/bin/bash

# BudConnect v1.0 - Advanced Remote Shell Tool (Ethical Use Only)
# Features: Reverse Shell, File Transfer, Encryption, Persistence

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Usage
usage() {
    echo -e "${GREEN}BudConnect v1.0 - Remote Shell Tool${NC}"
    echo "Usage:"
    echo "  Listen Mode: ./budconnect.sh -l -p PORT [-e]"
    echo "  Connect Mode: ./budconnect.sh HOST PORT [-e]"
    echo "  File Transfer: After connection, use 'send FILE' or 'get FILE'"
    echo -e "${RED}WARNING: For educational use only!${NC}"
    exit 1
}

# Check for args
if [ $# -lt 2 ]; then
    usage
fi

# Listener Mode
if [ "$1" == "-l" ] && [ "$2" == "-p" ]; then
    PORT="$3"
    ENCRYPT=false
    
    # Check for encryption flag
    if [ "$4" == "-e" ]; then
        ENCRYPT=true
        echo -e "${GREEN}[*] Starting encrypted listener on port $PORT...${NC}"
        openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem -subj "/CN=BudConnect"
        openssl s_server -quiet -key key.pem -cert cert.pem -port "$PORT"
    else
        echo -e "${GREEN}[*] Starting listener on port $PORT...${NC}"
        nc -lvnp "$PORT"
    fi

# Client Mode
else
    HOST="$1"
    PORT="$2"
    ENCRYPT=false
    
    # Check for encryption
    if [ "$3" == "-e" ]; then
        ENCRYPT=true
        echo -e "${GREEN}[*] Connecting to $HOST:$PORT (encrypted)...${NC}"
        openssl s_client -quiet -connect "$HOST:$PORT" 2>/dev/null
    else
        echo -e "${GREEN}[*] Connecting to $HOST:$PORT...${NC}"
        nc "$HOST" "$PORT"
    fi
fi
