
#!/bin/bash
set -e
echo "Configuring Nomad Client..."

# Variables for AWS tag-based discovery and datacenter name
# SERVER_AWS_TAG_KEY="nomad-server"
# SERVER_AWS_TAG_VALUE="true"

# NOMAD_SERVER_IP="${NOMAD_SERVER_IP}"
# INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo mkdir -p /opt/nomad
sudo chown -R nomad:nomad /opt/nomad
sudo chmod 700 /opt/nomad

sudo mkdir -p /opt/alloc_mounts
sudo chown -R nomad:nomad /opt/alloc_mounts
sudo chmod 700 /opt/alloc_mounts


sudo tee /etc/nomad.d/client.hcl > /dev/null <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

client {
  enabled = true
}

server_join {
  retry_join = ["provider=aws tag_key=Name tag_value=nomad-server"]
  retry_max = 5
  retry_interval = "30s"
}

telemetry {
  collection_interval          = "15s"
  prometheus_metrics           = true
  publish_allocation_metrics   = true
  publish_node_metrics         = true
  disable_hostname             = true
}
EOF

# Set proper ownership
chown nomad:nomad /etc/nomad.d/client.hcl

sudo usermod -aG docker nomad
newgrp docker

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart nomad
sudo systemctl enable nomad