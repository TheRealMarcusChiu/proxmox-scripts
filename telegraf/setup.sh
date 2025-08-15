#! /bin/bash

#export API_TOKEN="CHANGE_ME"
#export NAME="CHANGE_ME"

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
  urls = ["http://influxdb.lan"]
  organization = "marcus-company"
  bucket = "telegraf-lxc-$NAME"
  token = "$API_TOKEN"
EOF

tar -xvzf telegraf.tar.gz
cp telegraf.service /lib/systemd/system/telegraf.service

sudo systemctl daemon-reload
sudo systemctl start telegraf
sudo systemctl enable telegraf
sudo systemctl status telegraf
