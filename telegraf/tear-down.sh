#! /bin/bash

sudo systemctl disable telegraf
sudo systemctl stop telegraf
rm /lib/systemd/system/telegraf.service
sudo systemctl daemon-reload

rm /root/proxmox-scripts/telegraf/telegraf

cat <<EOF > telegraf.conf
EOF
