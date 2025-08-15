#!/bin/bash

INFLUXDB_URL="http://influxdb.lan"
INFLUXDB_API_TOKEN="INFLUXDB_API_TOKEN_HERE"
INFLUXDB_ORG_ID="a09d6bc7f532489d"
INFLUXDB_ORG_NAME="marcus-company"
INFLUXDB_BUCKET_NAME_PREFIX="telegraf-vm-"

qm list | grep running | while read line; do
    ID=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $2}')

    INFLUXDB_BUCKET_NAME="$INFLUXDB_BUCKET_NAME_PREFIX$NAME"

    # Create telegraf bucket
    curl -X POST "$INFLUXDB_URL/api/v2/buckets" \
         -H "Authorization: Token $INFLUXDB_API_TOKEN" \
         -H "Content-type: application/json" \
         -d "{
               \"name\": \"$INFLUXDB_BUCKET_NAME\",
               \"orgID\": \"$INFLUXDB_ORG_ID\",
               \"retentionRules\": [{
                   \"type\": \"expire\",
                   \"everySeconds\": 604800
               }]
             }"

    echo "Updating VM: $ID $NAME"
    qm guest exec $ID -- bash -c "sudo apt update && sudo apt-get update && sudo apt install git -y"
    qm guest exec $ID -- bash -c "cd /root && git clone https://github.com/TheRealMarcusChiu/proxmox-scripts.git"
    qm guest exec $ID -- bash -c "cd /root/proxmox-scripts && git pull"
    qm guest exec $ID -- bash -c "export INFLUXDB_URL=\"$INFLUXDB_URL\" && export INFLUXDB_API_TOKEN=\"$INFLUXDB_API_TOKEN\" && export INFLUXDB_ORG_NAME=\"$INFLUXDB_ORG_NAME\" && export INFLUXDB_BUCKET_NAME=\"$INFLUXDB_BUCKET_NAME\" && cd /root/proxmox-scripts/telegraf && /root/proxmox-scripts/telegraf/setup.sh > /root/proxmox-scripts/telegraf/log.txt"
    qm guest exec $ID -- bash -c "systemctl show -p SubState,ActiveState,Result telegraf > /root/proxmox-scripts/telegraf/output.txt"
    echo "Finished updating VM: $ID $NAME"

done
