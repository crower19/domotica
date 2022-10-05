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
    ____ _    _____________   ____             __     ____           __        ____
   / __ \ |  / / ____/__  /  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/    / /  / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __  / / / 
 / ____/| |/ / /___   / /  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  
/_/     |___/_____/  /_/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/   
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

clear
header_info
read -r -p "Specify the user to use in the path. example: ubutnu " user
if [[ $user != "" ]]
then
msg_info "Creating folder structures"
mkdir -p /home/$user/containers/mosquitto/{config,data,log}
mkdir -p /home/$user/containers/zigbee2mqtt/data
msg_ok "Folders created"
fi

read -r -p "Create Mosquitto Config File? <y/N> " prompt
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



read -r -p "Create Zigbee2Mqtt Config File? <y/N> " port
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
read -r -p "Specify the usb port? <ttyACM0/ttyUSB0> " port
if [[ $port != "" ]]
then
msg_info "Creating file..."
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
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
