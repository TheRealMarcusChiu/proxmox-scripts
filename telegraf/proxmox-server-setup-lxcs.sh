#!/bin/bash

INFLUXDB_URL="http://influxdb.lan"
INFLUXDB_API_TOKEN="INFLUXDB_API_TOKEN_HERE"
INFLUXDB_ORG_ID="a09d6bc7f532489d"
INFLUXDB_ORG_NAME="marcus-company"
INFLUXDB_BUCKET_NAME_PREFIX="telegraf-lxc-"

pct list | grep running | while read line; do
    ID=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $3}')

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

    echo "Updating container: $ID $NAME"
    pct exec $ID -- bash -c "apt update && apt-get update && apt install git -y"
    pct exec $ID -- bash -c "git clone https://github.com/TheRealMarcusChiu/proxmox-scripts.git"
    pct exec $ID -- bash -c "cd /root/proxmox-scripts && git pull"
    pct exec $ID -- bash -c "export INFLUXDB_URL=\"$INFLUXDB_URL\" && export INFLUXDB_API_TOKEN=\"$INFLUXDB_API_TOKEN\" && export INFLUXDB_ORG_NAME=\"$INFLUXDB_ORG_NAME\" && export INFLUXDB_BUCKET_NAME=\"$INFLUXDB_BUCKET_NAME\" && cd /root/proxmox-scripts/telegraf && /root/proxmox-scripts/telegraf/setup.sh > /root/proxmox-scripts/telegraf/log.txt"
    pct exec $ID -- bash -c "systemctl show -p SubState,ActiveState,Result telegraf > /root/proxmox-scripts/telegraf/output.txt"
    echo "Finished updating container: $ID $NAME"

done
