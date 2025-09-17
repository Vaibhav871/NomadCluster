#!/bin/bash
set -e


sudo apt-get update
sudo apt-get install -y unzip curl ufw


curl -sLo /tmp/nomad.zip "https://releases.hashicorp.com/nomad/1.10.5/nomad_1.10.5_linux_amd64.zip"
sudo unzip /tmp/nomad.zip -d /usr/local/bin
sudo chmod +x /usr/local/bin/nomad


sudo mkdir -p /etc/nomad.d
sudo chmod 700 /etc/nomad.d


sudo tee /etc/nomad.d/server.hcl > /dev/null <<EOT
datacenter = "dc1"
server {
  enabled = true
  bootstrap_expect = 1
}
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

telemetry {
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  disable_hostname           = true
}
EOT


sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOT
[Unit]
Description=Nomad
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOT


sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad
