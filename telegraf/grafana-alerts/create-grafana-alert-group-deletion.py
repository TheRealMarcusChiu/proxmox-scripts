import hashlib

header = """apiVersion: 1
deleteRules:
"""

alert_rule_template = """  - orgId: 1
    uid: ALERT_UID_HERE
"""

bucket_names = ["telegraf-lxc-13ft", "telegraf-lxc-adguard", "telegraf-lxc-archivebox", "telegraf-lxc-audiobookshelf", "telegraf-lxc-bookstack", "telegraf-lxc-changedetection", "telegraf-lxc-code-server", "telegraf-lxc-cyberchef", "telegraf-lxc-dashy", "telegraf-lxc-docmost", "telegraf-lxc-grafana", "telegraf-lxc-homebox", "telegraf-lxc-homepage", "telegraf-lxc-influxdb", "telegraf-lxc-jenkins", "telegraf-lxc-kasm", "telegraf-lxc-keycloak", "telegraf-lxc-librespeed-rust", "telegraf-lxc-mealie", "telegraf-lxc-onlyoffice", "telegraf-lxc-outline", "telegraf-lxc-paperless-ai", "telegraf-lxc-paperless-gpt", "telegraf-lxc-paperless-ngx", "telegraf-lxc-qbittorrent", "telegraf-lxc-reactive-resume", "telegraf-lxc-sandbox", "telegraf-lxc-stirling-pdf", "telegraf-lxc-syncthing", "telegraf-lxc-traefik", "telegraf-lxc-ubuntu-server-nginx-log-backup", "telegraf-lxc-ubuntu-server-proxy", "telegraf-lxc-ubuntu-server-wordpress-thoughts", "telegraf-lxc-vaultwarden", "telegraf-lxc-whoogle"]

with open("disk-almost-full-deletion.yaml", "w") as file:
    file.write(header)

    for bucket_name in bucket_names:
        hashed = hashlib.sha256(bucket_name.encode()).hexdigest()
        short_hash = hashed[:14]
        new_text = alert_rule_template.replace("ALERT_UID_HERE", short_hash, 1)
        file.write(new_text)
