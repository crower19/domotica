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

 /$$$$$$$$ /$$           /$$                                  /$$$$$$              /$$                        
|_____ $$ |__/          | $$                                 /$$__  $$            | $$                        
     /$$/  /$$  /$$$$$$ | $$$$$$$   /$$$$$$   /$$$$$$       | $$  \__/  /$$$$$$  /$$$$$$   /$$   /$$  /$$$$$$ 
    /$$/  | $$ /$$__  $$| $$__  $$ /$$__  $$ /$$__  $$      |  $$$$$$  /$$__  $$|_  $$_/  | $$  | $$ /$$__  $$
   /$$/   | $$| $$  \ $$| $$  \ $$| $$$$$$$$| $$$$$$$$       \____  $$| $$$$$$$$  | $$    | $$  | $$| $$  \ $$
  /$$/    | $$| $$  | $$| $$  | $$| $$_____/| $$_____/       /$$  \ $$| $$_____/  | $$ /$$| $$  | $$| $$  | $$
 /$$$$$$$$| $$|  $$$$$$$| $$$$$$$/|  $$$$$$$|  $$$$$$$      |  $$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$/| $$$$$$$/
|________/|__/ \____  $$|_______/  \_______/ \_______/       \______/  \_______/   \___/   \______/ | $$____/ 
               /$$  \ $$                                                                            | $$      
              |  $$$$$$/                                                                            | $$      
               \______/                                                                             |__/      
           
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
mkdir -p /home/$user/containers/zigbee2mqtt
msg_ok "Folders created"
fi

read -r -p "Create mosquitto.conf? <y/N> " prompt
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
