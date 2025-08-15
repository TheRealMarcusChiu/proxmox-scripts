#! /bin/bash

mkdir /root/telegraf
cd /root/telegraf

wget https://github.com/TheRealMarcusChiu/proxmox-scripts/raw/refs/heads/master/telegraf/telegraf.tar.gz

tar -xvzf telegraf.tar.gz

cat << EOF > /root/telegraf/telegraf.conf
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
  token = "$API_TOKEN"
  organization = "marcus-company"
  bucket = "telegraf-lxc-test"
EOF

cat << EOF > /lib/systemd/system/telegraf.service
[Unit]
Description=Telegraf
Documentation=https://github.com/influxdata/telegraf
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
NotifyAccess=all
User=root
ExecStart=/root/telegraf/telegraf -config /root/telegraf/telegraf.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartForceExitStatus=SIGPIPE
KillMode=mixed
LimitMEMLOCK=8M:8M
PrivateMounts=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start telegraf
sudo systemctl enable telegraf
sudo systemctl status telegraf
