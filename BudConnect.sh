#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    echo -e "${GREEN}BudConnect v3.1${NC}"
    echo "Shell:"
    echo "  ./BudConnect.sh -l -p PORT"
    echo "  ./BudConnect.sh -c IP PORT"
    echo "Chat:"
    echo "  ./BudConnect.sh -l -p PORT chat"
    echo "  ./BudConnect.sh -c IP PORT chat"
    echo "File Transfer:"
    echo "  ./BudConnect.sh -l -p PORT file"
    echo "  ./BudConnect.sh -c IP PORT file FILEPATH"
    exit 0
}

socket_listen() {
    local port=$1
    exec 3<>/dev/tcp/0.0.0.0/$port
}

socket_connect() {
    local host=$1
    local port=$2
    exec 3<>/dev/tcp/$host/$port
}

shell_server() {
    local port=$1
    while true; do
        socket_listen $port
        bash <&3 >&3 2>&3
        exec 3<&-
    done
}

shell_client() {
    local host=$1
    local port=$2
    socket_connect $host $port
    bash <&3 >&3 2>&3
}

chat_server() {
    local port=$1
    socket_listen $port
    cat <&3 &
    cat >&3
}

chat_client() {
    local host=$1
    local port=$2
    socket_connect $host $port
    cat <&3 &
    cat >&3
}

file_server() {
    local port=$1
    socket_listen $port
    cat <&3 > received_file
}

file_client() {
    local host=$1
    local port=$2
    local file=$3
    socket_connect $host $port
    cat $file >&3
}

case $1 in
    -h|--help) show_help ;;
    -l|--listen)
        case $2 in
            -p|--port)
                case $4 in
                    chat) chat_server $3 ;;
                    file) file_server $3 ;;
                    *) shell_server $3 ;;
                esac
                ;;
            *) show_help ;;
        esac
        ;;
    -c|--connect)
        case $4 in
            chat) chat_client $2 $3 ;;
            file) file_client $2 $3 $5 ;;
            *) shell_client $2 $3 ;;
        esac
        ;;
    *) show_help ;;
esac
