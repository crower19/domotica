#!/usr/bin/env bash -ex

set -euo pipefail
shopt -s inherit_errexit nullglob
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
clear
echo -e "${BL}This script will prepare zigbee envioronment.${CL}"
while true; do
    read -p "Start the preparation script (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

function header_info {
echo -e "${RD}
 ___       _ _   _       _   ____       _               
|_ _|_ __ (_) |_(_) __ _| | / ___|  ___| |_ _   _ _ __  
 | ||  _ \| | __| |/ _  | | \___ \ / _ \ __| | | |  _ \ 
 | || | | | | |_| | (_| | |  ___) |  __/ |_| |_| | |_) |
|___|_| |_|_|\__|_|\____|_| |____/ \___|\__|\____|  __/ 
                                                 |_|    
${CL}"
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
user=""
port=""
clear
header_info
read -r -p "Create folder structure to mosquitto and zigbee2mqtt? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
read -r -p "Specify the user to use in the path. example: ubutnu " user_prompt
if [[ $user_prompt != "" ]]
then
msg_info "Creating folder structures"
user="$user_prompt"
mkdir -p /home/$user/containers/mosquitto/{config,data,log}
mkdir -p /home/$user/containers/zigbee2mqtt/data
msg_ok "Folders created"
fi
fi

read -r -p "Create mosquitto config file? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Creating file..."
cat <<EOF > /home/$user/containers/mosquitto/config/mosquitto.conf
port 1883
listener 9001
allow_anonymous true
protocol websockets
persistence true
persistence_location /mosquitto/data/ 
log_dest file /mosquitto/log/mosquitto.log
EOF
sleep 2
msg_ok "Created file mosquitto.conf"
fi

read -r -p "Create zigbee2mqtt config file? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
read -r -p "Specify the usb port? <ttyACM0/ttyUSB0> " port_prompt
if [[ $port_prompt != "" ]]
then
msg_info "Creating file..."
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
port="$port_prompt"
cat <<EOF > /home/$user/containers/zigbee2mqtt/data/configuration.yaml
homeassistant: true
permit_join: true
availability:
  active:
    timeout: 10
  passive:
    timeout: 1500
mqtt:
  server: mqtt://$ip4:1883
advanced:
  last_seen: ISO_8601_local
serial:
  port: /dev/$port
frontend: true

EOF
sleep 2
msg_ok "Created file configuration.yaml"
fi
fi
