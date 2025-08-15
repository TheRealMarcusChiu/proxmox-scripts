#! /bin/bash

#export INFLUXDB_URL="http://influxdb.lan"
#export INFLUXDB_API_TOKEN="CHANGE_ME"
#export INFLUXDB_ORG_ID="a09d6bc7f532489d"
#export INFLUXDB_ORG_NAME="marcus-company"
#export INFLUXDB_BUCKET_NAME="telegraf-lxc-god"

sudo apt-get update
sudo apt install curl -y

# Create telegraf bucket
curl -X POST http://influxdb.lan/api/v2/buckets \
  -H "Authorization: Token $INFLUXDB_API_TOKEN" \
  -H "Content-type: application/json" \
  -d "{
        \"name\": \"$INFLUXDB_BUCKET_NAME\",
        \"orgID\": \"$INFLUXDB_ORG_ID\",
        \"retentionRules\": [
          {
            \"type\": \"expire\",
            \"everySeconds\": 86400
          }
        ]
      }"

cd /root/proxmox-scripts/telegraf

cat <<EOF > telegraf.conf
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0s"
[[inputs.disk]]
  mount_points = ["/"]

[[outputs.influxdb_v2]]
  urls = ["$INFLUXDB_URL"]
  organization = "$INFLUXDB_ORG_ID"
  bucket = "$INFLUXDB_BUCKET_NAME"
  token = "$INFLUXDB_API_TOKEN"
EOF

tar -xvzf telegraf.tar.gz
cp telegraf.service /lib/systemd/system/telegraf.service

sudo systemctl daemon-reload
sudo systemctl start telegraf
sudo systemctl enable telegraf
