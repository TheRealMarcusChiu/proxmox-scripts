import hashlib

header = """apiVersion: 1
groups:
  - orgId: 1
    name: evaluation-group-disk-almost-full
    folder: Disk Almost Full
    interval: 1m
    rules:
"""

alert_rule_template = """      - uid: ALERT_UID_HERE
        title: BUCKET_NAME_HERE
        condition: C
        data:
          - refId: A
            relativeTimeRange:
              from: 60
              to: 0
            datasourceUid: deu40om3f7xfkc
            model:
              intervalMs: 1000
              maxDataPoints: 43200
              query: |-
                from(bucket: "BUCKET_NAME_HERE")
                  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
                  |> filter(fn: (r) => r["_measurement"] == "disk")
                  |> filter(fn: (r) => r["_field"] == "used_percent")
                  |> aggregateWindow(every: v.windowPeriod, fn: last, createEmpty: false)
                  |> yield(name: "last")
              refId: A
          - refId: B
            datasourceUid: __expr__
            model:
              conditions:
                - evaluator:
                    params: []
                    type: gt
                  operator:
                    type: and
                  query:
                    params:
                      - B
                  reducer:
                    params: []
                    type: last
                  type: query
              datasource:
                type: __expr__
                uid: __expr__
              expression: A
              intervalMs: 1000
              maxDataPoints: 43200
              reducer: last
              refId: B
              type: reduce
          - refId: C
            datasourceUid: __expr__
            model:
              conditions:
                - evaluator:
                    params:
                      - 90
                    type: gt
                  operator:
                    type: and
                  query:
                    params:
                      - C
                  reducer:
                    params: []
                    type: last
                  type: query
              datasource:
                type: __expr__
                uid: __expr__
              expression: B
              intervalMs: 1000
              maxDataPoints: 43200
              refId: C
              type: threshold
        noDataState: NoData
        execErrState: Error
        annotations:
          description: optional description
          summary: optional summary
        isPaused: false
        notification_settings:
          receiver: Discord
"""

bucket_names = [
    "telegraf-lxc-13ft",
    "telegraf-lxc-adguard",
    "telegraf-lxc-archivebox",
    "telegraf-lxc-audiobookshelf",
    "telegraf-lxc-bookstack",
    "telegraf-lxc-changedetection",
    "telegraf-lxc-code-server",
    "telegraf-lxc-cyberchef",
    "telegraf-lxc-dashy",
    "telegraf-lxc-docmost",
    "telegraf-lxc-gitea",
    "telegraf-lxc-grafana",
    "telegraf-lxc-homebox",
    "telegraf-lxc-homepage",
    "telegraf-lxc-immich",
    "telegraf-lxc-influxdb",
    "telegraf-lxc-jenkins",
    "telegraf-lxc-kasm",
    "telegraf-lxc-keycloak",
    "telegraf-lxc-librespeed-rust",
    "telegraf-lxc-mealie",
    "telegraf-lxc-onlyoffice",
    "telegraf-lxc-outline",
    "telegraf-lxc-paperless-ai",
    "telegraf-lxc-paperless-gpt",
    "telegraf-lxc-paperless-ngx",
    "telegraf-lxc-pterodactyl-panel",
    "telegraf-lxc-qbittorrent",
    "telegraf-lxc-reactive-resume",
    "telegraf-lxc-sandbox",
    "telegraf-lxc-stirling-pdf",
    "telegraf-lxc-syncthing",
    "telegraf-lxc-traefik",
    "telegraf-lxc-ubuntu-server-nginx-log-backup",
    "telegraf-lxc-ubuntu-server-proxy",
    "telegraf-lxc-ubuntu-server-wordpress-thoughts",
    "telegraf-lxc-vaultwarden",
    "telegraf-lxc-whoogle"
]

with open("disk-almost-full.yaml", "w") as file:
    file.write(header)

    for bucket_name in bucket_names:
        hashed = hashlib.sha256(bucket_name.encode()).hexdigest()
        short_hash = hashed[:14]

        new_text = alert_rule_template.replace("ALERT_UID_HERE", short_hash, 1)
        new_text = new_text.replace("BUCKET_NAME_HERE", bucket_name, 2)

        file.write(new_text)
