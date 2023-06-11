#!/bin/bash

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

function check_proxy_status(){
    local $ip="$1"
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "$ip")

    if [ "$http_status" -eq 200 ]; then
        echo "HTTP status code 200: Success"
    else
        echo "HTTP status code $http_status: Error"
    fi
}

function install_apache_utils(){
    sudo apt install apache2-utils -y
}

function set_password(){
    local $password="$1"    
    sudo touch /etc/squid/passwd
    sudo chown proxy /etc/squid/passwd
    sudo htpasswd -cb /etc/squid/passwd proxyuser "$password"
}

function add_config(){
    content=$(cat <<EOF
    auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
    auth_param basic children 5
    auth_param basic realm Squid Basic Authentication
    auth_param basic credentialsttl 2 hours
    acl auth_users proxy_auth REQUIRED
    http_access allow auth_users
    EOF
    )

    echo "$content" >> /etc/squid/squid.conf
}

function restart_squid(){ 
    sudo systemctl restart squid
}

function block_website(){
    local $website="$1"
    echo "$website" >> /etc/squid/proxy-block-list.acl
}