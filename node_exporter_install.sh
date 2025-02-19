#!/bin/bash
set -euo pipefail

wget https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz
sudo groupadd -f node_exporter
sudo id -u node_exporter >/dev/null 2>&1 || sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
sudo mkdir -p /etc/node_exporter
sudo chown node_exporter:node_exporter /etc/node_exporter
tar -xvf node_exporter-1.9.0.linux-amd64.tar.gz
mv node_exporter-1.9.0.linux-amd64 node_exporter-files
sudo cp node_exporter-files/node_exporter /usr/bin/
sudo chown node_exporter:node_exporter /usr/bin/node_exporter

sudo tee -a /etc/systemd/system/node_exporter.service >/dev/null <<EOL
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

sudo chmod 664 /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter.service
rm -r node_exporter-files
rm node_exporter-1.9.0.linux-amd64.tar.gz
