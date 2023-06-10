#!/usr/bin/env bash

function install_dependencies(){
    sudo apt update -y
    sudo apt -y install squid
    }

function start_squid(){
    sudo systemctl start squid
    sudo systemctl enable squid
}

function check_status_netstat(){
    while true; do
    port_state=$(sudo netstat -tlnp | grep ":3128" | awk '{print $6}')

    if [[ $port_state == "LISTEN" ]]; then
        echo "Port 3128 is listening."
    else
        echo "Port 3128 is not listening."
    fi

    sleep 0.1
done
}

function uncomment_line(){
    sed -i '/http_access/s/^# //' /etc/squid/squid.conf
}

function add_acl(){
    local ip="$1"
    acl localnet src "$ip"
}