#! /bin/bash

#export API_TOKEN="CHANGE_ME"
#export NAME="CHANGE_ME"

cat <<EOF >> telegraf.conf
  bucket = "telegraf-lxc-$NAME"
  token = "$API_TOKEN"
EOF
