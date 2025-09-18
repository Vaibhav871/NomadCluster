#!/bin/bash
set -e

echo "Configuring Nomad Server..."


CLUSTER_SERVER_COUNT=1
SERVER_AWS_TAG_KEY="nomad-server"
SERVER_AWS_TAG_VALUE="true"

# Create directories with locked-down permissions
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
  bootstrap_expect = 1

}

telemetry {
  collection_interval         = "15s"
  prometheus_metrics          = true
  publish_allocation_metrics  = true
  publish_node_metrics        = true
  disable_hostname            = true
}
EOF

sudo mkdir -p /opt/nomad
sudo chown -R nomad:nomad /opt/nomad
sudo chmod 700 /opt/nomad
# Set proper ownership
chown nomad:nomad /etc/nomad.d/server.hcl

# Restart Nomad service
systemctl restart nomad
systemctl enable nomad
