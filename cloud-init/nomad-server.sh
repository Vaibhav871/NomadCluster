#!/bin/bash
set -e

echo "Configuring Nomad Server..."


CLUSTER_SERVER_COUNT=3             # Should match your cluster size!
SERVER_AWS_TAG_KEY="NomadServer"
SERVER_AWS_TAG_VALUE="true"

# Create directories with locked-down permissions
sudo mkdir -p /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo mkdir -p /opt/nomad
sudo chmod 700 /opt/nomad

# Optionally, create a dedicated system user for production
# sudo useradd --system --home /opt/nomad --shell /bin/false nomad
# sudo chown -R nomad:nomad /etc/nomad.d /opt/nomad

# Get instance private IP for advertise block
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
  collection_interval         = "15s"
  prometheus_metrics          = true
  publish_allocation_metrics  = true
  publish_node_metrics        = true
  disable_hostname            = true
}
EOF

# Secure config file permissions
sudo chmod 600 /etc/nomad.d/server.hcl

# Optionally, chown for system user
# sudo chown nomad:nomad /etc/nomad.d/server.hcl

sudo systemctl restart nomad
sudo systemctl enable nomad
