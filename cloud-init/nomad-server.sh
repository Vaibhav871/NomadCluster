#!/bin/bash
set -e

echo "Configuring Nomad Server..."


CLUSTER_SERVER_COUNT=1
SERVER_AWS_TAG_KEY="nomad-server"
SERVER_AWS_TAG_VALUE="true"

sudo mkdir -p /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo mkdir -p /opt/nomad
sudo chmod 700 /opt/nomad


INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

sudo tee /etc/nomad.d/server.hcl > /dev/null <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

advertise {
  http = "${INSTANCE_IP}"
  rpc  = "${INSTANCE_IP}"
  serf = "${INSTANCE_IP}"
}

server {
  enabled = true
  bootstrap_expect = ${CLUSTER_SERVER_COUNT}
  server_join {
    retry_join = ["provider=aws tag_key=${SERVER_AWS_TAG_KEY} tag_value=${SERVER_AWS_TAG_VALUE}"]
    retry_interval = "15s"
  }
}

telemetry {
  collection_interval         = "15s"S
  prometheus_metrics          = true
  publish_allocation_metrics  = true
  publish_node_metrics        = true
  disable_hostname            = true
}
EOF

# Secure config file permissions
sudo chmod 600 /etc/nomad.d/server.hcl

# Optionally, chown for system user
sudo chown nomad:nomad /etc/nomad.d/server.hcl

sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl restart nomad

