#!/bin/bash
set -e


sudo apt-get update -y
sudo apt-get install -y wget tar unzip apt-transport-https software-properties-common gnupg2

sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus


cd /tmp
PROM_VERSION="3.5.0"
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool


# Prometheus config

sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOT
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "nomad"
    metrics_path: "/v1/metrics"
    params:
      format: ["prometheus"]
    static_configs:
      - targets: ["<client-nomad-ip>:4646","<server-nomad-ip>:4646"]
EOT

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus


#Create Prometheus systemd service

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOT
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus


# Install Grafana

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update -y
sudo apt-get install -y grafana

sudo systemctl enable --now grafana-server



echo "Prometheus and Grafana installed successfully."
echo "Prometheus: http://<BASTION_PUBLIC_IP>:9090"
echo "Grafana: http://<BASTION_PUBLIC_IP>:3000 (default user: admin, password: admin)"
